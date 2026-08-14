<?php

namespace App\Services\Providers;

use App\Contracts\Providers\EpinsProviderInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class EpinsProvider implements EpinsProviderInterface
{
    public function generateCards(string $network, float $denomination, int $quantity): array
    {
        $url = rtrim(config('services.epins.base_url'), '/') . '/epins/generate';

        Log::info('EPINS Request', [
            'url' => $url,
            'network' => strtoupper($network),
            'denomination' => $denomination,
            'quantity' => $quantity,
            'api_key_present' => ! empty(config('services.epins.api_key')),
        ]);

        $timeout = \App\Models\Provider::query()
            ->where('slug', 'epins')
            ->value('timeout_seconds') ?? 30;

        $response = Http::withToken(config('services.epins.api_key'))
            ->acceptJson()
            ->timeout($timeout)
            ->post($url, [
                'network' => strtoupper($network),
                'denomination' => $denomination,
                'quantity' => $quantity,
            ]);

        Log::info('EPINS Response', [
            'status' => $response->status(),
            'headers' => $response->headers(),
            'body' => $response->body(),
            'json' => $response->json(),
        ]);

        $body = $response->json() ?? [];

        if (! $response->successful()) {
            throw new RuntimeException(
                sprintf(
                    'HTTP %d: %s',
                    $response->status(),
                    $response->body()
                )
            );
        }

        if (($body['status'] ?? null) !== 'success') {
            throw new RuntimeException(
                $body['message']
                    ?? json_encode($body, JSON_PRETTY_PRINT)
                    ?? 'ePINs card generation failed.'
            );
        }

        return array_map(fn ($card) => [
            'serial_number' => $card['serial_number'],
            'pin' => $card['pin'],
        ], $body['data']['cards'] ?? []);
    }
}