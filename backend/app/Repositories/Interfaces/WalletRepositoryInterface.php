<?php

namespace App\Repositories\Interfaces;

use App\Models\User;
use App\Models\Wallet;

interface WalletRepositoryInterface
{
    public function create(array $data): Wallet;

    public function findByUser(User $user): ?Wallet;

    public function lockForUpdate(int $walletId): Wallet;
}