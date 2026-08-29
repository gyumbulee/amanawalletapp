<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\Provider;

class ProviderPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('providers.manage'); }
    public function view(Admin $admin, Provider $provider): bool { return $admin->can('providers.manage'); }
    public function create(Admin $admin): bool { return $admin->can('providers.manage'); }
    public function update(Admin $admin, Provider $provider): bool { return $admin->can('providers.manage'); }
    public function delete(Admin $admin, Provider $provider): bool { return $admin->can('providers.manage'); }
}
