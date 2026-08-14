<?php

namespace App\Services;

use App\Models\Commission;
use App\Models\Transaction;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Collection;

class ReportService
{
    public function salesForRange(Carbon $from, Carbon $to): array
    {
        $query = Transaction::query()
            ->where('status', 'successful')
            ->whereBetween('created_at', [$from, $to]);

        return [
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'total_transactions' => (clone $query)->count(),
            'total_amount' => (float) (clone $query)->sum('amount'),
            'by_type' => (clone $query)
                ->selectRaw('type, COUNT(*) as count, SUM(amount) as total')
                ->groupBy('type')
                ->get()
                ->map(fn ($row) => [
                    'type' => $row->type instanceof \BackedEnum ? $row->type->value : $row->type,
                    'count' => (int) $row->count,
                    'total' => (float) $row->total,
                ]),
        ];
    }

    public function dailySales(Carbon $date): array
    {
        return $this->salesForRange($date->copy()->startOfDay(), $date->copy()->endOfDay());
    }

    public function weeklySales(Carbon $weekStart): array
    {
        return $this->salesForRange($weekStart->copy()->startOfWeek(), $weekStart->copy()->endOfWeek());
    }

    public function monthlySales(Carbon $month): array
    {
        return $this->salesForRange($month->copy()->startOfMonth(), $month->copy()->endOfMonth());
    }

    public function revenue(Carbon $from, Carbon $to): array
    {
        $query = Commission::query()
            ->whereHas('transaction', fn ($q) => $q->whereBetween('created_at', [$from, $to]));

        return [
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'total_profit' => (float) $query->sum('profit'),
            'total_cost' => (float) $query->sum('cost_price'),
            'total_sales' => (float) $query->sum('sale_price'),
            'transaction_count' => $query->count(),
        ];
    }

    public function walletFunding(Carbon $from, Carbon $to): array
    {
        $query = Transaction::query()
            ->where('type', 'wallet_funding')
            ->where('status', 'successful')
            ->whereBetween('created_at', [$from, $to]);

        return [
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'total_fundings' => $query->count(),
            'total_amount' => (float) $query->sum('amount'),
        ];
    }

    public function serviceSales(Carbon $from, Carbon $to): Collection
    {
        return Transaction::query()
            ->where('status', 'successful')
            ->where('type', '!=', 'wallet_funding')
            ->whereBetween('created_at', [$from, $to])
            ->selectRaw('type, COUNT(*) as count, SUM(amount) as total')
            ->groupBy('type')
            ->get()
            ->map(fn ($row) => [
                'service' => $row->type instanceof \BackedEnum ? $row->type->value : $row->type,
                'count' => (int) $row->count,
                'total' => (float) $row->total,
            ]);
    }

    public function userGrowth(Carbon $from, Carbon $to, string $groupBy = 'day'): Collection
    {
        $format = match ($groupBy) {
            'week' => '%x-W%v',
            'month' => '%Y-%m',
            default => '%Y-%m-%d',
        };

        return User::query()
            ->whereBetween('created_at', [$from, $to])
            ->selectRaw("DATE_FORMAT(created_at, '{$format}') as period, COUNT(*) as count")
            ->groupBy('period')
            ->orderBy('period')
            ->get()
            ->map(fn ($row) => [
                'period' => $row->period,
                'new_users' => (int) $row->count,
            ]);
    }
}