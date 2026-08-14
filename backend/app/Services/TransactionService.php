<?php

namespace App\Services;

use App\Enums\TransactionStatus;
use App\Enums\TransactionType;
use App\Events\TransactionFailed;
use App\Events\TransactionSuccessful;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use App\Repositories\Interfaces\TransactionRepositoryInterface;
use Illuminate\Support\Str;

class TransactionService
{
    public function __construct(
        protected TransactionRepositoryInterface $transactionRepository
    ) {
    }

    public function initiate(
        User $user,
        Wallet $wallet,
        TransactionType $type,
        float $amount,
        string $description,
        array $meta = [],
        float $fee = 0,
        ?string $provider = null
    ): Transaction {
        return $this->transactionRepository->create([
            'user_id' => $user->id,
            'wallet_id' => $wallet->id,
            'type' => $type,
            'reference' => $this->generateReference(),
            'amount' => $amount,
            'fee' => $fee,
            'status' => TransactionStatus::Pending,
            'provider' => $provider,
            'description' => $description,
            'meta' => $meta,
        ]);
    }

    public function markProcessing(Transaction $transaction): Transaction
    {
        return $this->transactionRepository->update($transaction, [
            'status' => TransactionStatus::Processing,
        ]);
    }

    public function markSuccessful(Transaction $transaction, ?string $providerReference = null): Transaction
    {
        $transaction = $this->transactionRepository->update($transaction, array_filter([
            'status' => TransactionStatus::Successful,
            'provider_reference' => $providerReference,
        ], fn ($value) => $value !== null));

        TransactionSuccessful::dispatch($transaction);

        return $transaction;
    }

    public function markFailed(Transaction $transaction, string $reason): Transaction
    {
        $meta = $transaction->meta ?? [];
        $meta['failure_reason'] = $reason;

        $transaction = $this->transactionRepository->update($transaction, [
            'status' => TransactionStatus::Failed,
            'meta' => $meta,
        ]);

        TransactionFailed::dispatch($transaction);

        return $transaction;
    }

    public function markReversed(Transaction $transaction): Transaction
    {
        return $this->transactionRepository->update($transaction, [
            'status' => TransactionStatus::Reversed,
        ]);
    }

    protected function generateReference(): string
    {
        do {
            $reference = 'TXN-' . now()->format('YmdHis') . '-' . Str::upper(Str::random(6));
        } while ($this->transactionRepository->referenceExists($reference));

        return $reference;
    }
}