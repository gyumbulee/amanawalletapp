<?php

namespace App\Services;

use App\Enums\WalletLedgerType;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use App\Models\WalletLedger;
use App\Repositories\Interfaces\WalletRepositoryInterface;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class WalletService
{
    public function __construct(
        protected WalletRepositoryInterface $walletRepository
    ) {
    }

    public function createWalletForUser(User $user): Wallet
    {
        if ($existing = $this->walletRepository->findByUser($user)) {
            return $existing;
        }

        return $this->walletRepository->create([
            'user_id' => $user->id,
            'balance' => 0,
            'currency' => 'NGN',
        ]);
    }

    public function getWalletForUser(User $user): Wallet
    {
        $wallet = $this->walletRepository->findByUser($user);

        if (! $wallet) {
            throw ValidationException::withMessages([
                'wallet' => ['No wallet found for this user.'],
            ]);
        }

        return $wallet;
    }

    /**
     * Set or change the wallet's transaction PIN. If a PIN already exists,
     * the current one must be verified first.
     */
    public function setPin(Wallet $wallet, string $newPin, ?string $currentPin = null): Wallet
    {
        if ($wallet->pin) {
            if (! $currentPin || ! Hash::check($currentPin, $wallet->pin)) {
                throw ValidationException::withMessages([
                    'current_pin' => ['Your current PIN is incorrect.'],
                ]);
            }
        }

        $wallet->update(['pin' => Hash::make($newPin)]);

        return $wallet->refresh();
    }

    /**
     * Verify a transaction PIN before any debit-based purchase. Every
     * purchase flow (Airtime, Data, Electricity, Cable, Education) must
     * call this before debiting the wallet.
     */
    public function verifyPin(Wallet $wallet, string $pin): void
    {
        if (! $wallet->pin) {
            throw ValidationException::withMessages([
                'pin' => ['Please set a transaction PIN before making purchases.'],
            ]);
        }

        if (! Hash::check($pin, $wallet->pin)) {
            throw ValidationException::withMessages([
                'pin' => ['Incorrect transaction PIN.'],
            ]);
        }
    }

    /**
     * Credit a wallet. Locks the row for the duration of the DB transaction
     * so concurrent credits/debits on the same wallet cannot race.
     */
    public function credit(Wallet $wallet, float $amount, string $reference, string $description, ?Transaction $transaction = null): Wallet
    {
        return DB::transaction(function () use ($wallet, $amount, $reference, $description, $transaction) {
            $locked = $this->walletRepository->lockForUpdate($wallet->id);

            $balanceBefore = (float) $locked->balance;
            $balanceAfter = $balanceBefore + $amount;

            $locked->update(['balance' => $balanceAfter]);

            WalletLedger::query()->create([
                'wallet_id' => $locked->id,
                'transaction_id' => $transaction?->id,
                'type' => WalletLedgerType::Credit,
                'amount' => $amount,
                'balance_before' => $balanceBefore,
                'balance_after' => $balanceAfter,
                'reference' => $reference,
                'description' => $description,
            ]);

            return $locked->refresh();
        });
    }

    /**
     * Debit a wallet. Locks the row and rejects if funds are insufficient,
     * all inside the same transaction to prevent overdraw under concurrency.
     */
    public function debit(Wallet $wallet, float $amount, string $reference, string $description, ?Transaction $transaction = null): Wallet
    {
        return DB::transaction(function () use ($wallet, $amount, $reference, $description, $transaction) {
            $locked = $this->walletRepository->lockForUpdate($wallet->id);

            $balanceBefore = (float) $locked->balance;

            if ($balanceBefore < $amount) {
                throw ValidationException::withMessages([
                    'balance' => ['Insufficient wallet balance.'],
                ]);
            }

            $balanceAfter = $balanceBefore - $amount;

            $locked->update(['balance' => $balanceAfter]);

            WalletLedger::query()->create([
                'wallet_id' => $locked->id,
                'transaction_id' => $transaction?->id,
                'type' => WalletLedgerType::Debit,
                'amount' => $amount,
                'balance_before' => $balanceBefore,
                'balance_after' => $balanceAfter,
                'reference' => $reference,
                'description' => $description,
            ]);

            return $locked->refresh();
        });
    }
}