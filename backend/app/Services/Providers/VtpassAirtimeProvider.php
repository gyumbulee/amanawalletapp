<?php

namespace App\Services\Providers;

use App\Contracts\Providers\AirtimeProviderInterface;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class VtpassAirtimeProvider implements AirtimeProviderInterface
{
    /**
     * VTpass network serviceIDs. 9mobile is historically called "etisalat" in their system.
     */
    protected const SERVICE_IDS = [
        'mtn' => 'mtn',
        'glo' => 'glo',
        'airtel' => 'airtel',
        '9mobile' => 'etisalat',
    ];

    public function purchase(string $network, string $phone, float $amount, string $reference): array
    {
        $serviceId = self::SERVICE_IDS[$network] ?? null;

        if (! $serviceId) {
            throw new RuntimeException("Unsupported network for VTpass: {$network}");
        }

        // Use OUR transaction reference as VTpass's request_id. This is what
        // VTpass echoes back in the "requestId" field of both the requery
        // response and the transaction-update webhook - it's the only way
        // to correlate an async confirmation back to our Transaction record.
        $response = Http::withHeaders([
            'api-key' => config('services.vtpass.api_key'),
            'secret-key' => config('services.vtpass.secret_key'),
        ])
            ->timeout(\App\Models\Provider::query()->where('slug', 'vtpass')->value('timeout_seconds') ?? 30)
            ->post(config('services.vtpass.base_url') . '/pay', [
                'request_id' => $reference,
                'serviceID' => $serviceId,
                'amount' => $amount,
                'phone' => $phone,
            ]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['code'] ?? null) !== '000') {
            throw new RuntimeException($body['response_description'] ?? 'VTpass airtime purchase failed.');
        }

        $innerStatus = $body['content']['transactions']['status'] ?? 'delivered';

        return [
            'provider_reference' => $body['content']['transactions']['transactionId'] ?? $reference,
            // 'delivered' = final success. 'pending' = accepted, final status
            // arrives later via the transaction-update webhook. Anything else
            // is treated as a failure by the caller.
            'status' => $innerStatus,
        ];
    }
}