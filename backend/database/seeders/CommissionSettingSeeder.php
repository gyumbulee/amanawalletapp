<?php

namespace Database\Seeders;

use App\Models\CommissionSetting;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class CommissionSettingSeeder extends Seeder
{
    /**
     * Placeholder commission rates for local testing. These are NOT the
     * real business rates - configure the actual values later via the
     * Filament admin panel (Phase 14) or update this seeder directly.
     */
    public function run(): void
    {
        $settings = [
            [
                'service_type' => 'airtime',
                'network'      => null,
                'type'         => 'percentage',
                'value'        => 2.0,
                'is_active'    => true,
            ],
            [
                'service_type' => 'data',
                'network'      => null,
                'type'         => 'percentage',
                'value'        => 3.0,
                'is_active'    => true,
            ],
            [
                'service_type' => 'electricity',
                'network'      => null,
                'type'         => 'percentage',
                'value'        => 1.5,
                'is_active'    => true,
            ],
            [
                'service_type' => 'cable',
                'network'      => null,
                'type'         => 'percentage',
                'value'        => 1.0,
                'is_active'    => true,
            ],
            [
                'service_type' => 'education',
                'network'      => null,
                'type'         => 'percentage',
                'value'        => 1.0,
                'is_active'    => true,
            ],
        ];

        foreach ($settings as $setting) {
            CommissionSetting::query()->firstOrCreate(
                [
                    'service_type' => $setting['service_type'],
                    'network'      => $setting['network'],
                ],
                [
                    'uuid'      => (string) Str::uuid(),
                    'type'      => $setting['type'],
                    'value'     => $setting['value'],
                    'is_active' => $setting['is_active'],
                ]
            );
        }
    }
}