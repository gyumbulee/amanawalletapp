<?php

namespace App\Repositories;

use App\Models\Transaction;
use App\Models\User;
use App\Repositories\Interfaces\TransactionRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class TransactionRepository implements TransactionRepositoryInterface
{
    public function create(array $data): Transaction
    {
        return Transaction::query()->create($data);
    }

    public function update(Transaction $transaction, array $data): Transaction
    {
        $transaction->update($data);

        return $transaction->refresh();
    }

    public function findByReference(string $reference): ?Transaction
    {
        return Transaction::query()->where('reference', $reference)->first();
    }

    public function findByUuid(string $uuid): ?Transaction
    {
        return Transaction::query()->where('uuid', $uuid)->first();
    }

    public function paginateForUser(User $user, int $perPage = 20, array $filters = []): LengthAwarePaginator
    {
        $query = Transaction::query()->where('user_id', $user->id);

        if (! empty($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        return $query->latest()->paginate($perPage);
    }

    public function referenceExists(string $reference): bool
    {
        return Transaction::query()->where('reference', $reference)->exists();
    }
}