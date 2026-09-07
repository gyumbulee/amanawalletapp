<?php

namespace App\Services;

use App\Enums\TransactionType;
use App\Jobs\ProcessCablePurchase;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;

class CableService
{
    public function __construct(
        protected CableProviderResolver $providerResolver,
        protected TransactionService $transactionService,
        protected WalletService $walletService,
    ) {}

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

    public function purchase(User $user, string $cableProvider, string $smartcardNumber, string $variationCode, string $phone, string $pin): Transaction
    {
        $wallet = $user->wallet;

        $this->walletService->verifyPin($wallet, $pin);

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
            meta: ['cable_provider' => $cableProvider, 'smartcard_number' => $smartcardNumber, 'variation_code' => $variationCode, 'plan_name' => $plan['name']],
        );

        $this->walletService->debit($wallet, $amount, $transaction->reference, 'Cable TV subscription', $transaction);
        $this->transactionService->markProcessing($transaction);

        ProcessCablePurchase::dispatch($transaction->id, $cableProvider, $smartcardNumber, $variationCode, $amount, $phone);

        return $transaction;
    }
}
