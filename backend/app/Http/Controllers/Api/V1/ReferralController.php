<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ReferralEarning;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReferralController extends Controller
{
    public function summary(Request $request): JsonResponse
    {
        $user = $request->user();

        $count = User::query()->where('referred_by', $user->id)->count();
        $totalEarnings = ReferralEarning::query()->where('referrer_id', $user->id)->sum('amount');

        return response()->json([
            'referral_code' => $user->referral_code,
            'referral_count' => $count,
            'total_earnings' => (float) $totalEarnings,
        ]);
    }

    public function history(Request $request): JsonResponse
    {
        $earnings = ReferralEarning::query()
            ->where('referrer_id', $request->user()->id)
            ->with('referredUser:id,first_name,last_name')
            ->latest()
            ->paginate((int) $request->query('per_page', 20));

        $data = $earnings->through(fn ($earning) => [
            'id' => $earning->uuid,
            'referred_user' => $earning->referredUser->first_name . ' ' . $earning->referredUser->last_name,
            'amount' => (float) $earning->amount,
            'created_at' => $earning->created_at,
        ]);

        return response()->json([
            'earnings' => $data->items(),
            'meta' => [
                'current_page' => $earnings->currentPage(),
                'last_page' => $earnings->lastPage(),
                'total' => $earnings->total(),
            ],
        ]);
    }
}