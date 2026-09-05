<?php

namespace App\Listeners;

use App\Events\TransactionReversed;
use App\Notifications\TransactionStatusNotification;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendTransactionReversedNotification implements ShouldQueue
{
    public function handle(TransactionReversed $event): void
    {
        $event->transaction->user->notify(new TransactionStatusNotification($event->transaction));
    }
}
