<?php

namespace App\Models;

use App\Enums\KycStatus;
use App\Enums\KycType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Kyc extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'status',
        'reference',
        'document_path',
        'rejection_reason',
        'verified_at',
    ];

    protected function casts(): array
    {
        return [
            'type' => KycType::class,
            'status' => KycStatus::class,
            'reference' => 'encrypted',
            'verified_at' => 'datetime',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (Kyc $kyc) {
            $kyc->uuid = $kyc->uuid ?? (string) Str::uuid();
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}