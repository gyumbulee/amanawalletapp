<?php

namespace App\Services;

use App\Enums\ProviderLogStatus;
use App\Enums\TransactionType;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;
use Throwable;

class EducationService
{
    public function __construct(
        protected EducationProviderResolver $providerResolver,
        protected TransactionService $transactionService,
        protected WalletService $walletService,
        protected ProviderLogService $providerLogService,
        protected TransactionConfirmationService $confirmationService,
    ) {
    }

    public function listPlans(string $educationType): array
    {
        $providers = $this->providerResolver->resolve();

        if (empty($providers)) {
            throw new RuntimeException('No active education providers are configured.');
        }

        return reset($providers)->listPlans($educationType);
    }

    public function verifyProfile(string $educationType, string $profileId, string $variationCode): array
    {
        $providers = $this->providerResolver->resolve();

        if (empty($providers)) {
            throw new RuntimeException('No active education providers are configured.');
        }

        return reset($providers)->verifyProfile($educationType, $profileId, $variationCode);
    }

    public function purchase(User $user, string $educationType, string $variationCode, string $phone, ?string $profileId): Transaction
    {
        $wallet = $user->wallet;

        $plans = $this->listPlans($educationType);
        $plan = collect($plans)->firstWhere('variation_code', $variationCode);

        if (! $plan) {
            throw new RuntimeException('Selected education plan is not available.');
        }

        $amount = (float) $plan['amount'];

        $transaction = $this->transactionService->initiate(
            user: $user,
            wallet: $wallet,
            type: TransactionType::Education,
            amount: $amount,
            description: "Education PIN purchase - {$educationType} - {$plan['name']}",
            meta: ['education_type' => $educationType, 'variation_code' => $variationCode, 'plan_name' => $plan['name'], 'profile_id' => $profileId],
        );

        $this->walletService->debit($wallet, $amount, $transaction->reference, 'Education PIN purchase', $transaction);
        $this->transactionService->markProcessing($transaction);

        $providers = $this->providerResolver->resolve();
        $lastError = null;

        foreach ($providers as $slug => $provider) {
            $startedAt = microtime(true);
            $requestPayload = [
    'education_type' => $educationType,
    'variation_code' => $variationCode,
    'amount' => $amount,
    'phone' => $phone,
    'profile_id' => $profileId,
    'reference' => $transaction->reference,
];

            try {
                $result = $provider->purchase($educationType, $variationCode, $amount, $phone, $profileId, $transaction->reference);
                $status = $result['status'] ?? 'delivered';

                $this->providerLogService->log(
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
        serviceType: 'education',
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
            'Reversal: education PIN purchase failed on all providers',
            $transaction
        );

        $this->transactionService->markFailed($transaction, $lastError?->getMessage() ?? 'All education providers failed.');

        throw new RuntimeException('Education PIN purchase failed. Your wallet has been refunded.');
    }
}