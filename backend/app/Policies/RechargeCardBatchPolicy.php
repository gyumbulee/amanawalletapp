<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\RechargeCardBatch;

class RechargeCardBatchPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('recharge-cards.view'); }
    public function view(Admin $admin, RechargeCardBatch $batch): bool { return $admin->can('recharge-cards.view'); }
    public function create(Admin $admin): bool { return $admin->can('recharge-cards.generate'); }
}
