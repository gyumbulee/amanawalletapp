<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class AuditLog extends Model
{
    protected $fillable = [
        'admin_id',
        'action',
        'subject_type',
        'subject_id',
        'changes',
        'ip_address',
    ];

    protected function casts(): array
    {
        return [
            'changes' => 'array',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (AuditLog $log) {
            $log->uuid = $log->uuid ?? (string) Str::uuid();
        });
    }

    public function admin()
    {
        return $this->belongsTo(Admin::class);
    }

    public static function record(string $action, ?Model $subject = null, array $changes = []): void
    {
        static::query()->create([
            'admin_id' => auth('admin')->id(),
            'action' => $action,
            'subject_type' => $subject ? get_class($subject) : null,
            'subject_id' => $subject?->id,
            'changes' => $changes,
            'ip_address' => request()?->ip(),
        ]);
    }
}