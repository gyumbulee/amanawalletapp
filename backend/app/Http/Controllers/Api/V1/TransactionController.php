<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\TransactionResource;
use App\Repositories\Interfaces\TransactionRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    public function __construct(protected TransactionRepositoryInterface $transactionRepository)
    {
    }

    public function index(Request $request): JsonResponse
    {
        $transactions = $this->transactionRepository->paginateForUser(
            $request->user(),
            (int) $request->query('per_page', 20),
            $request->only(['type', 'status'])
        );

        return response()->json([
            'transactions' => TransactionResource::collection($transactions),
            'meta' => [
                'current_page' => $transactions->currentPage(),
                'last_page' => $transactions->lastPage(),
                'total' => $transactions->total(),
            ],
        ]);
    }

    public function show(Request $request, string $uuid): JsonResponse
    {
        $transaction = $this->transactionRepository->findByUuid($uuid);

        if (! $transaction || $transaction->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Transaction not found.'], 404);
        }

        return response()->json([
            'transaction' => new TransactionResource($transaction),
        ]);
    }
}