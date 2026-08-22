<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\WalletLedgerResource;
use App\Http\Resources\WalletResource;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    public function __construct(protected WalletService $walletService)
    {
    }

    public function show(Request $request): JsonResponse
    {
        $wallet = $this->walletService->getWalletForUser($request->user());

        return response()->json([
            'wallet' => new WalletResource($wallet),
        ]);
    }

    public function ledgers(Request $request): JsonResponse
    {
        $wallet = $this->walletService->getWalletForUser($request->user());

        $ledgers = $wallet->ledgers()->latest()->paginate(20);

        return response()->json([
            'ledgers' => WalletLedgerResource::collection($ledgers),
            'meta' => [
                'current_page' => $ledgers->currentPage(),
                'last_page' => $ledgers->lastPage(),
                'total' => $ledgers->total(),
            ],
        ]);
    }
}