<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class ReferralEarning extends Model
{
    protected $fillable = [
        'referrer_id',
        'referred_user_id',
        'qualifying_transaction_id',
        'bonus_transaction_id',
        'amount',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (ReferralEarning $earning) {
            $earning->uuid = $earning->uuid ?? (string) Str::uuid();
        });
    }

    public function referrer()
    {
        return $this->belongsTo(User::class, 'referrer_id');
    }

    public function referredUser()
    {
        return $this->belongsTo(User::class, 'referred_user_id');
    }
}