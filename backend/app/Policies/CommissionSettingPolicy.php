<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\CommissionSetting;

class CommissionSettingPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('commissions.manage'); }
    public function view(Admin $admin, CommissionSetting $setting): bool { return $admin->can('commissions.manage'); }
    public function create(Admin $admin): bool { return $admin->can('commissions.manage'); }
    public function update(Admin $admin, CommissionSetting $setting): bool { return $admin->can('commissions.manage'); }
    public function delete(Admin $admin, CommissionSetting $setting): bool { return $admin->can('commissions.manage'); }
}
