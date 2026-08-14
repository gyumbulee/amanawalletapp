<?php

namespace App\Jobs;

use App\Enums\TransactionType;
use App\Enums\WebhookStatus;
use App\Models\WalletLedger;
use App\Models\Webhook;
use App\Repositories\Interfaces\UserRepositoryInterface;
use App\Services\TransactionService;
use App\Services\WalletService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Throwable;

class ProcessFlutterwaveWebhook implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, SerializesModels;

    public function __construct(public int $webhookId)
    {
    }

    public function handle(
        UserRepositoryInterface $userRepository,
        WalletService $walletService,
        TransactionService $transactionService
    ): void {
        $webhook = Webhook::query()->find($this->webhookId);

        if (! $webhook) {
            return;
        }

        try {
            $payload = $webhook->payload;
            $event = $payload['event'] ?? null;
            $data = $payload['data'] ?? [];

            if ($event === 'charge.completed' && ($data['status'] ?? null) === 'successful' && ($data['payment_type'] ?? null) === 'bank_transfer') {
                $email = $data['customer']['email'] ?? null;
                // flw_ref is the unique per-transaction reference. tx_ref is reused
                // across all transfers into the same dedicated virtual account, so it
                // cannot be used as the ledger idempotency key.
                $providerReference = $data['flw_ref'] ?? (string) ($data['id'] ?? '');
                $amount = (float) ($data['amount'] ?? 0);

                if (! $email || ! $providerReference || $amount <= 0) {
                    throw new \RuntimeException('Webhook payload missing required fields (customer.email/flw_ref/amount).');
                }

                // Idempotency guard: never double-credit for the same provider reference.
                if (! WalletLedger::query()->where('reference', $providerReference)->exists()) {
                    $user = $userRepository->findByEmail($email);

                    if (! $user || ! $user->wallet) {
                        throw new \RuntimeException("No user/wallet found for email: {$email}");
                    }

                    $transaction = $transactionService->initiate(
                        user: $user,
                        wallet: $user->wallet,
                        type: TransactionType::WalletFunding,
                        amount: $amount,
                        description: 'Wallet funding via Flutterwave virtual account',
                        meta: [
                            'provider_reference' => $providerReference,
                            'tx_ref' => $data['tx_ref'] ?? null,
                        ],
                        provider: 'flutterwave',
                    );

                    try {
                        $walletService->credit(
                            $user->wallet,
                            $amount,
                            $providerReference,
                            'Wallet funding via Flutterwave virtual account',
                            $transaction
                        );

                        $transactionService->markSuccessful($transaction, $providerReference);
                    } catch (Throwable $e) {
                        $transactionService->markFailed($transaction, $e->getMessage());

                        throw $e;
                    }
                }
            }

            $webhook->update([
                'status' => WebhookStatus::Processed,
                'processed_at' => now(),
            ]);
        } catch (Throwable $e) {
            Log::error('Flutterwave webhook processing failed', [
                'webhook_id' => $webhook->id,
                'error' => $e->getMessage(),
            ]);

            $webhook->update(['status' => WebhookStatus::Failed]);
        }
    }
}