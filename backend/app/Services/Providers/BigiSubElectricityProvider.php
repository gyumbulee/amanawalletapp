<?php

namespace App\Services\Providers;

use App\Contracts\Providers\ElectricityProviderInterface;
use App\Services\Providers\Concerns\HasBigiSubClient;

class BigiSubElectricityProvider implements ElectricityProviderInterface
{
    use HasBigiSubClient;

    /**
     * $disco is passed straight through as `company` - this app already
     * uses the same kebab-case disco slugs (e.g. 'ikeja-electric') that
     * Bigisub's own GET /bills/electricity/providers/ endpoint documents,
     * so no translation table is needed.
     */
    public function verifyMeter(string $disco, string $meterNumber, string $meterType): array
    {
        $response = $this->bigiSubClient()->post("{$this->bigiSubBaseUrl()}/bills/electricity/verify/", [
            'company' => $disco,
            'meter_no' => $meterNumber,
            'meter_type' => $meterType,
        ]);

        $data = $this->bigiSubData($response, 'Meter number verification failed.');

        return [
            'customer_name' => $data['customer_name'],
            'customer_address' => $data['customer_address'] ?? null,
        ];
    }

    public function payBill(string $disco, string $meterType, string $meterNumber, float $amount, string $phone, string $reference): array
    {
        // Pay's "Customer_name" field must match verify's returned name -
        // same reasoning as cable's "Customer" field: always re-verify
        // immediately before paying rather than trusting an earlier value.
        $verification = $this->verifyMeter($disco, $meterNumber, $meterType);

        $response = $this->bigiSubClient()->post("{$this->bigiSubBaseUrl()}/bills/electricity/pay/", [
            'company' => $disco,
            'meter_no' => $meterNumber,
            'meter_type' => $meterType,
            'phone_number' => $phone,
            'amount' => $amount,
            'Customer_name' => $verification['customer_name'],
            'pin' => $this->bigiSubPin(),
        ]);

        $data = $this->bigiSubData($response, 'Bigisub electricity payment failed.');

        return [
            'provider_reference' => $data['reference'] ?? $data['transaction_id'] ?? $reference,
            'status' => $this->mapBigiSubStatus($data['status'] ?? 'failed'),
            'token' => $data['token'] ?? null,
            'units' => $data['units'] ?? null,
            'customer_name' => $verification['customer_name'],
        ];
    }
}
