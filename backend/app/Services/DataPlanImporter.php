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
                    'name' => self::withSizeUnit($raw['name'], (float) $raw['amount']),
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

    /**
     * BigiSub's plan names carry a leading size number with NO unit
     * (e.g. "20 GIFTING - 1 day", "1 GIFTING - 1day") - customers can't
     * tell 20 from 20MB from 20GB. There's no unit field in their API
     * response to read it from, so it's inferred from price-per-GB
     * sanity, validated against the full real catalog:
     *   - Any decimal value (1.2, 3.5, 12.5, 3.072, ...) is always GB -
     *     MB values never appear with decimals in this catalog.
     *   - Whole numbers under 20 are always GB (nothing that small is
     *     ever sold as MB here).
     *   - Whole numbers 20+ are ambiguous by magnitude alone (e.g. "20"
     *     is 20MB for a ~N25 1-day bundle, but "20" is also 20GB for a
     *     ~N7,455 30-day bundle) - resolved by computing the implied
     *     price-per-GB under the GB interpretation: real GB pricing in
     *     this catalog never drops below ~N145/GB even at the largest
     *     bulk discount (680GB/800GB tiers), so anything that would
     *     imply a price under N100/GB must actually be MB.
     */
    private static function withSizeUnit(string $name, float $amount): string
    {
        if (! preg_match('/^([\d.]+)/', trim($name), $matches)) {
            return $name;
        }

        $rawNumber = $matches[1];
        $value = (float) $rawNumber;

        if (str_contains($rawNumber, '.') || $value < 20) {
            $unit = 'GB';
        } else {
            $impliedPricePerGb = $amount / $value;
            $unit = $impliedPricePerGb < 100 ? 'MB' : 'GB';
        }

        return preg_replace('/^([\d.]+)/', $rawNumber . $unit, $name, 1);
    }
}
