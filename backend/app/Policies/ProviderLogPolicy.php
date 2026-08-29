<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\ProviderLog;

class ProviderLogPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('provider-logs.view'); }
    public function view(Admin $admin, ProviderLog $log): bool { return $admin->can('provider-logs.view'); }
}
