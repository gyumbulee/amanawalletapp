<?php

namespace App\Services\Providers;

use App\Contracts\Providers\VirtualAccountProviderInterface;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use RuntimeException;

class FlutterwaveProvider implements VirtualAccountProviderInterface
{
    public function createDedicatedVirtualAccount(User $user): array
    {
        Log::info('Creating Flutterwave VA', [
            'user_id' => $user->id,
            'email' => $user->email,
            'bvn' => $user->bvn,
        ]);

        $timeout = \App\Models\Provider::query()
            ->where('slug', 'flutterwave')
            ->value('timeout_seconds') ?? 30;

        $response = Http::connectTimeout(5)
            ->timeout($timeout)
            ->acceptJson()
            ->withToken(config('services.flutterwave.secret_key'))
            ->post(
                config('services.flutterwave.base_url') . '/virtual-account-numbers',
                [
                    'email' => $user->email,
                    'bvn' => $user->bvn,
                    'tx_ref' => 'VA-' . $user->uuid . '-' . Str::random(6),
                    'phonenumber' => $user->phone,
                    'firstname' => $user->first_name,
                    'lastname' => $user->last_name,
                    'narration' => $user->first_name . ' ' . $user->last_name . ' - Amana Wallet',
                    'is_permanent' => true,
                ]
            );

        Log::info('Flutterwave response', [
            'status' => $response->status(),
            'body' => $response->body(),
        ]);

        $body = $response->json() ?? [];

        if (! $response->successful() || ($body['status'] ?? null) !== 'success') {
            throw new RuntimeException(
                $body['message'] ?? 'Failed to create virtual account with Flutterwave.'
            );
        }

        $data = $body['data'] ?? [];

        return [
            'account_number' => $data['account_number'] ?? '',
            'account_name' => $data['account_name']
                ?? ($user->first_name . ' ' . $user->last_name),
            'bank_name' => $data['bank_name'] ?? '',
            'reference' => $data['order_ref'] ?? $data['flw_ref'] ?? '',
        ];
    }

    public function verifyWebhookSignature(string $signature): bool
    {
        $expected = config('services.flutterwave.webhook_secret_hash');

        if (! $expected || ! $signature) {
            return false;
        }

        return hash_equals((string) $expected, $signature);
    }
}