<?php

namespace App\Models;

use App\Enums\SupportTicketSenderType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class SupportTicketMessage extends Model
{
    use HasFactory;

    protected $fillable = [
        'support_ticket_id',
        'sender_type',
        'sender_id',
        'message',
    ];

    protected function casts(): array
    {
        return [
            'sender_type' => SupportTicketSenderType::class,
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (SupportTicketMessage $message) {
            $message->uuid = $message->uuid ?? (string) Str::uuid();
        });
    }

    public function ticket()
    {
        return $this->belongsTo(SupportTicket::class, 'support_ticket_id');
    }

    /**
     * Resolves against the correct table for whichever guard sent this
     * message - there's no single foreign key to join on since 'user' and
     * 'admin' senders live in separate tables (Sanctum 'users' guard vs
     * session 'admins' guard, same split used everywhere else in this app).
     */
    public function sender(): User|Admin|null
    {
        if (! $this->sender_id) {
            return null;
        }

        return $this->sender_type === SupportTicketSenderType::Admin
            ? Admin::find($this->sender_id)
            : User::find($this->sender_id);
    }
}
