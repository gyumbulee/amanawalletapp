<?php

namespace App\Jobs;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionStatus;
use App\Models\Transaction;
use App\Services\CableProviderResolver;
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

class ProcessCablePurchase implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, SerializesModels;

    public function __construct(
        public int $transactionId,
        public string $cableProvider,
        public string $smartcardNumber,
        public string $variationCode,
        public float $amount,
        public string $phone,
    ) {}

    public function handle(
        CableProviderResolver $providerResolver,
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
            $requestPayload = ['cable_provider' => $this->cableProvider, 'smartcard_number' => $this->smartcardNumber, 'variation_code' => $this->variationCode, 'amount' => $this->amount, 'reference' => $transaction->reference];

            try {
                $result = $provider->subscribe($this->cableProvider, $this->smartcardNumber, $this->variationCode, $this->amount, $this->phone, $transaction->reference);
                $status = $result['status'] ?? 'delivered';

                $providerLogService->log(
                    provider: $slug,
                    serviceType: 'cable',
                    requestReference: $transaction->reference,
                    transactionReference: $transaction->reference,
                    requestPayload: $requestPayload,
                    responsePayload: $result,
                    status: ProviderLogStatus::Success,
                    errorMessage: null,
                    durationMs: (int) ((microtime(true) - $startedAt) * 1000),
                );

                $meta = $transaction->meta ?? [];
                $meta['customer_name'] = $result['customer_name'] ?? null;
                $transaction->update(['meta' => $meta]);

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
                    serviceType: 'cable',
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
            $this->amount,
            $transaction->reference.'-REVERSAL',
            'Reversal: cable TV subscription failed on all providers',
            $transaction
        );

        $transactionService->markFailed($transaction, $lastError?->getMessage() ?? 'All cable TV providers failed.');
    }
}
