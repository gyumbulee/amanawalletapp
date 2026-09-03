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
    private const MAX_PIN_ATTEMPTS = 5;

    private const PIN_LOCKOUT_MINUTES = 15;

    public function __construct(
        protected WalletRepositoryInterface $walletRepository
    ) {}

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
     *
     * Locks the wallet's PIN for PIN_LOCKOUT_MINUTES after MAX_PIN_ATTEMPTS
     * consecutive wrong guesses, so a stolen bearer token can't be used to
     * brute-force a 4-digit PIN (10,000 combinations is trivial without
     * this - route-level throttling alone isn't enough).
     */
    public function verifyPin(Wallet $wallet, string $pin): void
    {
        if (! $wallet->pin) {
            throw ValidationException::withMessages([
                'pin' => ['Please set a transaction PIN before making purchases.'],
            ]);
        }

        if ($wallet->pin_locked_until && $wallet->pin_locked_until->isFuture()) {
            $minutesLeft = max(1, now()->diffInMinutes($wallet->pin_locked_until, true));

            throw ValidationException::withMessages([
                'pin' => ["Too many incorrect PIN attempts. Try again in {$minutesLeft} minute(s)."],
            ]);
        }

        if (! Hash::check($pin, $wallet->pin)) {
            // Atomic increment - avoids a fetch-then-write race letting two
            // near-simultaneous wrong guesses both slip in under the limit.
            $wallet->increment('pin_failed_attempts');
            $attempts = $wallet->fresh()->pin_failed_attempts;

            if ($attempts >= self::MAX_PIN_ATTEMPTS) {
                $wallet->update([
                    'pin_locked_until' => now()->addMinutes(self::PIN_LOCKOUT_MINUTES),
                    'pin_failed_attempts' => 0,
                ]);

                throw ValidationException::withMessages([
                    'pin' => ['Too many incorrect PIN attempts. Your PIN has been locked for '.self::PIN_LOCKOUT_MINUTES.' minutes.'],
                ]);
            }

            $remaining = self::MAX_PIN_ATTEMPTS - $attempts;

            throw ValidationException::withMessages([
                'pin' => ["Incorrect transaction PIN. {$remaining} attempt(s) remaining before lockout."],
            ]);
        }

        if ($wallet->pin_failed_attempts > 0 || $wallet->pin_locked_until) {
            $wallet->update(['pin_failed_attempts' => 0, 'pin_locked_until' => null]);
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
