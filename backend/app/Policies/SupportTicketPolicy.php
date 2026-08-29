<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\SupportTicket;

class SupportTicketPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('support-tickets.view'); }
    public function view(Admin $admin, SupportTicket $ticket): bool { return $admin->can('support-tickets.view'); }
    public function update(Admin $admin, SupportTicket $ticket): bool { return $admin->can('support-tickets.reply'); }
}
