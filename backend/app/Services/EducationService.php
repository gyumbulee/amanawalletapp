<?php

namespace App\Services;

use App\Enums\TransactionType;
use App\Jobs\ProcessEducationPurchase;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;

class EducationService
{
    public function __construct(
        protected EducationProviderResolver $providerResolver,
        protected TransactionService $transactionService,
        protected WalletService $walletService,
    ) {}

    public function listPlans(string $educationType): array
    {
        $providers = $this->providerResolver->resolve();

        if (empty($providers)) {
            throw new RuntimeException('No active education providers are configured.');
        }

        return reset($providers)->listPlans($educationType);
    }

    public function verifyProfile(string $educationType, string $profileId): array
    {
        $providers = $this->providerResolver->resolve();

        if (empty($providers)) {
            throw new RuntimeException('No active education providers are configured.');
        }

        return reset($providers)->verifyProfile($educationType, $profileId);
    }

    public function purchase(User $user, string $educationType, string $variationCode, string $phone, ?string $profileId, string $pin): Transaction
    {
        $wallet = $user->wallet;

        $this->walletService->verifyPin($wallet, $pin);

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

        ProcessEducationPurchase::dispatch($transaction->id, $educationType, $variationCode, $amount, $phone, $profileId);

        return $transaction;
    }
}
