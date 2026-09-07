<?php

namespace App\Jobs;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionStatus;
use App\Models\Transaction;
use App\Services\AirtimeProviderResolver;
use App\Services\ProviderLogService;
use App\Services\TransactionConfirmationService;
use App\Services\TransactionService;
use App\Services\WalletService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use RuntimeException;
use Throwable;

class ProcessAirtimePurchase implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, SerializesModels;

    public function __construct(
        public int $transactionId,
        public string $network,
        public string $phone,
        public float $amount,
    ) {}

    public function handle(
        AirtimeProviderResolver $providerResolver,
        TransactionService $transactionService,
        WalletService $walletService,
        ProviderLogService $providerLogService,
        TransactionConfirmationService $confirmationService,
    ): void {
        $transaction = Transaction::query()->find($this->transactionId);

        // Gone, or already resolved by something else (e.g. a webhook that
        // beat this job to it) — nothing left to do. Guards against double
        // -processing if this job ever got dispatched/retried twice.
        if (! $transaction || $transaction->status !== TransactionStatus::Processing) {
            return;
        }

        $wallet = $transaction->wallet;
        $providers = $providerResolver->resolve();
        $lastError = null;

        foreach ($providers as $slug => $provider) {
            $startedAt = microtime(true);
            $requestPayload = ['network' => $this->network, 'phone' => $this->phone, 'amount' => $this->amount, 'reference' => $transaction->reference];

            try {
                $result = $provider->purchase($this->network, $this->phone, $this->amount, $transaction->reference);
                $status = $result['status'] ?? 'delivered';

                $providerLogService->log(
                    provider: $slug,
                    serviceType: 'airtime',
                    requestReference: $transaction->reference,
                    transactionReference: $transaction->reference,
                    requestPayload: $requestPayload,
                    responsePayload: $result,
                    status: ProviderLogStatus::Success,
                    errorMessage: null,
                    durationMs: (int) ((microtime(true) - $startedAt) * 1000),
                );

                if ($status === 'pending') {
                    // Accepted by the provider, final outcome arrives via webhook.
                    // Leave the transaction as "processing" - do not try a fallback provider.
                    return;
                }

                if ($status !== 'delivered') {
                    throw new RuntimeException("Provider returned unexpected status: {$status}");
                }

                $confirmationService->confirm($transaction->reference, 'delivered', $result['provider_reference'] ?? null);

                return;
            } catch (Throwable $e) {
                $lastError = $e;

                $providerLogService->log(
                    provider: $slug,
                    serviceType: 'airtime',
                    requestReference: $transaction->reference,
                    transactionReference: $transaction->reference,
                    requestPayload: $requestPayload,
                    responsePayload: null,
                    status: ProviderLogStatus::Failed,
                    errorMessage: $e->getMessage(),
                    durationMs: (int) ((microtime(true) - $startedAt) * 1000),
                );

                continue;
            }
        }

        // All providers failed - reverse the reserved funds and fail the transaction.
        $walletService->credit(
            $wallet,
            $this->amount,
            $transaction->reference.'-REVERSAL',
            'Reversal: airtime purchase failed on all providers',
            $transaction
        );

        $transactionService->markFailed($transaction, $lastError?->getMessage() ?? 'All airtime providers failed.');
    }
}
