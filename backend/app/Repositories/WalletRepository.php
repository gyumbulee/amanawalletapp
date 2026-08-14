<?php

namespace App\Repositories;

use App\Models\User;
use App\Models\Wallet;
use App\Repositories\Interfaces\WalletRepositoryInterface;

class WalletRepository implements WalletRepositoryInterface
{
    public function create(array $data): Wallet
    {
        return Wallet::query()->create($data);
    }

    public function findByUser(User $user): ?Wallet
    {
        return Wallet::query()->where('user_id', $user->id)->first();
    }

    public function lockForUpdate(int $walletId): Wallet
    {
        return Wallet::query()->where('id', $walletId)->lockForUpdate()->firstOrFail();
    }
}

