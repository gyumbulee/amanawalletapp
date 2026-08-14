<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RolePermissionSeeder extends Seeder
{
    public function run(): void
    {
        $permissions = [
            'users.view', 'users.suspend', 'users.activate', 'users.reset-pin',
            'transactions.view', 'transactions.export',
            'providers.manage',
            'commissions.manage',
            'recharge-cards.manage',
            'reports.view',
            'settings.manage',
        ];

        foreach ($permissions as $permission) {
            Permission::query()->firstOrCreate(['name' => $permission, 'guard_name' => 'admin']);
        }

        $superAdmin = Role::query()->firstOrCreate(['name' => 'super-admin', 'guard_name' => 'admin']);
        $superAdmin->syncPermissions($permissions);

        Role::query()->firstOrCreate(['name' => 'support', 'guard_name' => 'admin'])
            ->syncPermissions(['users.view', 'transactions.view']);
    }
}