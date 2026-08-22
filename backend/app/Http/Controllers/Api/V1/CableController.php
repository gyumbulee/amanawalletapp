<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\CableProvider;
use App\Http\Controllers\Controller;
use App\Http\Requests\Cable\PurchaseCableRequest;
use App\Http\Requests\Cable\VerifySmartcardRequest;
use App\Http\Resources\TransactionResource;
use App\Services\CableService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Enum;
use RuntimeException;

class CableController extends Controller
{
    public function __construct(protected CableService $cableService)
    {
    }

    public function plans(Request $request): JsonResponse
    {
        $request->validate([
            'cable_provider' => ['required', new Enum(CableProvider::class)],
        ]);

        try {
            $plans = $this->cableService->listPlans($request->query('cable_provider'));

            return response()->json(['plans' => $plans]);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function verifySmartcard(VerifySmartcardRequest $request): JsonResponse
    {
        try {
            $result = $this->cableService->verifySmartcard($request->cable_provider, $request->smartcard_number);

            return response()->json($result);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function purchase(PurchaseCableRequest $request): JsonResponse
    {
        try {
            $transaction = $this->cableService->purchase(
                user: $request->user(),
                cableProvider: $request->cable_provider,
                smartcardNumber: $request->smartcard_number,
                variationCode: $request->variation_code,
                phone: $request->phone,
                pin: $request->pin,
            );

            return response()->json([
                'message' => 'Cable TV subscription successful.',
                'transaction' => new TransactionResource($transaction),
            ]);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }
}