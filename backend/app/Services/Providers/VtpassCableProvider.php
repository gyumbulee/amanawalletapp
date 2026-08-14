<?php

namespace App\Services\Providers;

use App\Contracts\Providers\CableProviderInterface;
use App\Models\Provider;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class VtpassCableProvider implements CableProviderInterface
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
            ->timeout($timeout)
            ->retry(2, 500);
    }

    public function listPlans(string $cableProvider): array
    {
        return Cache::remember(
            "vtpass-cable-plans-{$cableProvider}",
            now()->addHours(6),
            function () use ($cableProvider) {
                $response = $this->client()
                    ->get(config('services.vtpass.base_url') . '/service-variations', [
                        'serviceID' => $cableProvider,
                    ]);

                $body = $response->json() ?? [];

                if (
                    ! $response->successful() ||
                    ($body['response_description'] ?? null) !== '000'
                ) {
                    throw new RuntimeException(
                        $body['response_description']
                            ?? 'Failed to fetch cable plans.'
                    );
                }

                $variations = $body['content']['variations'] ?? [];

                return array_map(function ($variation) {
                    return [
                        'variation_code' => $variation['variation_code'],
                        'name' => $variation['name'],
                        'amount' => (float) $variation['variation_amount'],
                    ];
                }, $variations);
            }
        );
    }

    public function verifySmartcard(
        string $cableProvider,
        string $smartcardNumber
    ): array {
        $response = $this->client()
            ->post(config('services.vtpass.base_url') . '/merchant-verify', [
                'billersCode' => $smartcardNumber,
                'serviceID' => $cableProvider,
            ]);

        $body = $response->json() ?? [];

        $content = $body['content'] ?? [];

        if (
            ! $response->successful() ||
            empty($content['Customer_Name'] ?? null)
        ) {
            throw new RuntimeException(
                $content['error']
                    ?? $body['response_description']
                    ?? 'Smartcard verification failed.'
            );
        }

        return [
            'customer_name' => $content['Customer_Name'],
            'customer_number' => $content['Customer_Number'] ?? $smartcardNumber,
            'status' => $content['Status'] ?? null,
        ];
    }

    public function subscribe(
        string $cableProvider,
        string $smartcardNumber,
        string $variationCode,
        float $amount,
        string $phone,
        string $reference
    ): array {
        // Smartcard verification should already happen before purchase.
        // Avoid making a second verification request here.

        $response = $this->client()
            ->post(config('services.vtpass.base_url') . '/pay', [
                'request_id' => $reference,
                'serviceID' => $cableProvider,
                'billersCode' => $smartcardNumber,
                'variation_code' => $variationCode,
                'amount' => $amount,
                'phone' => $phone,
                'subscription_type' => 'change',
                'quantity' => 1,
            ]);

        $body = $response->json() ?? [];

        if (
            ! $response->successful() ||
            ($body['code'] ?? null) !== '000'
        ) {
            throw new RuntimeException(
                $body['response_description']
                    ?? 'VTpass cable subscription failed.'
            );
        }

        $transaction = $body['content']['transactions'] ?? [];

        return [
            'provider_reference' => $transaction['transactionId'] ?? $reference,
            'status' => $transaction['status'] ?? 'delivered',
        ];
    }
}