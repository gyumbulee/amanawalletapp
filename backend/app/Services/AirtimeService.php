<?php

namespace App\Services;

use App\Enums\TransactionType;
use App\Jobs\ProcessAirtimePurchase;
use App\Models\Transaction;
use App\Models\User;

class AirtimeService
{
    public function __construct(
        protected TransactionService $transactionService,
        protected WalletService $walletService,
    ) {}

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

        // The actual provider call happens off-request from here on - see
        // ProcessAirtimePurchase. This method now always returns with the
        // transaction still in "processing" status; the client is expected
        // to reflect that (not assume success) and poll/await the eventual
        // update via GET /transactions/{uuid} or a push notification.
        ProcessAirtimePurchase::dispatch($transaction->id, $network, $phone, $amount);

        return $transaction;
    }
}
