<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RechargeCardBatchResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'network' => $this->network,
            'denomination' => (float) $this->denomination,
            'quantity' => $this->quantity,
            'status' => $this->status,
            'failure_reason' => $this->failure_reason,
            'generated_by' => $this->whenLoaded('generatedBy', fn () => $this->generatedBy->first_name . ' ' . $this->generatedBy->last_name),
            'created_at' => $this->created_at,
        ];
    }
}