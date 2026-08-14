<?php

namespace App\Models;

use App\Enums\RechargeCardBatchStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class RechargeCardBatch extends Model
{
    protected $fillable = [
        'network',
        'denomination',
        'quantity',
        'status',
        'generated_by',
        'failure_reason',
    ];

    protected function casts(): array
    {
        return [
            'denomination' => 'decimal:2',
            'status' => RechargeCardBatchStatus::class,
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (RechargeCardBatch $batch) {
            $batch->uuid = $batch->uuid ?? (string) Str::uuid();
        });
    }

    public function cards()
    {
        return $this->hasMany(RechargeCard::class, 'batch_id');
    }

    public function generatedBy()
    {
        return $this->belongsTo(Admin::class, 'generated_by');
    }
}