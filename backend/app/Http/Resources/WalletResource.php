<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WalletResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'balance' => (float) $this->balance,
            'currency' => $this->currency,
            'status' => $this->status,
            'has_pin' => ! is_null($this->pin),
            'created_at' => $this->created_at,
        ];
    }
}