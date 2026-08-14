<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class RechargeCard extends Model
{
    protected $fillable = [
        'batch_id',
        'network',
        'denomination',
        'serial_number',
        'pin',
        'is_printed',
    ];

    protected $hidden = [
        'pin',
    ];

    protected function casts(): array
    {
        return [
            'denomination' => 'decimal:2',
            'pin' => 'encrypted',
            'is_printed' => 'boolean',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (RechargeCard $card) {
            $card->uuid = $card->uuid ?? (string) Str::uuid();
        });
    }

    public function batch()
    {
        return $this->belongsTo(RechargeCardBatch::class, 'batch_id');
    }
}