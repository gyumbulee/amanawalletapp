<?php

namespace App\Services\Providers;

use App\Contracts\Providers\ElectricityProviderInterface;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class VtpassElectricityProvider implements ElectricityProviderInterface
{
    public function verifyMeter(string $disco, string $meterNumber, string $meterType): array
    {
        $response = Http::withHeaders([
            'api-key' => config('services.vtpass.api_key'),
            'secret-key' => config('services.vtpass.secret_key'),
        ])
            ->timeout(\App\Models\Provider::query()->where('slug', 'vtpass')->value('timeout_seconds') ?? 30)
            ->post(config('services.vtpass.base_url') . '/merchant-verify', [
                'billersCode' => $meterNumber,
                'serviceID' => $disco,
                'type' => $meterType,
            ]);

        $body = $response->json() ?? [];
        $content = $body['content'] ?? [];

        if (! $response->successful() || ($content['error'] ?? null) || empty($content['Customer_Name'] ?? $content['customer_name'] ?? null)) {
            throw new RuntimeException($content['error'] ?? 'Meter number verification failed.');
        }

        return [
            'customer_name' => $content['Customer_Name'] ?? $content['customer_name'] ?? 'Unknown',
            'customer_address' => $content['Address'] ?? $content['address'] ?? null,
        ];
    }

    public function payBill(string $disco, string $meterType, string $meterNumber, float $amount, string $phone, string $reference): array
    {
        // VTpass explicitly requires meter validation before every purchase.
        $verification = $this->verifyMeter($disco, $meterNumber, $meterType);

        $response = Http::withHeaders([
            'api-key' => config('services.vtpass.api_key'),
            'secret-key' => config('services.vtpass.secret_key'),
        ])
            ->timeout(\App\Models\Provider::query()->where('slug', 'vtpass')->value('timeout_seconds') ?? 30)
            ->post(config('services.vtpass.base_url') . '/pay', [
                'request_id' => $reference,
                'serviceID' => $disco,
                'billersCode' => $meterNumber,
                'variation_code' => $meterType,
                'amount' => $amount,
                'phone' => $phone,
            ]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['code'] ?? null) !== '000') {
            throw new RuntimeException($body['response_description'] ?? 'VTpass electricity payment failed.');
        }

        $innerStatus = $body['content']['transactions']['status'] ?? 'delivered';

        return [
            'provider_reference' => $body['content']['transactions']['transactionId'] ?? $reference,
            'status' => $innerStatus,
            'token' => $body['purchased_code'] ?? $body['token'] ?? null,
            'customer_name' => $verification['customer_name'],
        ];
    }
}