<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\RechargeCard\GenerateBatchRequest;
use App\Http\Resources\RechargeCardBatchResource;
use App\Http\Resources\RechargeCardResource;
use App\Models\RechargeCard;
use App\Models\RechargeCardBatch;
use App\Services\RechargeCardService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RechargeCardController extends Controller
{
    public function __construct(protected RechargeCardService $rechargeCardService)
    {
    }

    public function generateBatch(GenerateBatchRequest $request): JsonResponse
    {
        $batch = $this->rechargeCardService->generateBatch(
            admin: $request->user(),
            network: $request->network,
            denomination: (float) $request->denomination,
            quantity: (int) $request->quantity,
        );

        return response()->json([
            'message' => $batch->status->value === 'completed'
                ? 'Recharge card batch generated successfully.'
                : 'Recharge card batch generation failed.',
            'batch' => new RechargeCardBatchResource($batch->load('generatedBy')),
        ], $batch->status->value === 'completed' ? 201 : 422);
    }

    public function batches(Request $request): JsonResponse
    {
        $batches = RechargeCardBatch::query()
            ->with('generatedBy')
            ->when($request->query('network'), fn ($q, $network) => $q->where('network', $network))
            ->when($request->query('status'), fn ($q, $status) => $q->where('status', $status))
            ->latest()
            ->paginate((int) $request->query('per_page', 20));

        return response()->json([
            'batches' => RechargeCardBatchResource::collection($batches),
            'meta' => [
                'current_page' => $batches->currentPage(),
                'last_page' => $batches->lastPage(),
                'total' => $batches->total(),
            ],
        ]);
    }

    public function cards(Request $request): JsonResponse
    {
        $cards = RechargeCard::query()
            ->when($request->query('network'), fn ($q, $network) => $q->where('network', $network))
            ->when($request->query('batch_id'), fn ($q, $batchUuid) => $q->whereHas('batch', fn ($b) => $b->where('uuid', $batchUuid)))
            ->when($request->query('is_printed') !== null, fn ($q) => $q->where('is_printed', filter_var($request->query('is_printed'), FILTER_VALIDATE_BOOLEAN)))
            ->when($request->query('search'), fn ($q, $search) => $q->where('serial_number', 'like', "%{$search}%"))
            ->latest()
            ->paginate((int) $request->query('per_page', 20));

        return response()->json([
            'cards' => RechargeCardResource::collection($cards),
            'meta' => [
                'current_page' => $cards->currentPage(),
                'last_page' => $cards->lastPage(),
                'total' => $cards->total(),
            ],
        ]);
    }

    public function markPrinted(Request $request, string $uuid): JsonResponse
    {
        $card = RechargeCard::query()->where('uuid', $uuid)->firstOrFail();

        $card = $this->rechargeCardService->markPrinted($card);

        return response()->json(['card' => new RechargeCardResource($card)]);
    }
}