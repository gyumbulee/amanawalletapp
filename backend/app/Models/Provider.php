<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Provider extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'is_active',
        'priority',
        'retry_attempts',
        'timeout_seconds',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (Provider $provider) {
            $provider->uuid = $provider->uuid ?? (string) Str::uuid();
        });

        static::updated(function (Provider $provider) {
            if (app()->runningInConsole()) {
                return;
            }

            \App\Models\AuditLog::record(
                'provider.update',
                $provider,
                $provider->getChanges()
            );
        });
    }
}