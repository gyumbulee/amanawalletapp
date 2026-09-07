<?php

namespace App\Jobs;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionStatus;
use App\Models\Transaction;
use App\Services\DataProviderResolver;
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

class ProcessDataPurchase implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, SerializesModels;

    public function __construct(
        public int $transactionId,
        public string $network,
        public string $phone,
        public string $variationCode,
        // What the customer paid (sellingPrice) is reserved from their
        // wallet in DataService - this is deliberately the provider's own
        // cost price instead, since sending the marked-up amount would
        // fail BigiSub's validation for this plan_id (or eat our margin).
        public float $costPrice,
        public float $sellingPrice,
    ) {}

    public function handle(
        DataProviderResolver $providerResolver,
        TransactionService $transactionService,
        WalletService $walletService,
        ProviderLogService $providerLogService,
        TransactionConfirmationService $confirmationService,
    ): void {
        $transaction = Transaction::query()->find($this->transactionId);

        if (! $transaction || $transaction->status !== TransactionStatus::Processing) {
            return;
        }

        $wallet = $transaction->wallet;
        $providers = $providerResolver->resolve();
        $lastError = null;

        foreach ($providers as $slug => $provider) {
            $startedAt = microtime(true);
            $requestPayload = ['network' => $this->network, 'phone' => $this->phone, 'variation_code' => $this->variationCode, 'amount' => $this->costPrice, 'reference' => $transaction->reference];

            try {
                $result = $provider->purchase($this->network, $this->phone, $this->variationCode, $this->costPrice, $transaction->reference);
                $status = $result['status'] ?? 'delivered';

                $providerLogService->log(
                    provider: $slug,
                    serviceType: 'data',
                    requestReference: $transaction->reference,
                    transactionReference: $transaction->reference,
                    requestPayload: $requestPayload,
                    responsePayload: $result,
                    status: ProviderLogStatus::Success,
                    errorMessage: null,
                    durationMs: (int) ((microtime(true) - $startedAt) * 1000),
                );

                if ($status === 'pending') {
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
                    serviceType: 'data',
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

        $walletService->credit(
            $wallet,
            $this->sellingPrice,
            $transaction->reference.'-REVERSAL',
            'Reversal: data purchase failed on all providers',
            $transaction
        );

        $transactionService->markFailed($transaction, $lastError?->getMessage() ?? 'All data providers failed.');
    }
}
