<?php

namespace App\Repositories;

use App\Models\SupportTicket;
use App\Models\User;
use App\Repositories\Interfaces\SupportTicketRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class SupportTicketRepository implements SupportTicketRepositoryInterface
{
    public function create(array $data): SupportTicket
    {
        return SupportTicket::query()->create($data);
    }

    public function findByUuid(string $uuid): ?SupportTicket
    {
        return SupportTicket::query()->where('uuid', $uuid)->first();
    }

    public function findByUuidForUser(string $uuid, User $user): ?SupportTicket
    {
        return SupportTicket::query()
            ->where('uuid', $uuid)
            ->where('user_id', $user->id)
            ->first();
    }

    public function paginateForUser(User $user, int $perPage = 20): LengthAwarePaginator
    {
        return SupportTicket::query()
            ->where('user_id', $user->id)
            ->with('transaction')
            ->latest('last_message_at')
            ->paginate($perPage);
    }

    public function touchLastMessageAt(SupportTicket $ticket): void
    {
        $ticket->update(['last_message_at' => now()]);
    }
}
