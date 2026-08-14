<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\EducationType;
use App\Http\Controllers\Controller;
use App\Http\Requests\Education\PurchaseEducationRequest;
use App\Http\Resources\TransactionResource;
use App\Services\EducationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rules\Enum;
use RuntimeException;

class EducationController extends Controller
{
    public function __construct(protected EducationService $educationService)
    {
    }

    public function plans(Request $request): JsonResponse
    {
        $request->validate([
            'education_type' => ['required', new Enum(EducationType::class)],
        ]);

        try {
            $plans = $this->educationService->listPlans($request->query('education_type'));

            return response()->json(['plans' => $plans]);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function verifyProfile(Request $request): JsonResponse
    {
        $request->validate([
            'education_type' => ['required', new Enum(EducationType::class)],
            'profile_id' => ['required', 'string'],
            'variation_code' => ['required', 'string'],
        ]);

        try {
            $result = $this->educationService->verifyProfile($request->education_type, $request->profile_id);

            return response()->json($result);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function purchase(PurchaseEducationRequest $request): JsonResponse
    {
        try {
            $transaction = $this->educationService->purchase(
                user: $request->user(),
                educationType: $request->education_type,
                variationCode: $request->variation_code,
                phone: $request->phone,
                profileId: $request->profile_id,
                pin: $request->pin,
            );

            return response()->json([
                'message' => 'Education PIN purchase successful.',
                'transaction' => new TransactionResource($transaction),
            ]);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }
}