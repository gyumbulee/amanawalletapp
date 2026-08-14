<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VirtualAccountResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'account_number' => $this->account_number,
            'account_name' => $this->account_name,
            'bank_name' => $this->bank_name,
            'status' => $this->status,
            'failure_reason' => $this->when(
                $this->status?->value === 'failed',
                $this->failure_reason
            ),
            'created_at' => $this->created_at,
        ];
    }
}