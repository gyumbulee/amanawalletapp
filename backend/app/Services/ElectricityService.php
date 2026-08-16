<?php

namespace App\Services;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionType;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;
use Throwable;

class ElectricityService
{
    public function __construct(
        protected ElectricityProviderResolver $providerResolver,
        protected TransactionService $transactionService,
        protected WalletService $walletService,
        protected ProviderLogService $providerLogService,
        protected TransactionConfirmationService $confirmationService,
    ) {
    }

    /**
     * Standalone verification, so the Flutter app can show "Customer: John Doe"
     * before the user confirms payment.
     */
    public function verifyMeter(string $disco, string $meterNumber, string $meterType): array
    {
        $providers = $this->providerResolver->resolve();

        if (empty($providers)) {
            throw new RuntimeException('No active electricity providers are configured.');
        }

        return reset($providers)->verifyMeter($disco, $meterNumber, $meterType);
    }

    public function purchase(User $user, string $disco, string $meterNumber, string $meterType, float $amount, string $phone, string $pin): Transaction
    {
        $wallet = $user->wallet;

        $this->walletService->verifyPin($wallet, $pin);

        $transaction = $this->transactionService->initiate(
            user: $user,
            wallet: $wallet,
            type: TransactionType::Electricity,
            amount: $amount,
            description: "Electricity payment - {$disco} - {$meterNumber}",
            meta: ['disco' => $disco, 'meter_number' => $meterNumber, 'meter_type' => $meterType, 'phone' => $phone],
        );

        $this->walletService->debit($wallet, $amount, $transaction->reference, 'Electricity payment', $transaction);
        $this->transactionService->markProcessing($transaction);

        $providers = $this->providerResolver->resolve();
        $lastError = null;

        foreach ($providers as $slug => $provider) {
            $startedAt = microtime(true);
            $requestPayload = ['disco' => $disco, 'meter_number' => $meterNumber, 'meter_type' => $meterType, 'amount' => $amount, 'reference' => $transaction->reference];

            try {
                $result = $provider->payBill($disco, $meterType, $meterNumber, $amount, $phone, $transaction->reference);
                $status = $result['status'] ?? 'delivered';

                $this->providerLogService->log(
                    provider: $slug,
                    serviceType: 'electricity',
                    requestReference: $transaction->reference,
                    transactionReference: $transaction->reference,
                    requestPayload: $requestPayload,
                    responsePayload: $result,
                    status: ProviderLogStatus::Success,
                    errorMessage: null,
                    durationMs: (int) ((microtime(true) - $startedAt) * 1000),
                );

                // Persist the token/customer name onto the transaction meta right away,
                // regardless of final delivery status, so it's never lost.
                $meta = $transaction->meta ?? [];
                $meta['token'] = $result['token'] ?? null;
                $meta['customer_name'] = $result['customer_name'] ?? null;
                $transaction->update(['meta' => $meta]);

                if ($status === 'pending') {
                    return $transaction;
                }

                if ($status !== 'delivered') {
                    throw new RuntimeException("Provider returned unexpected status: {$status}");
                }

                return $this->confirmationService->confirm(
                    $transaction->reference,
                    'delivered',
                    $result['provider_reference'] ?? null
                );
            } catch (Throwable $e) {
                $lastError = $e;

                $this->providerLogService->log(
                    provider: $slug,
                    serviceType: 'electricity',
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

        $this->walletService->credit(
            $wallet,
            $amount,
            $transaction->reference . '-REVERSAL',
            'Reversal: electricity payment failed on all providers',
            $transaction
        );

        $this->transactionService->markFailed($transaction, $lastError?->getMessage() ?? 'All electricity providers failed.');

        throw new RuntimeException('Electricity payment failed. Your wallet has been refunded.');
    }
}