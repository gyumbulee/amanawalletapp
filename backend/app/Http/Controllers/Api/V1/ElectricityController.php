<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Electricity\PurchaseElectricityRequest;
use App\Http\Requests\Electricity\VerifyMeterRequest;
use App\Http\Resources\TransactionResource;
use App\Services\ElectricityService;
use Illuminate\Http\JsonResponse;
use RuntimeException;

class ElectricityController extends Controller
{
    public function __construct(protected ElectricityService $electricityService)
    {
    }

    public function verifyMeter(VerifyMeterRequest $request): JsonResponse
    {
        try {
            $result = $this->electricityService->verifyMeter(
                $request->disco,
                $request->meter_number,
                $request->meter_type
            );

            return response()->json($result);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function purchase(PurchaseElectricityRequest $request): JsonResponse
    {
        try {
            $transaction = $this->electricityService->purchase(
                user: $request->user(),
                disco: $request->disco,
                meterNumber: $request->meter_number,
                meterType: $request->meter_type,
                amount: (float) $request->amount,
                phone: $request->phone,
                pin: $request->pin,
            );

            return response()->json([
                'message' => 'Electricity payment successful.',
                'transaction' => new TransactionResource($transaction),
            ]);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }
}