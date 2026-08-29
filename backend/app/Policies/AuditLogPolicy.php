<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\AuditLog;

class AuditLogPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('audit-logs.view'); }
    public function view(Admin $admin, AuditLog $log): bool { return $admin->can('audit-logs.view'); }
}
