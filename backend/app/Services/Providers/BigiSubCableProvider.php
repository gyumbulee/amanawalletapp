<?php

namespace App\Services\Providers;

use App\Contracts\Providers\CableProviderInterface;
use App\Services\Providers\Concerns\HasBigiSubClient;
use Illuminate\Support\Facades\Cache;
use RuntimeException;

class BigiSubCableProvider implements CableProviderInterface
{
    use HasBigiSubClient;

    public function listPlans(string $cableProvider): array
    {
        $cableProvider = strtolower($cableProvider);

        return Cache::remember("bigisub-cable-plans-{$cableProvider}", now()->addHours(6), function () use ($cableProvider) {
            $response = $this->bigiSubClient()
                ->get("{$this->bigiSubBaseUrl()}/vtu/cable/plans/", ['cable_name' => $cableProvider]);

            $plans = $this->bigiSubData($response, 'Failed to fetch Bigisub cable plans.');

            return collect($plans)
                ->map(fn ($plan) => [
                    'variation_code' => $plan['variation_code'],
                    'name' => $plan['product_name'],
                    'amount' => (float) $plan['amount'],
                ])
                ->values()
                ->all();
        });
    }

    public function verifySmartcard(string $cableProvider, string $smartcardNumber): array
    {
        $response = $this->bigiSubClient()->post("{$this->bigiSubBaseUrl()}/vtu/cable/verify/", [
            'cable_name' => strtolower($cableProvider),
            'card_no' => $smartcardNumber,
        ]);

        $data = $this->bigiSubData($response, 'Smartcard verification failed.');

        if (! ($data['valid'] ?? false)) {
            throw new RuntimeException('Smartcard could not be verified.');
        }

        return [
            'customer_name' => $data['customer_name'],
            'customer_number' => (string) ($data['card_number'] ?? $smartcardNumber),
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
        // Purchase's "Customer" field must match verify's returned name
        // exactly (per Bigisub's docs) - always re-verify immediately
        // before purchasing rather than trusting a name captured earlier
        // in the flow, in case it's gone stale.
        $customerName = $this->verifySmartcard($cableProvider, $smartcardNumber)['customer_name'];

        $response = $this->bigiSubClient()->post("{$this->bigiSubBaseUrl()}/vtu/cable/purchase/", [
            'cable_type' => strtolower($cableProvider),
            'card_no' => $smartcardNumber,
            'phone_number' => $phone,
            'amount' => $amount,
            'Customer' => $customerName,
            'pin' => $this->bigiSubPin(),
        ]);

        $data = $this->bigiSubData($response, 'Bigisub cable subscription failed.');

        return [
            'provider_reference' => $data['reference'] ?? $data['transaction_id'] ?? $reference,
            'status' => $this->mapBigiSubStatus($data['status'] ?? 'failed'),
            'customer_name' => $customerName,
        ];
    }
}
