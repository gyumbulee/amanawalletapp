<?php

namespace App\Services\Providers;

use App\Models\Provider;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * VTpass does not sign its transaction-status webhook (no equivalent of
 * Flutterwave's verif-hash header). Anyone who discovers the callback URL
 * could POST a forged payload - e.g. claiming a real pending transaction
 * "failed" to trigger a fraudulent wallet refund.
 *
 * To close that gap, we never act on the webhook body directly. Instead we
 * requery VTpass server-to-server using the request_id from the payload and
 * only trust that response. This mirrors VTpass's own documented best
 * practice for confirming transaction status.
 */
class VtpassRequeryService
{
    /**
     * @return array{status: ?string, provider_reference: ?string}
     */
    public function requery(string $requestId): array
    {
        $response = Http::withHeaders([
            'api-key' => config('services.vtpass.api_key'),
            'secret-key' => config('services.vtpass.secret_key'),
        ])
            ->timeout(Provider::query()->where('slug', 'vtpass')->value('timeout_seconds') ?? 30)
            ->post(config('services.vtpass.base_url') . '/requery', [
                'request_id' => $requestId,
            ]);

        $body = $response->json() ?? [];

        if (! $response->successful()) {
            throw new RuntimeException($body['response_description'] ?? 'VTpass requery request failed.');
        }

        return [
            'status' => $body['content']['transactions']['status'] ?? null,
            'provider_reference' => $body['content']['transactions']['transactionId'] ?? null,
        ];
    }
}
