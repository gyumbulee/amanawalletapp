<?php

namespace App\Repositories;

use App\Models\CommissionSetting;
use App\Repositories\Interfaces\CommissionSettingRepositoryInterface;

class CommissionSettingRepository implements CommissionSettingRepositoryInterface
{
    public function findActiveFor(string $serviceType, ?string $network = null): ?CommissionSetting
    {
        // Prefer a network-specific setting, fall back to a service-wide one (network = null).
        return CommissionSetting::query()
            ->where('service_type', $serviceType)
            ->where('is_active', true)
            ->where(function ($query) use ($network) {
                $query->where('network', $network)->orWhereNull('network');
            })
            ->orderByRaw('network IS NULL') // network-specific rows first
            ->first();
    }
}