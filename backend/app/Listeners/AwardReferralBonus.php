<?php

namespace App\Listeners;

use App\Events\TransactionSuccessful;
use App\Services\ReferralService;
use Illuminate\Contracts\Queue\ShouldQueue;

class AwardReferralBonus implements ShouldQueue
{
    public function __construct(protected ReferralService $referralService)
    {
    }

    public function handle(TransactionSuccessful $event): void
    {
        $this->referralService->maybeAwardBonus($event->transaction);
    }
}