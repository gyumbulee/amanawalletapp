<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Airtime\PurchaseAirtimeRequest;
use App\Http\Resources\TransactionResource;
use App\Services\AirtimeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use RuntimeException;

class AirtimeController extends Controller
{
    public function __construct(protected AirtimeService $airtimeService)
    {
    }

    public function purchase(PurchaseAirtimeRequest $request): JsonResponse
    {
        try {
            $transaction = $this->airtimeService->purchase(
                user: $request->user(),
                network: $request->network,
                phone: $request->phone,
                amount: (float) $request->amount,
                pin: $request->pin,
            );

            return response()->json([
                'message' => 'Airtime purchase successful.',
                'transaction' => new TransactionResource($transaction),
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => $e->getMessage(),
                'errors' => $e->errors(),
            ], 422);
        } catch (RuntimeException $e) {
            return response()->json([
                'message' => $e->getMessage(),
            ], 422);
        }
    }
}