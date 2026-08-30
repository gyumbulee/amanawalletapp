<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\DataPlan;

class DataPlanPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('commissions.manage'); }
    public function view(Admin $admin, DataPlan $plan): bool { return $admin->can('commissions.manage'); }
    public function update(Admin $admin, DataPlan $plan): bool { return $admin->can('commissions.manage'); }
}
