<?php

namespace App\Models;

use App\Enums\CommissionType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class CommissionSetting extends Model
{
    protected $fillable = [
        'service_type',
        'network',
        'type',
        'value',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'type' => CommissionType::class,
            'value' => 'decimal:4',
            'is_active' => 'boolean',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (CommissionSetting $setting) {
            $setting->uuid = $setting->uuid ?? (string) Str::uuid();
        });

        static::saved(function (CommissionSetting $setting) {
            if (app()->runningInConsole()) {
                return;
            }

            \App\Models\AuditLog::record('commission_setting.save', $setting, $setting->getChanges());
        });
    }
}