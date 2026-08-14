<?php

namespace App\Models;

use App\Enums\VirtualAccountStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class VirtualAccount extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'wallet_id',
        'provider',
        'provider_reference',
        'account_number',
        'account_name',
        'bank_name',
        'status',
        'failure_reason',
    ];

    protected function casts(): array
    {
        return [
            'status' => VirtualAccountStatus::class,
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (VirtualAccount $account) {
            $account->uuid = $account->uuid ?? (string) Str::uuid();
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }
}