<?php

namespace App\Services;

use App\Enums\TransactionStatus;
use App\Models\Transaction;
use App\Repositories\Interfaces\TransactionRepositoryInterface;
use RuntimeException;

class TransactionConfirmationService
{
    public function __construct(
        protected TransactionRepositoryInterface $transactionRepository,
        protected WalletService $walletService,
        protected TransactionService $transactionService,
        protected CommissionService $commissionService,
    ) {
    }

    /**
     * @param  string  $status  Provider's inner status - expects 'delivered', 'failed', or 'reversed'.
     */
    public function confirm(string $reference, string $status, ?string $providerReference): Transaction
    {
        $transaction = $this->transactionRepository->findByReference($reference);

        if (! $transaction) {
            throw new RuntimeException("No transaction found for reference: {$reference}");
        }

        // Idempotent - a webhook may arrive after we already finalized synchronously, or twice.
        if (in_array($transaction->status, [TransactionStatus::Successful, TransactionStatus::Failed, TransactionStatus::Reversed], true)) {
            return $transaction;
        }

        if ($status === 'delivered') {
            $network = $transaction->meta['network'] ?? null;

            $calc = $this->commissionService->calculate($transaction->type->value, $network, (float) $transaction->amount);
            $this->commissionService->record($transaction, $calc);

            return $this->transactionService->markSuccessful($transaction, $providerReference);
        }

        // failed or reversed - refund the reserved funds.
        $this->walletService->credit(
            $transaction->wallet,
            (float) $transaction->amount,
            $transaction->reference . '-REVERSAL',
            "Reversal: {$transaction->type->value} transaction {$status}",
            $transaction
        );

        return $status === 'reversed'
            ? $this->transactionService->markReversed($transaction)
            : $this->transactionService->markFailed($transaction, "Provider reported status: {$status}");
    }
}