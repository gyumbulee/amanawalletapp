<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\AirtimeNetwork;
use App\Http\Controllers\Controller;
use App\Http\Requests\Data\PurchaseDataRequest;
use App\Http\Resources\TransactionResource;
use App\Services\DataService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Enum;
use RuntimeException;

class DataController extends Controller
{
    public function __construct(protected DataService $dataService)
    {
    }

    public function plans(Request $request): JsonResponse
    {
        $request->validate([
            'network' => ['required', new Enum(AirtimeNetwork::class)],
        ]);

        try {
            $plans = $this->dataService->listPlans($request->query('network'));

            return response()->json(['plans' => $plans]);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function purchase(PurchaseDataRequest $request): JsonResponse
    {
        try {
            $transaction = $this->dataService->purchase(
                user: $request->user(),
                network: $request->network,
                phone: $request->phone,
                variationCode: $request->variation_code,
                pin: $request->pin,
            );

            return response()->json([
                'message' => 'Data purchase successful.',
                'transaction' => new TransactionResource($transaction),
            ]);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }
}