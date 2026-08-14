<?php

namespace App\Models;

use App\Enums\ProviderLogStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class ProviderLog extends Model
{
    protected $fillable = [
        'provider',
        'service_type',
        'request_reference',
        'transaction_reference',
        'request_payload',
        'response_payload',
        'status',
        'error_message',
        'retry_count',
        'duration_ms',
    ];

    protected function casts(): array
    {
        return [
            'request_payload' => 'array',
            'response_payload' => 'array',
            'status' => ProviderLogStatus::class,
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (ProviderLog $log) {
            $log->uuid = $log->uuid ?? (string) Str::uuid();
        });
    }
}