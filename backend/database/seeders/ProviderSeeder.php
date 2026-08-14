<?php

namespace Database\Seeders;

use App\Models\Provider;
use Illuminate\Database\Seeder;

class ProviderSeeder extends Seeder
{
    public function run(): void
    {
        $providers = [
            [
                'name' => 'Flutterwave',
                'slug' => 'flutterwave',
                'is_active' => true,
                'priority' => 1,
                'retry_attempts' => 1,
                'timeout_seconds' => 30,
            ],
            [
                'name' => 'VTpass',
                'slug' => 'vtpass',
                'is_active' => true,
                'priority' => 1,
                'retry_attempts' => 1,
                'timeout_seconds' => 30,
            ],
            [
                'name' => 'BigiSub',
                'slug' => 'bigisub',
                'is_active' => true,
                'priority' => 2,
                'retry_attempts' => 1,
                'timeout_seconds' => 30,
            ],
            [
                'name' => 'ePINs',
                'slug' => 'epins',
                'is_active' => true,
                'priority' => 1,
                'retry_attempts' => 1,
                'timeout_seconds' => 30,
            ],
        ];

        foreach ($providers as $provider) {
            Provider::query()->updateOrCreate(
                ['slug' => $provider['slug']],
                $provider
            );
        }
    }
}