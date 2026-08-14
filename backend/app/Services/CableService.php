<?php

namespace App\Services;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionType;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;
use Throwable;

class CableService
{
    public function __construct(
        protected CableProviderResolver $providerResolver,
        protected TransactionService $transactionService,
        protected WalletService $walletService,
        protected ProviderLogService $providerLogService,
        protected TransactionConfirmationService $confirmationService,
    ) {
    }

    public function listPlans(string $cableProvider): array
    {
        $providers = $this->providerResolver->resolve();

        if (empty($providers)) {
            throw new RuntimeException('No active cable TV providers are configured.');
        }

        return reset($providers)->listPlans($cableProvider);
    }

    public function verifySmartcard(string $cableProvider, string $smartcardNumber): array
    {
        $providers = $this->providerResolver->resolve();

        if (empty($providers)) {
            throw new RuntimeException('No active cable TV providers are configured.');
        }

        return reset($providers)->verifySmartcard($cableProvider, $smartcardNumber);
    }

    public function purchase(
        User $user,
        string $cableProvider,
        string $smartcardNumber,
        string $variationCode,
        string $phone
    ): Transaction {
        $wallet = $user->wallet;

        $plans = $this->listPlans($cableProvider);

        $plan = collect($plans)->firstWhere('variation_code', $variationCode);

        if (! $plan) {
            throw new RuntimeException('Selected cable TV bouquet is not available.');
        }

        $amount = (float) $plan['amount'];

        $transaction = $this->transactionService->initiate(
            user: $user,
            wallet: $wallet,
            type: TransactionType::Cable,
            amount: $amount,
            description: "Cable TV subscription - {$cableProvider} - {$plan['name']} - {$smartcardNumber}",
            meta: [
                'cable_provider' => $cableProvider,
                'smartcard_number' => $smartcardNumber,
                'variation_code' => $variationCode,
                'plan_name' => $plan['name'],
            ],
        );

        $this->walletService->debit(
            $wallet,
            $amount,
            $transaction->reference,
            'Cable TV subscription',
            $transaction
        );

        $this->transactionService->markProcessing($transaction);

        $providers = $this->providerResolver->resolve();

        $lastError = null;

        try {

            foreach ($providers as $slug => $provider) {

                $startedAt = microtime(true);

                $requestPayload = [
                    'cable_provider' => $cableProvider,
                    'smartcard_number' => $smartcardNumber,
                    'variation_code' => $variationCode,
                    'amount' => $amount,
                    'reference' => $transaction->reference,
                ];

                try {

                    $result = $provider->subscribe(
                        $cableProvider,
                        $smartcardNumber,
                        $variationCode,
                        $amount,
                        $phone,
                        $transaction->reference
                    );

                    $status = strtolower($result['status'] ?? 'delivered');

                    $this->providerLogService->log(
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

                    switch ($status) {

                        case 'delivered':
                        case 'success':
                        case 'successful':

                            $transaction->update([
                                'provider' => $slug,
                            ]);

                            return $this->confirmationService->confirm(
                                $transaction->reference,
                                'delivered',
                                $result['provider_reference'] ?? null
                            );

                        case 'pending':

                            $transaction->update([
                                'provider' => $slug,
                            ]);

                            return $transaction;

                        default:

                            throw new RuntimeException(
                                "Provider returned unexpected status: {$status}"
                            );
                    }

                } catch (Throwable $e) {

                    $lastError = $e;

                    $this->providerLogService->log(
                        provider: $slug,
                        serviceType: 'cable',
                        requestReference: $transaction->reference,
                        transactionReference: $transaction->reference,
                        requestPayload: $requestPayload,
                        responsePayload: method_exists($e, 'response')
                            ? $e->response?->json()
                            : null,
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
                'Reversal: cable TV subscription failed on all providers',
                $transaction
            );

            $this->transactionService->markFailed(
                $transaction,
                $lastError?->getMessage() ?? 'All cable TV providers failed.'
            );

            throw new RuntimeException(
                'Cable TV subscription failed. Your wallet has been refunded.'
            );

        } finally {

            $transaction->refresh();

            if ($transaction->status === 'processing') {

                $this->walletService->credit(
                    $wallet,
                    $amount,
                    $transaction->reference . '-AUTO-REVERSAL',
                    'Automatic reversal after interrupted cable purchase',
                    $transaction
                );

                $this->transactionService->markFailed(
                    $transaction,
                    'Interrupted while contacting provider.'
                );
            }
        }
    }
}