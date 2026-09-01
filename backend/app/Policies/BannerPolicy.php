<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\Banner;

class BannerPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('settings.manage'); }
    public function view(Admin $admin, Banner $banner): bool { return $admin->can('settings.manage'); }
    public function create(Admin $admin): bool { return $admin->can('settings.manage'); }
    public function update(Admin $admin, Banner $banner): bool { return $admin->can('settings.manage'); }
    public function delete(Admin $admin, Banner $banner): bool { return $admin->can('settings.manage'); }
}
