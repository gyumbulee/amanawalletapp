<?php

namespace App\Services;

use App\Enums\TransactionType;
use App\Models\ReferralEarning;
use App\Models\Setting;
use App\Models\Transaction;
use App\Models\User;
use App\Notifications\ReferralBonusEarnedNotification;

class ReferralService
{
    public function __construct(
        protected TransactionService $transactionService,
        protected WalletService $walletService,
    ) {
    }

    public function maybeAwardBonus(Transaction $transaction): void
    {
        // Referral bonus transactions themselves never trigger another bonus.
        if ($transaction->type === TransactionType::ReferralBonus) {
            return;
        }

        if ((float) $transaction->amount < 1000) {
            return;
        }

        $referredUser = $transaction->user;

        if (! $referredUser->referred_by) {
            return;
        }

        // One-time bonus per referred user.
        if (ReferralEarning::query()->where('referred_user_id', $referredUser->id)->exists()) {
            return;
        }

        $referrer = User::query()->find($referredUser->referred_by);

        if (! $referrer || ! $referrer->wallet) {
            return;
        }

        $bonusAmount = (float) Setting::get('referral_bonus_amount', 200);

        $bonusTransaction = $this->transactionService->initiate(
            user: $referrer,
            wallet: $referrer->wallet,
            type: TransactionType::ReferralBonus,
            amount: $bonusAmount,
            description: "Referral bonus - {$referredUser->first_name} {$referredUser->last_name}",
            meta: ['referred_user_id' => $referredUser->id, 'qualifying_transaction_id' => $transaction->id],
        );

        $this->walletService->credit(
            $referrer->wallet,
            $bonusAmount,
            $bonusTransaction->reference,
            'Referral bonus',
            $bonusTransaction
        );

        $this->transactionService->markSuccessful($bonusTransaction);

        ReferralEarning::query()->create([
            'referrer_id' => $referrer->id,
            'referred_user_id' => $referredUser->id,
            'qualifying_transaction_id' => $transaction->id,
            'bonus_transaction_id' => $bonusTransaction->id,
            'amount' => $bonusAmount,
        ]);

        $referrer->notify(new ReferralBonusEarnedNotification($bonusAmount, $referredUser));
    }
}