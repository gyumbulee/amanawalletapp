<?php

namespace App\Services\Providers;

use App\Contracts\Providers\AirtimeProviderInterface;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class BigiSubAirtimeProvider implements AirtimeProviderInterface
{
    public function purchase(string $network, string $phone, float $amount, string $reference): array
    {
        $response = Http::withToken(config('services.bigisub.api_key'))
            ->timeout(\App\Models\Provider::query()->where('slug', 'bigisub')->value('timeout_seconds') ?? 30)
            ->post(config('services.bigisub.base_url') . '/airtime', [
                'network' => strtoupper($network),
                'phone' => $phone,
                'amount' => $amount,
                'reference' => $reference,
            ]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['status'] ?? null) !== 'success') {
            throw new RuntimeException($body['message'] ?? 'BigiSub airtime purchase failed.');
        }

        return [
            'provider_reference' => $body['data']['reference'] ?? $reference,
        ];
    }
}