<?php

namespace App\Services;

use App\Enums\TransactionType;
use App\Jobs\ProcessElectricityPurchase;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;

class ElectricityService
{
    public function __construct(
        protected ElectricityProviderResolver $providerResolver,
        protected TransactionService $transactionService,
        protected WalletService $walletService,
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

        ProcessElectricityPurchase::dispatch($transaction->id, $disco, $meterNumber, $meterType, $amount, $phone);

        return $transaction;
    }
}