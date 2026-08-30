<?php

namespace App\Services;

use App\Enums\DataPlanCategory;
use App\Models\DataPlan;

/**
 * Upserts a provider's raw data-plan list into the data_plans catalog.
 *
 * Cost price always reflects the provider's latest number. Selling price
 * is left alone on re-import (admin-set margin is never silently wiped) -
 * it only defaults to cost_price the first time a plan is seen, meaning a
 * brand new plan starts at zero margin until someone prices it.
 *
 * Plans that disappear from the provider's response (discontinued on
 * their end) are marked inactive rather than deleted, so historical
 * transactions still resolve their plan_name/variation_code correctly.
 */
class DataPlanImporter
{
    /**
     * @param  array<int, array{variation_code: string, name: string, amount: float}>  $rawPlans
     */
    public function import(string $network, array $rawPlans): void
    {
        $seenCodes = [];

        foreach ($rawPlans as $raw) {
            $seenCodes[] = $raw['variation_code'];

            $existing = DataPlan::query()
                ->where('network', $network)
                ->where('variation_code', $raw['variation_code'])
                ->first();

            DataPlan::query()->updateOrCreate(
                ['network' => $network, 'variation_code' => $raw['variation_code']],
                [
                    'category' => DataPlanCategory::fromPlanName($raw['name'])->value,
                    'name' => $raw['name'],
                    'cost_price' => $raw['amount'],
                    'selling_price' => $existing?->selling_price ?? $raw['amount'],
                    'is_active' => true,
                ]
            );
        }

        DataPlan::query()
            ->where('network', $network)
            ->whereNotIn('variation_code', $seenCodes)
            ->update(['is_active' => false]);
    }
}
