<?php

namespace App\Policies;

use App\Models\Admin;
use App\Models\Kyc;

class KycPolicy
{
    public function viewAny(Admin $admin): bool { return $admin->can('kyc.view'); }
    public function view(Admin $admin, Kyc $kyc): bool { return $admin->can('kyc.view'); }
    public function update(Admin $admin, Kyc $kyc): bool { return $admin->can('kyc.review'); }
}
