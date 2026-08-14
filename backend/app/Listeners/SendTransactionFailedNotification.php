<?php

namespace App\Listeners;

use App\Events\TransactionFailed;
use App\Notifications\TransactionStatusNotification;
use Illuminate\Contracts\Queue\ShouldQueue;

class SendTransactionFailedNotification implements ShouldQueue
{
    public function handle(TransactionFailed $event): void
    {
        $event->transaction->user->notify(new TransactionStatusNotification($event->transaction));
    }
}