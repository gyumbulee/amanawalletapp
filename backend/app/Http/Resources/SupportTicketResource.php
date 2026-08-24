<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SupportTicketResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->uuid,
            'subject' => $this->subject,
            'status' => $this->status,
            'transaction_reference' => $this->whenLoaded('transaction', fn () => $this->transaction?->reference),
            'last_message_at' => $this->last_message_at,
            'created_at' => $this->created_at,
            'messages' => SupportTicketMessageResource::collection($this->whenLoaded('messages')),
        ];
    }
}
