<?php

namespace App\Repositories\Interfaces;

use App\Models\CommissionSetting;

interface CommissionSettingRepositoryInterface
{
    public function findActiveFor(string $serviceType, ?string $network = null): ?CommissionSetting;
}