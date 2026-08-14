<?php

namespace App\Filament\Widgets;

use App\Models\Commission;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class DashboardStatsWidget extends BaseWidget
{
    protected function getStats(): array
    {
        $today = now()->startOfDay();
        $monthStart = now()->startOfMonth();

        return [
            Stat::make('Total Users', User::query()->count()),
            Stat::make('Active Users', User::query()->where('status', 'active')->count()),
            Stat::make('Total Wallet Balance', '₦' . number_format(Wallet::query()->sum('balance'), 2)),
            Stat::make('Daily Revenue', '₦' . number_format(
                Commission::query()->whereDate('created_at', $today)->sum('profit'),
                2
            )),
            Stat::make('Monthly Revenue', '₦' . number_format(
                Commission::query()->where('created_at', '>=', $monthStart)->sum('profit'),
                2
            )),
            Stat::make('Total Transactions', Transaction::query()->count()),
            Stat::make('Successful Transactions', Transaction::query()->where('status', 'successful')->count())
                ->color('success'),
            Stat::make('Failed Transactions', Transaction::query()->where('status', 'failed')->count())
                ->color('danger'),
        ];
    }
}