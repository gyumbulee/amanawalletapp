<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class IdempotencyKey extends Model
{
    protected $fillable = [
        'user_id',
        'key',
        'route',
        'request_hash',
        'status',
        'response_status',
        'response_body',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
