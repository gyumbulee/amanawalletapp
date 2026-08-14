<?php

namespace App\Services\Providers;

use App\Contracts\Providers\DataProviderInterface;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class BigiSubDataProvider implements DataProviderInterface
{
    public function listPlans(string $network): array
    {
        $response = Http::withToken(config('services.bigisub.api_key'))
            ->timeout(\App\Models\Provider::query()->where('slug', 'bigisub')->value('timeout_seconds') ?? 30)
            ->get(config('services.bigisub.base_url') . '/data/plans', ['network' => strtoupper($network)]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['status'] ?? null) !== 'success') {
            throw new RuntimeException($body['message'] ?? 'Failed to fetch BigiSub data plans.');
        }

        return array_map(fn ($plan) => [
            'variation_code' => $plan['plan_id'],
            'name' => $plan['name'],
            'amount' => (float) $plan['amount'],
        ], $body['data'] ?? []);
    }

    public function purchase(string $network, string $phone, string $variationCode, float $amount, string $reference): array
    {
        $response = Http::withToken(config('services.bigisub.api_key'))
            ->timeout(\App\Models\Provider::query()->where('slug', 'bigisub')->value('timeout_seconds') ?? 30)
            ->post(config('services.bigisub.base_url') . '/data', [
                'network' => strtoupper($network),
                'phone' => $phone,
                'plan_id' => $variationCode,
                'amount' => $amount,
                'reference' => $reference,
            ]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['status'] ?? null) !== 'success') {
            throw new RuntimeException($body['message'] ?? 'BigiSub data purchase failed.');
        }

        return [
            'provider_reference' => $body['data']['reference'] ?? $reference,
            'status' => 'delivered',
        ];
    }
}