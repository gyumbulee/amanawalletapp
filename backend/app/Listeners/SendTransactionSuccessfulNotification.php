<?php

namespace App\Listeners;

use App\Enums\TransactionType;
use App\Events\TransactionSuccessful;
use App\Notifications\TransactionStatusNotification;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendTransactionSuccessfulNotification implements ShouldQueue
{
    public function handle(TransactionSuccessful $event): void
    {
        // Referral bonuses get their own dedicated, richer notification instead.
        if ($event->transaction->type === TransactionType::ReferralBonus) {
            return;
        }

        $event->transaction->user->notify(new TransactionStatusNotification($event->transaction));
    }
}