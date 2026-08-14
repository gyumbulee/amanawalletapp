<?php

namespace Database\Seeders;

use App\Models\Admin;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
{
    $admin = Admin::where('email', 'admin@amanawallet.com')->first();

    if (! $admin) {
        $admin = Admin::create([
            'name' => 'Super Admin',
            'email' => 'admin@amanawallet.com',
            'password' => Hash::make('ChangeMe123!'),
            'is_active' => true,
        ]);
    }

    if (! $admin->hasRole('super-admin')) {
        $admin->assignRole('super-admin');
    }
}

    protected static function booted(): void
{
    static::creating(function (Admin $admin) {
        $admin->uuid = $admin->uuid ?? (string) \Illuminate\Support\Str::uuid();

        dump($admin->uuid);
    });
}
}