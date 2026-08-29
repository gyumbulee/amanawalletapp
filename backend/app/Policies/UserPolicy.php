<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\User;

class UserPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('users.view'); }
    public function view(Admin $admin, User $user): bool { return $admin->can('users.view'); }
    public function update(Admin $admin, User $user): bool { return $admin->can('users.view'); }
}
