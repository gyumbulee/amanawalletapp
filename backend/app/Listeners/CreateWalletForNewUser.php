<?php

namespace App\Listeners;

use App\Events\UserRegistered;
use App\Services\WalletService;

class CreateWalletForNewUser
{
    public function __construct(protected WalletService $walletService)
    {
    }

    public function handle(UserRegistered $event): void
    {
        $this->walletService->createWalletForUser($event->user);
    }
}