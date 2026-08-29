<?php

namespace App\Policies;

use App\Models\Admin;

class AdminPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->hasRole('super-admin') || $admin->can('admins.manage'); }
    public function view(Admin $admin, Admin $target): bool { return $admin->hasRole('super-admin') || $admin->can('admins.manage'); }
    public function create(Admin $admin): bool { return $admin->hasRole('super-admin'); }
    public function update(Admin $admin, Admin $target): bool { return $admin->hasRole('super-admin'); }
    public function delete(Admin $admin, Admin $target): bool { return $admin->hasRole('super-admin') && $admin->id !== $target->id; }
}
