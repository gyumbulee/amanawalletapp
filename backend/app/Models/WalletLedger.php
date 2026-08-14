<?php

namespace App\Models;

use App\Enums\WalletLedgerType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class WalletLedger extends Model
{
    use HasFactory;

    protected $fillable = [
        'wallet_id',
        'transaction_id',
        'type',
        'amount',
        'balance_before',
        'balance_after',
        'reference',
        'description',
    ];

    protected function casts(): array
    {
        return [
            'type' => WalletLedgerType::class,
            'amount' => 'decimal:2',
            'balance_before' => 'decimal:2',
            'balance_after' => 'decimal:2',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (WalletLedger $ledger) {
            $ledger->uuid = $ledger->uuid ?? (string) Str::uuid();
        });
    }

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }

    public function transaction()
    {
        return $this->belongsTo(Transaction::class);
    }
}