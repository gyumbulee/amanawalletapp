<?php

namespace App\Listeners;

use App\Events\UserRegistered;
use App\Services\VirtualAccountService;
use Illuminate\Contracts\Queue\ShouldQueue;

class ProvisionVirtualAccountForNewUser implements ShouldQueue
{
    public function __construct(protected VirtualAccountService $virtualAccountService)
    {
    }

    public function handle(UserRegistered $event): void
    {
        $this->virtualAccountService->provisionForUser($event->user);
    }
}