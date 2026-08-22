<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\VirtualAccountResource;
use App\Services\VirtualAccountService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VirtualAccountController extends Controller
{
    public function __construct(protected VirtualAccountService $virtualAccountService)
    {
    }

    public function show(Request $request): JsonResponse
    {
        $account = $request->user()->virtualAccount;

        if (! $account) {
            return response()->json([
                'message' => 'Virtual account has not been provisioned yet.',
            ], 404);
        }

        return response()->json([
            'virtual_account' => new VirtualAccountResource($account),
        ]);
    }

    public function retry(Request $request): JsonResponse
    {
        $account = $this->virtualAccountService->provisionForUser($request->user());

        return response()->json([
            'virtual_account' => new VirtualAccountResource($account),
        ]);
    }
}