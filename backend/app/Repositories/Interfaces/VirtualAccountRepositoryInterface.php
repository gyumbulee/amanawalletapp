<?php

namespace App\Repositories\Interfaces;

use App\Models\User;
use App\Models\VirtualAccount;

interface VirtualAccountRepositoryInterface
{
    public function firstOrCreatePending(User $user): VirtualAccount;

    public function findByUser(User $user): ?VirtualAccount;

    public function findByAccountNumber(string $accountNumber): ?VirtualAccount;

    public function update(VirtualAccount $account, array $data): VirtualAccount;
}