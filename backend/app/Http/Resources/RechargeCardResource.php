<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RechargeCardResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'network' => $this->network,
            'denomination' => (float) $this->denomination,
            'serial_number' => $this->serial_number,
            'pin' => $this->pin,
            'is_printed' => $this->is_printed,
            'created_at' => $this->created_at,
        ];
    }
}