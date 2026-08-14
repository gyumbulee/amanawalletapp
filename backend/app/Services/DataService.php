<?php

namespace App\Services;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionType;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;
use Throwable;

class DataService
{
    public function __construct(
        protected DataProviderResolver $providerResolver,
        protected TransactionService $transactionService,
        protected WalletService $walletService,
        protected ProviderLogService $providerLogService,
        protected TransactionConfirmationService $confirmationService,
    ) {
    }

    public function listPlans(string $network): array
    {
        $providers = $this->providerResolver->resolve();

        if (empty($providers)) {
            throw new RuntimeException('No active data providers are configured.');
        }

        // Use the first (highest-priority) active provider for the plan catalogue.
        return reset($providers)->listPlans($network);
    }

    public function purchase(User $user, string $network, string $phone, string $variationCode): Transaction
    {
        $wallet = $user->wallet;

        // Look up the authoritative price server-side - never trust a client-sent amount.
        $plans = $this->listPlans($network);
        $plan = collect($plans)->firstWhere('variation_code', $variationCode);

        if (! $plan) {
            throw new RuntimeException('Selected data plan is not available.');
        }

        $amount = (float) $plan['amount'];

        $transaction = $this->transactionService->initiate(
            user: $user,
            wallet: $wallet,
            type: TransactionType::Data,
            amount: $amount,
            description: "Data purchase - {$network} - {$plan['name']} - {$phone}",
            meta: ['network' => $network, 'phone' => $phone, 'variation_code' => $variationCode, 'plan_name' => $plan['name']],
        );

        $this->walletService->debit($wallet, $amount, $transaction->reference, 'Data purchase', $transaction);
        $this->transactionService->markProcessing($transaction);

        $providers = $this->providerResolver->resolve();
        $lastError = null;

        foreach ($providers as $slug => $provider) {
            $startedAt = microtime(true);
            $requestPayload = ['network' => $network, 'phone' => $phone, 'variation_code' => $variationCode, 'amount' => $amount, 'reference' => $transaction->reference];

            try {
                $result = $provider->purchase($network, $phone, $variationCode, $amount, $transaction->reference);
                $status = $result['status'] ?? 'delivered';

                $this->providerLogService->log(
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

        $this->walletService->credit(
            $wallet,
            $amount,
            $transaction->reference . '-REVERSAL',
            'Reversal: data purchase failed on all providers',
            $transaction
        );

        $this->transactionService->markFailed($transaction, $lastError?->getMessage() ?? 'All data providers failed.');

        throw new RuntimeException('Data purchase failed. Your wallet has been refunded.');
    }
}