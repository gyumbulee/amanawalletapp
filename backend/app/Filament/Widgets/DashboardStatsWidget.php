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

        $totalUsers = User::query()->count();
        $activeUsers = User::query()->where('status', 'active')->count();
        $totalTransactions = Transaction::query()->count();
        $successfulTransactions = Transaction::query()->where('status', 'successful')->count();
        $failedTransactions = Transaction::query()->where('status', 'failed')->count();
        $revenueTrend = $this->dailyRevenueTrend();

        return [
            Stat::make('Total Users', number_format($totalUsers))
                ->description($activeUsers.' active')
                ->descriptionIcon('heroicon-m-users')
                ->icon('heroicon-o-users')
                ->color('gray'),

            Stat::make('Active Users', number_format($activeUsers))
                ->description($totalUsers > 0 ? round(($activeUsers / $totalUsers) * 100).'% of total' : 'No users yet')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->icon('heroicon-o-user-circle')
                ->color('primary'),

            Stat::make('Total Wallet Balance', '₦'.number_format(Wallet::query()->sum('balance'), 2))
                ->description('Across all customer wallets')
                ->icon('heroicon-o-wallet')
                ->color('primary'),

            Stat::make('Daily Revenue', '₦'.number_format(
                Commission::query()->whereDate('created_at', $today)->sum('profit'),
                2
            ))
                ->description('Since midnight')
                ->descriptionIcon('heroicon-m-clock')
                ->icon('heroicon-o-banknotes')
                ->chart($revenueTrend)
                ->color('success'),

            Stat::make('Monthly Revenue', '₦'.number_format(
                Commission::query()->where('created_at', '>=', $monthStart)->sum('profit'),
                2
            ))
                ->description('Since '.$monthStart->format('M j'))
                ->descriptionIcon('heroicon-m-calendar')
                ->icon('heroicon-o-chart-bar')
                ->chart($revenueTrend)
                ->color('success'),

            Stat::make('Total Transactions', number_format($totalTransactions))
                ->icon('heroicon-o-arrows-right-left')
                ->color('gray'),

            Stat::make('Successful Transactions', number_format($successfulTransactions))
                ->description($totalTransactions > 0
                    ? round(($successfulTransactions / $totalTransactions) * 100).'% success rate'
                    : 'No transactions yet')
                ->descriptionIcon('heroicon-m-check-circle')
                ->icon('heroicon-o-check-circle')
                ->color('success'),

            Stat::make('Failed Transactions', number_format($failedTransactions))
                ->description($totalTransactions > 0
                    ? round(($failedTransactions / $totalTransactions) * 100).'% of total'
                    : 'No transactions yet')
                ->descriptionIcon('heroicon-m-x-circle')
                ->icon('heroicon-o-x-circle')
                ->color('danger'),
        ];
    }

    /**
     * Last 7 days of commission profit, oldest first — feeds the Stat
     * sparkline charts. A flat/empty line is a legitimate result for a
     * fresh install, not a bug.
     */
    private function dailyRevenueTrend(): array
    {
        return collect(range(6, 0))
            ->map(fn (int $daysAgo) => (float) Commission::query()
                ->whereDate('created_at', now()->subDays($daysAgo)->toDateString())
                ->sum('profit'))
            ->all();
    }
}
