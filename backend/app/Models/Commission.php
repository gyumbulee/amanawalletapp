<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Commission extends Model
{
    protected $fillable = [
        'transaction_id',
        'commission_setting_id',
        'cost_price',
        'sale_price',
        'profit',
    ];

    protected function casts(): array
    {
        return [
            'cost_price' => 'decimal:2',
            'sale_price' => 'decimal:2',
            'profit' => 'decimal:2',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (Commission $commission) {
            $commission->uuid = $commission->uuid ?? (string) Str::uuid();
        });
    }

    public function transaction()
    {
        return $this->belongsTo(Transaction::class);
    }

    public function commissionSetting()
    {
        return $this->belongsTo(CommissionSetting::class);
    }
}