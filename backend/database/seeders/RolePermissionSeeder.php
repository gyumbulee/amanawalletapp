<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RolePermissionSeeder extends Seeder
{
    /**
     * Full permission catalog — one entry per gated action across the admin panel.
     * Keep this list in sync with app/Filament/Resources/* and any Policies.
     */
    public static array $permissions = [
        'users.view', 'users.suspend', 'users.activate', 'users.reset-pin',
        'kyc.view', 'kyc.review',
        'transactions.view', 'transactions.export',
        'providers.manage',
        'provider-logs.view',
        'commissions.manage',
        'recharge-cards.view', 'recharge-cards.generate', 'recharge-cards.print',
        'support-tickets.view', 'support-tickets.reply',
        'reports.view', 'reports.export',
        'audit-logs.view',
        'settings.manage',
        'admins.manage',
    ];

    public function run(): void
    {
        foreach (self::$permissions as $permission) {
            Permission::query()->firstOrCreate(['name' => $permission, 'guard_name' => 'admin']);
        }

        // super-admin: implicit full access via Gate::before bypass (see AppServiceProvider).
        // Permissions are still synced so the panel's "select all" UI stays accurate.
        $superAdmin = Role::query()->firstOrCreate(['name' => 'super-admin', 'guard_name' => 'admin']);
        $superAdmin->syncPermissions(self::$permissions);

        // admin: base role with no implicit permissions — each admin's actual access
        // is granted individually as direct permissions when the account is created.
        Role::query()->firstOrCreate(['name' => 'admin', 'guard_name' => 'admin']);
    }
}
