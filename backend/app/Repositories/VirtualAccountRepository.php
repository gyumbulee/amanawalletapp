<?php

namespace App\Repositories;

use App\Enums\VirtualAccountStatus;
use App\Models\User;
use App\Models\VirtualAccount;
use App\Repositories\Interfaces\VirtualAccountRepositoryInterface;

class VirtualAccountRepository implements VirtualAccountRepositoryInterface
{
    public function firstOrCreatePending(User $user): VirtualAccount
    {
        return VirtualAccount::query()->firstOrCreate(
            ['user_id' => $user->id],
            [
                'wallet_id' => $user->wallet->id,
                'status' => VirtualAccountStatus::Pending,
            ]
        );
    }

    public function findByUser(User $user): ?VirtualAccount
    {
        return VirtualAccount::query()->where('user_id', $user->id)->first();
    }

    public function findByAccountNumber(string $accountNumber): ?VirtualAccount
    {
        return VirtualAccount::query()->where('account_number', $accountNumber)->first();
    }

    public function update(VirtualAccount $account, array $data): VirtualAccount
    {
        $account->update($data);

        return $account->refresh();
    }
}