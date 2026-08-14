<?php

namespace App\Repositories\Interfaces;

use App\Models\Transaction;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface TransactionRepositoryInterface
{
    public function create(array $data): Transaction;

    public function update(Transaction $transaction, array $data): Transaction;

    public function findByReference(string $reference): ?Transaction;

    public function findByUuid(string $uuid): ?Transaction;

    public function paginateForUser(User $user, int $perPage = 20, array $filters = []): LengthAwarePaginator;

    public function referenceExists(string $reference): bool;
}