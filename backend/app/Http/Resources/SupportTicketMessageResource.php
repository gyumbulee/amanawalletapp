<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SupportTicketMessageResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'sender_type' => $this->sender_type,
            'message' => $this->message,
            'created_at' => $this->created_at,
        ];
    }
}
