<?php

namespace App\Services;

use App\Enums\CommissionType;
use App\Models\Commission;
use App\Models\Transaction;
use App\Repositories\Interfaces\CommissionSettingRepositoryInterface;

class CommissionService
{
    public function __construct(
        protected CommissionSettingRepositoryInterface $commissionSettingRepository
    ) {
    }

    public function calculate(string $serviceType, ?string $network, float $saleAmount): array
    {
        $setting = $this->commissionSettingRepository->findActiveFor($serviceType, $network);

        if (! $setting) {
            return [
                'cost_price' => $saleAmount,
                'sale_price' => $saleAmount,
                'profit' => 0,
                'commission_setting_id' => null,
            ];
        }

        $profit = $setting->type === CommissionType::Percentage
            ? round($saleAmount * ((float) $setting->value / 100), 2)
            : min((float) $setting->value, $saleAmount);

        return [
            'cost_price' => $saleAmount - $profit,
            'sale_price' => $saleAmount,
            'profit' => $profit,
            'commission_setting_id' => $setting->id,
        ];
    }

    public function record(Transaction $transaction, array $calculation): Commission
    {
        return Commission::query()->create([
            'transaction_id' => $transaction->id,
            'commission_setting_id' => $calculation['commission_setting_id'],
            'cost_price' => $calculation['cost_price'],
            'sale_price' => $calculation['sale_price'],
            'profit' => $calculation['profit'],
        ]);
    }
}