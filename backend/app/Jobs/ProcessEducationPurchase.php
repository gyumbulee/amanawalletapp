<?php

namespace App\Jobs;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionStatus;
use App\Models\Transaction;
use App\Services\EducationProviderResolver;
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

class ProcessEducationPurchase implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, SerializesModels;

    public function __construct(
        public int $transactionId,
        public string $educationType,
        public string $variationCode,
        public float $amount,
        public string $phone,
        public ?string $profileId,
    ) {}

    public function handle(
        EducationProviderResolver $providerResolver,
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
            $requestPayload = ['education_type' => $this->educationType, 'variation_code' => $this->variationCode, 'amount' => $this->amount, 'phone' => $this->phone, 'reference' => $transaction->reference];

            try {
                $result = $provider->purchase($this->educationType, $this->variationCode, $this->amount, $this->phone, $this->profileId, $transaction->reference);
                $status = $result['status'] ?? 'delivered';

                $providerLogService->log(
                    provider: $slug,
                    serviceType: 'education',
                    requestReference: $transaction->reference,
                    transactionReference: $transaction->reference,
                    requestPayload: $requestPayload,
                    responsePayload: $result,
                    status: ProviderLogStatus::Success,
                    errorMessage: null,
                    durationMs: (int) ((microtime(true) - $startedAt) * 1000),
                );

                $meta = $transaction->meta ?? [];
                $meta['pin'] = $result['pin'] ?? null;
                $meta['serial'] = $result['serial'] ?? null;
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
                    serviceType: 'education',
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
            'Reversal: education PIN purchase failed on all providers',
            $transaction
        );

        $transactionService->markFailed($transaction, $lastError?->getMessage() ?? 'All education providers failed.');
    }
}
