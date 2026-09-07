<?php

namespace App\Services;

use App\Models\DeviceToken;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

/**
 * Sends push notifications via Firebase Cloud Messaging's HTTP v1 API.
 *
 * FCM's old legacy API (a static "server key" in an Authorization header)
 * was shut down by Google in 2024. The v1 API requires an OAuth2 access
 * token signed by a Firebase service account instead - there's no simpler
 * "just paste a key" option any more. This class does the OAuth2 exchange
 * itself (a signed JWT -> Google's token endpoint) rather than pulling in
 * the full Google API client just for one grant type.
 */
class FcmService
{
    private const TOKEN_CACHE_KEY = 'fcm:access_token';

    /**
     * Send the same notification to every token belonging to a user.
     * Silently skips if the user has no registered devices or FCM isn't
     * configured - push is a best-effort channel, never something a
     * purchase/wallet flow should fail over.
     */
    public function sendToUser(int $userId, string $title, string $body, array $data = []): void
    {
        $tokens = DeviceToken::query()->where('user_id', $userId)->pluck('token');

        if ($tokens->isEmpty()) {
            Log::info('FCM: skipped push - user has no registered device tokens.', ['user_id' => $userId]);

            return;
        }

        foreach ($tokens as $token) {
            $this->sendToToken($token, $title, $body, $data);
        }
    }

    public function sendToToken(string $token, string $title, string $body, array $data = []): void
    {
        if (! $this->isConfigured()) {
            Log::warning('FCM: skipped push - not configured (check FCM_PROJECT_ID / FCM_CREDENTIALS_PATH in .env and that the credentials file actually exists at that path).');

            return;
        }

        try {
            $accessToken = $this->getAccessToken();
        } catch (\Throwable $e) {
            Log::error('FCM: failed to obtain access token', ['error' => $e->getMessage()]);

            return;
        }

        $projectId = config('services.fcm.project_id');

        $response = Http::withToken($accessToken)
            ->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", [
                'message' => [
                    'token' => $token,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    // All values must be strings - FCM's data payload is
                    // string-only regardless of the original PHP type.
                    'data' => array_map(fn ($value) => (string) $value, $data),
                ],
            ]);

        if ($response->successful()) {
            Log::info('FCM: push sent successfully.', ['title' => $title]);

            return;
        }

        $errorStatus = $response->json('error.status');

        // FCM reports dead tokens (uninstalled app, expired registration)
        // this way. Prune them so we stop wasting calls on them and the
        // device_tokens table doesn't accumulate garbage forever.
        if (in_array($errorStatus, ['UNREGISTERED', 'NOT_FOUND', 'INVALID_ARGUMENT'], true)) {
            Log::info('FCM: pruning dead device token.', ['status' => $errorStatus]);
            DeviceToken::query()->where('token', $token)->delete();

            return;
        }

        Log::warning('FCM: push send failed', [
            'status' => $response->status(),
            'error' => $response->json('error'),
        ]);
    }

    public function isConfigured(): bool
    {
        return filled(config('services.fcm.project_id'))
            && filled(config('services.fcm.credentials_path'))
            && file_exists(config('services.fcm.credentials_path'));
    }

    /**
     * Exchanges a service-account-signed JWT for a short-lived OAuth2
     * access token, cached for just under its 1-hour lifetime so every
     * push send doesn't re-authenticate.
     */
    private function getAccessToken(): string
    {
        return Cache::remember(self::TOKEN_CACHE_KEY, 3300, function () {
            $credentialsPath = config('services.fcm.credentials_path');

            if (! $credentialsPath || ! file_exists($credentialsPath)) {
                throw new RuntimeException('FCM credentials file not found at FCM_CREDENTIALS_PATH.');
            }

            $credentials = json_decode(file_get_contents($credentialsPath), true);

            if (! isset($credentials['client_email'], $credentials['private_key'])) {
                throw new RuntimeException('FCM credentials file is missing client_email/private_key.');
            }

            $now = time();

            $header = $this->base64UrlEncode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));

            $claims = $this->base64UrlEncode(json_encode([
                'iss' => $credentials['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600,
            ]));

            $signatureInput = "{$header}.{$claims}";

            $signature = '';
            $signed = openssl_sign($signatureInput, $signature, $credentials['private_key'], OPENSSL_ALGO_SHA256);

            if (! $signed) {
                throw new RuntimeException('Failed to sign FCM service-account JWT.');
            }

            $jwt = $signatureInput.'.'.$this->base64UrlEncode($signature);

            $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]);

            if (! $response->successful() || ! $response->json('access_token')) {
                throw new RuntimeException('Google OAuth2 token exchange failed: '.$response->body());
            }

            return $response->json('access_token');
        });
    }

    private function base64UrlEncode(string $value): string
    {
        return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
    }
}
