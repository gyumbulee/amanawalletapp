<?php

namespace Database\Seeders;

use App\Models\Setting;
use Illuminate\Database\Seeder;

class SettingSeeder extends Seeder
{
    /**
     * Placeholder value - configure the real referral bonus via the
     * Filament admin panel (Phase 14) or update this seeder directly.
     */
    public function run(): void
    {
        Setting::set('referral_bonus_amount', 200);
    }
}