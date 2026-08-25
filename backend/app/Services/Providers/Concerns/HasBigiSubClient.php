<?php

namespace App\Services\Providers\Concerns;

use App\Models\Provider;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * Confirmed against Bigisub's official v2 API docs (api.bigisub.ng),
 * checked Aug 2026:
 * - Base URL: https://api.bigisub.ng/api/v2
 * - Auth header: `Authorization: Token {token}` (Django REST Framework
 *   token auth) - NOT `Bearer`.
 * - Every response is enveloped as {"success": bool, "data": {...},
 *   "message": "..."}. The actual payload is always under "data".
 * - Every purchase call requires a `pin` field - Bigisub's own merchant
 *   transaction PIN (config('services.bigisub.pin')), separate from the
 *   end-user's Amana Wallet PIN.
 * - Status vocabulary (Standard Services): successful/completed = done;
 *   processing/submitted/pending/in_progress = still with the provider;
 *   failed/cancelled/refunded/partial = failed, Bigisub auto-refunds their
 *   side. mapStatus() below is the single source of truth for translating
 *   this into this app's delivered/pending/failed vocabulary.
 */
trait HasBigiSubClient
{
    protected function bigiSubClient(): PendingRequest
    {
        $token = config('services.bigisub.api_key');

        return Http::withHeaders([
            'Authorization' => "Token {$token}",
            'Content-Type' => 'application/json',
        ])
            ->timeout(Provider::query()->where('slug', 'bigisub')->value('timeout_seconds') ?? 30);
    }

    protected function bigiSubBaseUrl(): string
    {
        return rtrim(config('services.bigisub.base_url'), '/');
    }

    protected function bigiSubPin(): string
    {
        $pin = config('services.bigisub.pin');

        if (! $pin) {
            throw new RuntimeException('Bigisub merchant PIN is not configured (BIGISUB_PIN).');
        }

        return $pin;
    }

    /**
     * Unwraps {"success": bool, "data": {...}} and throws with whatever
     * message Bigisub sent back if success is false or the HTTP call
     * itself failed.
     *
     * @return array the inner "data" payload
     */
    protected function bigiSubData(\Illuminate\Http\Client\Response $response, string $fallbackMessage): array
    {
        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['success'] ?? false) !== true) {
            throw new RuntimeException($body['message'] ?? $body['error'] ?? $fallbackMessage);
        }

        return $body['data'] ?? [];
    }

    /**
     * Maps Bigisub's status vocabulary to this app's delivered/pending/
     * failed. Deliberately throws on anything not explicitly documented
     * rather than guessing a bucket - this only runs after Bigisub has
     * already confirmed success:true, so an unrecognized status here means
     * their API changed, not that the purchase failed; better to surface
     * that loudly than silently misclassify a real transaction.
     */
    protected function mapBigiSubStatus(string $status): string
    {
        return match ($status) {
            'successful', 'completed' => 'delivered',
            'processing', 'submitted', 'pending', 'in_progress' => 'pending',
            'failed', 'cancelled', 'refunded', 'partial' => 'failed',
            default => throw new RuntimeException("Unrecognized Bigisub status: {$status}"),
        };
    }
}
