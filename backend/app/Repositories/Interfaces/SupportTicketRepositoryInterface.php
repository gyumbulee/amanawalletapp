<?php

namespace App\Repositories\Interfaces;

use App\Models\SupportTicket;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

interface SupportTicketRepositoryInterface
{
    public function create(array $data): SupportTicket;

    public function findByUuid(string $uuid): ?SupportTicket;

    public function findByUuidForUser(string $uuid, User $user): ?SupportTicket;

    public function paginateForUser(User $user, int $perPage = 20): LengthAwarePaginator;

    public function touchLastMessageAt(SupportTicket $ticket): void;
}
