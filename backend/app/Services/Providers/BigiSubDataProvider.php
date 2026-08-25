<?php

namespace App\Services\Providers;

use App\Contracts\Providers\DataProviderInterface;
use App\Services\Providers\Concerns\HasBigiSubClient;
use Illuminate\Support\Facades\Cache;
use RuntimeException;

class BigiSubDataProvider implements DataProviderInterface
{
    use HasBigiSubClient;

    // Confirmed from Bigisub's v2 "Buy Data" docs page.
    protected const NETWORK_CODES = [
        'mtn' => 1,
        'glo' => 2,
        'airtel' => 3,
        '9mobile' => 4,
    ];

    public function listPlans(string $network): array
    {
        $networkCode = self::NETWORK_CODES[strtolower($network)] ?? null;

        if (! $networkCode) {
            throw new RuntimeException("Unsupported network for Bigisub data: {$network}");
        }

        return Cache::remember("bigisub-data-plans-{$networkCode}", now()->addHours(6), function () use ($networkCode) {
            $response = $this->bigiSubClient()
                ->get("{$this->bigiSubBaseUrl()}/vtu/data/plans/", ['network' => $networkCode]);

            $plans = $this->bigiSubData($response, 'Failed to fetch Bigisub data plans.');

            return collect($plans)
                ->reject(fn ($plan) => $plan['plan_disabled'] ?? false)
                ->map(fn ($plan) => [
                    'variation_code' => (string) $plan['id'],
                    'name' => "{$plan['size']} {$plan['plantype']} - {$plan['validity']}",
                    // 'amount' is Bigisub's reseller/discounted price (what we
                    // actually pay) - distinct from 'plan_amount' (their
                    // displayed retail price) and 'corporate_amount' (a
                    // cheaper tier this app isn't set up for). Matches the
                    // same role VTpass's 'variation_amount' plays.
                    'amount' => (float) $plan['amount'],
                ])
                ->values()
                ->all();
        });
    }

    public function purchase(string $network, string $phone, string $variationCode, float $amount, string $reference): array
    {
        $networkCode = self::NETWORK_CODES[strtolower($network)] ?? null;

        if (! $networkCode) {
            throw new RuntimeException("Unsupported network for Bigisub data: {$network}");
        }

        $response = $this->bigiSubClient()->post("{$this->bigiSubBaseUrl()}/vtu/data/purchase/", [
            'network' => $networkCode,
            'plan' => (int) $variationCode,
            'phone_number' => $phone,
            'pin' => $this->bigiSubPin(),
            'ported_number' => true,
        ]);

        $data = $this->bigiSubData($response, 'Bigisub data purchase failed.');

        return [
            'provider_reference' => $data['reference'] ?? $data['transaction_id'] ?? $reference,
            'status' => $this->mapBigiSubStatus($data['status'] ?? 'failed'),
        ];
    }
}
