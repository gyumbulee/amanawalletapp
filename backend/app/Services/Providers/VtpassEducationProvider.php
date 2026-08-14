<?php

namespace App\Services\Providers;

use App\Contracts\Providers\EducationProviderInterface;
use App\Models\Provider;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class VtpassEducationProvider implements EducationProviderInterface
{
    protected function client()
    {
        $timeout = Provider::query()
            ->where('slug', 'vtpass')
            ->value('timeout_seconds') ?? 30;

        return Http::withHeaders([
            'api-key' => config('services.vtpass.api_key'),
            'secret-key' => config('services.vtpass.secret_key'),
        ])
            ->connectTimeout(5)
            ->timeout($timeout);
    }

    public function listPlans(string $educationType): array
    {
        return Cache::remember(
            "vtpass-education-plans-{$educationType}",
            now()->addHours(6),
            function () use ($educationType) {
                $response = $this->client()
                    ->get(config('services.vtpass.base_url') . '/service-variations', [
                        'serviceID' => $educationType,
                    ]);

                $body = $response->json() ?? [];

                if (
                    ! $response->successful() ||
                    ($body['response_description'] ?? null) !== '000'
                ) {
                    throw new RuntimeException(
                        $body['response_description']
                            ?? 'Failed to fetch VTpass education plans.'
                    );
                }

                $variations = $body['content']['variations'] ?? [];

                return array_map(fn ($variation) => [
                    'variation_code' => $variation['variation_code'],
                    'name' => $variation['name'],
                    'amount' => (float) $variation['variation_amount'],
                ], $variations);
            }
        );
    }

    public function verifyProfile(
        string $educationType,
        string $profileId
    ): array {
        // Only JAMB requires pre-purchase profile verification.
        if ($educationType !== 'jamb') {
            return [];
        }

        $response = $this->client()
            ->post(config('services.vtpass.base_url') . '/merchant-verify', [
                'billersCode' => $profileId,
                'serviceID' => 'jamb',
                'type' => 'utme',
            ]);

        $body = $response->json() ?? [];

        $content = $body['content'] ?? [];

        if (
            ! $response->successful() ||
            empty($content['Customer_Name'] ?? null)
        ) {
            throw new RuntimeException(
                $body['response_description']
                    ?? $content['error']
                    ?? 'JAMB profile verification failed.'
            );
        }

        return [
            'candidate_name' => $content['Customer_Name'],
        ];
    }

    public function purchase(
        string $educationType,
        string $variationCode,
        float $amount,
        string $phone,
        ?string $profileId,
        string $reference
    ): array {
        $payload = [
            'request_id' => $reference,
            'serviceID' => $educationType,
            'variation_code' => $variationCode,
            'amount' => $amount,
            'phone' => $phone,
        ];

        if ($educationType === 'jamb' && $profileId) {
            $payload['billersCode'] = $profileId;
        }

        $response = $this->client()
            ->post(config('services.vtpass.base_url') . '/pay', $payload);

        $body = $response->json() ?? [];

        Log::info('VTpass education raw response', [
            'body' => $body,
        ]);

        if (
            ! $response->successful() ||
            ($body['code'] ?? null) !== '000'
        ) {
            throw new RuntimeException(
                $body['response_description']
                    ?? 'VTpass education purchase failed.'
            );
        }

        $content = $body['content'] ?? [];
        $transaction = $content['transactions'] ?? [];

        /*
        |--------------------------------------------------------------------------
        | VTpass may return education cards at the ROOT of the response.
        |--------------------------------------------------------------------------
        */

        $card = $body['cards'][0]
            ?? $body['Cards'][0]
            ?? $content['cards'][0]
            ?? $content['Cards'][0]
            ?? [];

        Log::info('VTpass extracted education card', [
            'card' => $card,
        ]);

        $result = [
            'provider_reference' => $transaction['transactionId']
                ?? $reference,

            'status' => $transaction['status']
                ?? 'delivered',

            'pin' => $card['Pin']
                ?? $card['pin']
                ?? $body['Pin']
                ?? $body['pin']
                ?? $body['purchased_code']
                ?? $transaction['unique_element']
                ?? null,

            'serial' => $card['Serial']
                ?? $card['serial']
                ?? null,
        ];

        Log::info('VTpass education parsed result', $result);

        return $result;
    }
}