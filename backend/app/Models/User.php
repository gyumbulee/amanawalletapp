<?php

namespace App\Models;

use App\Enums\UserStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Str;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'first_name',
        'last_name',
        'email',
        'phone',
        'password',
        'referral_code',
        'referred_by',
        'status',
        'profile_photo_path',
        'bvn',
        'bvn_verified_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'bvn',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'bvn_verified_at' => 'datetime',
            'password' => 'hashed',
            'bvn' => 'encrypted',
            'status' => UserStatus::class,
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (User $user) {
            $user->uuid = $user->uuid ?? (string) Str::uuid();
        });
    }

    public function referrer()
    {
        return $this->belongsTo(User::class, 'referred_by');
    }

    public function referrals()
    {
        return $this->hasMany(User::class, 'referred_by');
    }

    public function wallet()
    {
        return $this->hasOne(Wallet::class);
    }

    public function virtualAccount()
    {
        return $this->hasOne(VirtualAccount::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }
}