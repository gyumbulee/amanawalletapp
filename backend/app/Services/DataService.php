<?php

namespace App\Services;

use App\Enums\TransactionType;
use App\Jobs\ProcessDataPurchase;
use App\Models\DataPlan;
use App\Models\Transaction;
use App\Models\User;
use RuntimeException;

class DataService
{
    public function __construct(
        protected TransactionService $transactionService,
        protected WalletService $walletService,
    ) {
    }

    /**
     * Plans now come from the persisted catalog (data_plans), not a live
     * provider call — this is what lets us charge a selling_price with
     * real margin instead of BigiSub's raw cost, and is also what powers
     * category grouping in the app. Run `php artisan data-plans:sync` to
     * refresh cost prices from BigiSub; admin-set selling prices persist.
     */
    public function listPlans(string $network, ?string $category = null): array
    {
        $query = DataPlan::query()->forNetwork($network)->active();

        if ($category) {
            $query->forCategory($category);
        }

        return $query->orderBy('selling_price')->get()
            ->map(fn (DataPlan $plan) => [
                'variation_code' => $plan->variation_code,
                'name' => $plan->name,
                'amount' => (float) $plan->selling_price,
                'category' => $plan->category->value,
                'category_label' => $plan->category->label(),
            ])->all();
    }

    /**
     * One row per category present for this network, with a plan count -
     * powers the "browse by category" screen (SME / Gifting / etc).
     */
    public function listCategories(string $network): array
    {
        return DataPlan::query()
            ->forNetwork($network)
            ->active()
            ->selectRaw('category, COUNT(*) as plan_count')
            ->groupBy('category')
            ->get()
            ->map(fn ($row) => [
                'key' => $row->category->value,
                'label' => $row->category->label(),
                'plan_count' => $row->plan_count,
            ])->all();
    }

    public function purchase(User $user, string $network, string $phone, string $variationCode, string $pin): Transaction
    {
        $wallet = $user->wallet;

        $this->walletService->verifyPin($wallet, $pin);

        // Look up the authoritative plan server-side - never trust a client-sent amount.
        $plan = DataPlan::query()
            ->forNetwork($network)
            ->where('variation_code', $variationCode)
            ->active()
            ->first();

        if (! $plan) {
            throw new RuntimeException('Selected data plan is not available.');
        }

        // What the customer pays (includes markup) vs. what BigiSub actually
        // charges us for this exact plan_id - these are deliberately different.
        $sellingPrice = (float) $plan->selling_price;
        $costPrice = (float) $plan->cost_price;

        $transaction = $this->transactionService->initiate(
            user: $user,
            wallet: $wallet,
            type: TransactionType::Data,
            amount: $sellingPrice,
            description: "Data purchase - {$network} - {$plan->name} - {$phone}",
            meta: [
                'network' => $network,
                'phone' => $phone,
                'variation_code' => $variationCode,
                'plan_name' => $plan->name,
                'cost_price' => $costPrice,
                'revenue' => $sellingPrice - $costPrice,
            ],
        );

        $this->walletService->debit($wallet, $sellingPrice, $transaction->reference, 'Data purchase', $transaction);
        $this->transactionService->markProcessing($transaction);

        ProcessDataPurchase::dispatch($transaction->id, $network, $phone, $variationCode, $costPrice, $sellingPrice);

        return $transaction;
    }
}