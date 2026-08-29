<?php

namespace App\Http\Middleware;

use App\Models\IdempotencyKey;
use Closure;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

/**
 * Protects purchase-type endpoints against duplicate execution when a
 * client never receives the response (dropped connection, app killed
 * mid-request, user impatiently retapping "Confirm", etc).
 *
 * Client sends a unique `Idempotency-Key` header, generated once per
 * purchase attempt and reused on any retry of that *same* attempt.
 * The server:
 *   - First time seeing a key: claims it, runs the request normally,
 *     stores the final response.
 *   - Sees it again with a completed record: replays the stored
 *     response instead of re-running the purchase (no second debit).
 *   - Sees it again while still "processing" (a near-simultaneous
 *     duplicate, e.g. double-tap): rejects with 409 rather than racing.
 *   - Sees it reused with a *different* request body: rejects with 422
 *     - a key must always mean the same request.
 *   - A "processing" record older than STALE_AFTER_SECONDS is treated
 *     as an abandoned/crashed attempt and reclaimed.
 */
class EnsureIdempotency
{
    private const STALE_AFTER_SECONDS = 90;

    public function handle(Request $request, Closure $next): Response
    {
        $key = $request->header('Idempotency-Key');

        if (! $key) {
            return response()->json([
                'message' => 'Idempotency-Key header is required for this request.',
            ], 400);
        }

        $userId = $request->user()->id;
        $route = $request->route()?->getName() ?? $request->path();
        $requestHash = hash('sha256', $request->getContent());

        $existing = IdempotencyKey::query()
            ->where('user_id', $userId)
            ->where('route', $route)
            ->where('key', $key)
            ->first();

        if ($existing) {
            if ($existing->request_hash !== $requestHash) {
                return response()->json([
                    'message' => 'This Idempotency-Key was already used with a different request.',
                ], 422);
            }

            if ($existing->status === 'completed') {
                return response()
                    ->json(json_decode($existing->response_body, true), $existing->response_status)
                    ->header('Idempotent-Replay', 'true');
            }

            // Still "processing" - either a genuine concurrent duplicate,
            // or a previous attempt that died without finishing.
            if ($existing->updated_at->diffInSeconds(now()) < self::STALE_AFTER_SECONDS) {
                return response()->json([
                    'message' => 'This request is already being processed. Please wait.',
                ], 409);
            }

            Log::warning('Reclaiming stale idempotency key', ['key' => $key, 'route' => $route, 'user_id' => $userId]);
            $existing->delete();
        }

        try {
            $record = IdempotencyKey::query()->create([
                'user_id' => $userId,
                'route' => $route,
                'key' => $key,
                'request_hash' => $requestHash,
                'status' => 'processing',
            ]);
        } catch (QueryException $e) {
            // Lost a race against a near-simultaneous identical request.
            return response()->json([
                'message' => 'This request is already being processed. Please wait.',
            ], 409);
        }

        $response = $next($request);

        $record->update([
            'status' => 'completed',
            'response_status' => $response->getStatusCode(),
            'response_body' => $response->getContent(),
        ]);

        return $response;
    }
}
