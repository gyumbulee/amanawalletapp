<?php

namespace App\Services;

use App\Contracts\Providers\EpinsProviderInterface;
use App\Enums\RechargeCardBatchStatus;
use App\Models\Admin;
use App\Models\RechargeCard;
use App\Models\RechargeCardBatch;
use Illuminate\Support\Facades\DB;
use Throwable;

class RechargeCardService
{
    public function __construct(protected EpinsProviderInterface $provider)
    {
    }

    public function generateBatch(Admin $admin, string $network, float $denomination, int $quantity): RechargeCardBatch
    {
        $batch = RechargeCardBatch::query()->create([
            'network' => $network,
            'denomination' => $denomination,
            'quantity' => $quantity,
            'status' => RechargeCardBatchStatus::Pending,
            'generated_by' => $admin->id,
        ]);

        try {
            $cards = $this->provider->generateCards($network, $denomination, $quantity);

            DB::transaction(function () use ($cards, $batch, $network, $denomination) {
                foreach ($cards as $card) {
                    RechargeCard::query()->create([
                        'batch_id' => $batch->id,
                        'network' => $network,
                        'denomination' => $denomination,
                        'serial_number' => $card['serial_number'],
                        'pin' => $card['pin'],
                    ]);
                }
            });

            $batch->update(['status' => RechargeCardBatchStatus::Completed]);
        } catch (Throwable $e) {
            $batch->update([
                'status' => RechargeCardBatchStatus::Failed,
                'failure_reason' => $e->getMessage(),
            ]);
        }

        return $batch->refresh();
    }

    public function markPrinted(RechargeCard $card): RechargeCard
    {
        $card->update(['is_printed' => true]);

        return $card->refresh();
    }
}