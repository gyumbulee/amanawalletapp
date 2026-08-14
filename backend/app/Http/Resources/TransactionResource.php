<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'type' => $this->type,
            'reference' => $this->reference,
            'amount' => (float) $this->amount,
            'fee' => (float) $this->fee,
            'status' => $this->status,
            'provider' => $this->provider,
            'description' => $this->description,
            'meta' => $this->meta,
            'created_at' => $this->created_at,
        ];
    }
}