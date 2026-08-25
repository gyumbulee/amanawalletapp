<?php

namespace App\Services\Providers;

use App\Contracts\Providers\AirtimeProviderInterface;
use App\Services\Providers\Concerns\HasBigiSubClient;
use RuntimeException;

/**
 * NOT VERIFIED against Bigisub's v2 API and NOT currently used - Airtime
 * is routed to VTpass strictly (see AirtimeProviderResolver). This class
 * still reflects an earlier, unconfirmed guess at the endpoint shape and
 * will not work correctly against the confirmed v2 base URL/envelope used
 * by the other Bigisub providers. Confirm the real
 * GET/POST /vtu/airtime/... endpoint against api.bigisub.ng before ever
 * re-enabling Bigisub as an Airtime provider.
 */
class BigiSubAirtimeProvider implements AirtimeProviderInterface
{
    use HasBigiSubClient;

    protected const NETWORK_CODES = [
        'mtn' => 1,
        'glo' => 2,
        '9mobile' => 3,
        'airtel' => 4,
    ];

    public function purchase(string $network, string $phone, float $amount, string $reference): array
    {
        $networkCode = self::NETWORK_CODES[strtolower($network)] ?? null;

        if (! $networkCode) {
            throw new RuntimeException("Unsupported network for Bigisub airtime: {$network}");
        }

        $response = $this->bigiSubClient()->post("{$this->bigiSubBaseUrl()}/airtime_topup/", [
            'network' => $networkCode,
            'amount' => (string) $amount,
            'phone_number' => $phone,
            'airtime_type' => 'vtu',
        ]);

        $body = $response->json() ?? [];
        $this->assertBigiSubSuccess($body, $response->successful(), 'Bigisub airtime purchase failed.');

        return [
            'provider_reference' => $body['tran_id'] ?? $reference,
        ];
    }
}
