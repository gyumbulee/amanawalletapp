<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'email' => $this->email,
            'phone' => $this->phone,
            'referral_code' => $this->referral_code,
            'status' => $this->status,
            'email_verified' => ! is_null($this->email_verified_at),
            'profile_photo_path' => $this->profile_photo_path,
            'profile_photo_url' => $this->profile_photo_path
                ? url('/api/v1/profile-photo/' . basename($this->profile_photo_path))
                : null,
            'created_at' => $this->created_at,
        ];
    }
}