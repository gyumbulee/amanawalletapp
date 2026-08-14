<?php

namespace App\Services\Providers;

use App\Contracts\Providers\ElectricityProviderInterface;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class BigiSubElectricityProvider implements ElectricityProviderInterface
{
    public function verifyMeter(string $disco, string $meterNumber, string $meterType): array
    {
        $response = Http::withToken(config('services.bigisub.api_key'))
            ->timeout(\App\Models\Provider::query()->where('slug', 'bigisub')->value('timeout_seconds') ?? 30)
            ->post(config('services.bigisub.base_url') . '/electricity/verify', [
                'disco' => $disco,
                'meter_number' => $meterNumber,
                'meter_type' => $meterType,
            ]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['status'] ?? null) !== 'success') {
            throw new RuntimeException($body['message'] ?? 'Meter number verification failed.');
        }

        return [
            'customer_name' => $body['data']['customer_name'] ?? 'Unknown',
            'customer_address' => $body['data']['address'] ?? null,
        ];
    }

    public function payBill(string $disco, string $meterType, string $meterNumber, float $amount, string $phone, string $reference): array
    {
        $verification = $this->verifyMeter($disco, $meterNumber, $meterType);

        $response = Http::withToken(config('services.bigisub.api_key'))
            ->timeout(\App\Models\Provider::query()->where('slug', 'bigisub')->value('timeout_seconds') ?? 30)
            ->post(config('services.bigisub.base_url') . '/electricity/pay', [
                'disco' => $disco,
                'meter_number' => $meterNumber,
                'meter_type' => $meterType,
                'amount' => $amount,
                'phone' => $phone,
                'reference' => $reference,
            ]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['status'] ?? null) !== 'success') {
            throw new RuntimeException($body['message'] ?? 'BigiSub electricity payment failed.');
        }

        return [
            'provider_reference' => $body['data']['reference'] ?? $reference,
            'status' => 'delivered',
            'token' => $body['data']['token'] ?? null,
            'customer_name' => $verification['customer_name'],
        ];
    }
}