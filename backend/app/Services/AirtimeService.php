<?php

namespace App\Services;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionType;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;
use Throwable;

class AirtimeService
{
    public function __construct(
        protected AirtimeProviderResolver $providerResolver,
        protected TransactionService $transactionService,
        protected WalletService $walletService,
        protected ProviderLogService $providerLogService,
        protected TransactionConfirmationService $confirmationService,
    ) {
    }

    public function purchase(User $user, string $network, string $phone, float $amount, string $pin): Transaction
    {
        $wallet = $user->wallet;

        $this->walletService->verifyPin($wallet, $pin);

        $transaction = $this->transactionService->initiate(
            user: $user,
            wallet: $wallet,
            type: TransactionType::Airtime,
            amount: $amount,
            description: "Airtime purchase - {$network} - {$phone}",
            meta: ['network' => $network, 'phone' => $phone],
        );

        // Reserve funds up front. If this throws (insufficient balance),
        // it propagates straight to the controller - no provider call is made.
        $this->walletService->debit($wallet, $amount, $transaction->reference, 'Airtime purchase', $transaction);

        $this->transactionService->markProcessing($transaction);

        $providers = $this->providerResolver->resolve();
        $lastError = null;

        foreach ($providers as $slug => $provider) {
            $startedAt = microtime(true);
            $requestPayload = ['network' => $network, 'phone' => $phone, 'amount' => $amount, 'reference' => $transaction->reference];

            try {
                $result = $provider->purchase($network, $phone, $amount, $transaction->reference);
                $status = $result['status'] ?? 'delivered';

                $this->providerLogService->log(
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
        $this->walletService->credit(
            $wallet,
            $amount,
            $transaction->reference . '-REVERSAL',
            'Reversal: airtime purchase failed on all providers',
            $transaction
        );

        $this->transactionService->markFailed($transaction, $lastError?->getMessage() ?? 'All airtime providers failed.');

        throw new RuntimeException('Airtime purchase failed. Your wallet has been refunded.');
    }
}