<?php

namespace App\Services\Providers;

use App\Contracts\Providers\DataProviderInterface;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class VtpassDataProvider implements DataProviderInterface
{
    protected const SERVICE_IDS = [
        'mtn' => 'mtn-data',
        'glo' => 'glo-data',
        'airtel' => 'airtel-data',
        '9mobile' => 'etisalat-data',
    ];

    public function listPlans(string $network): array
    {
        $serviceId = self::SERVICE_IDS[$network] ?? null;

        if (! $serviceId) {
            throw new RuntimeException("Unsupported network for VTpass data: {$network}");
        }

        return Cache::remember("vtpass-data-plans-{$serviceId}", now()->addHours(6), function () use ($serviceId) {
            $response = Http::withHeaders([
                'api-key' => config('services.vtpass.api_key'),
                'secret-key' => config('services.vtpass.secret_key'),
            ])
                ->timeout(\App\Models\Provider::query()->where('slug', 'vtpass')->value('timeout_seconds') ?? 30)
                ->get(config('services.vtpass.base_url') . '/service-variations', [
                    'serviceID' => $serviceId,
                ]);

            $body = $response->json() ?? [];

            if (! $response->successful() || ($body['response_description'] ?? null) !== '000') {
                throw new RuntimeException('Failed to fetch VTpass data plans.');
            }

            $variations = $body['content']['variations'] ?? [];

            return array_map(fn ($v) => [
                'variation_code' => $v['variation_code'],
                'name' => $v['name'],
                'amount' => (float) $v['variation_amount'],
            ], $variations);
        });
    }

    public function purchase(string $network, string $phone, string $variationCode, float $amount, string $reference): array
    {
        $serviceId = self::SERVICE_IDS[$network] ?? null;

        if (! $serviceId) {
            throw new RuntimeException("Unsupported network for VTpass data: {$network}");
        }

        $response = Http::withHeaders([
            'api-key' => config('services.vtpass.api_key'),
            'secret-key' => config('services.vtpass.secret_key'),
        ])
            ->timeout(\App\Models\Provider::query()->where('slug', 'vtpass')->value('timeout_seconds') ?? 30)
            ->post(config('services.vtpass.base_url') . '/pay', [
                'request_id' => $reference,
                'serviceID' => $serviceId,
                'billersCode' => $phone,
                'variation_code' => $variationCode,
                'phone' => $phone,
                'amount' => $amount,
            ]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['code'] ?? null) !== '000') {
            throw new RuntimeException($body['response_description'] ?? 'VTpass data purchase failed.');
        }

        $innerStatus = $body['content']['transactions']['status'] ?? 'delivered';

        return [
            'provider_reference' => $body['content']['transactions']['transactionId'] ?? $reference,
            'status' => $innerStatus,
        ];
    }
}