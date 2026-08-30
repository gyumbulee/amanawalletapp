<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\ProviderServicePriority;

class ProviderServicePriorityPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('providers.manage'); }
    public function view(Admin $admin, ProviderServicePriority $r): bool { return $admin->can('providers.manage'); }
    public function create(Admin $admin): bool { return $admin->can('providers.manage'); }
    public function update(Admin $admin, ProviderServicePriority $r): bool { return $admin->can('providers.manage'); }
    public function delete(Admin $admin, ProviderServicePriority $r): bool { return $admin->can('providers.manage'); }
}
