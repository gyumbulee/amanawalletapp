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
        // Was previously listing only ReferralEarning rows, which only
        // exist once a referred user makes a qualifying (>=N1000)
        // transaction. That made the count on the summary card disagree
        // with an apparently-empty list whenever someone had referred
        // people who simply hadn't transacted yet. Listing every referred
        // user (with their bonus status) keeps the two consistent.
        $referredUsers = User::query()
            ->where('referred_by', $request->user()->id)
            ->with('referralEarningTriggered')
            ->latest()
            ->paginate((int) $request->query('per_page', 20));

        $data = $referredUsers->through(fn (User $referred) => [
            'id' => $referred->uuid,
            'referee_name' => trim("{$referred->first_name} {$referred->last_name}"),
            'status' => $referred->referralEarningTriggered ? 'completed' : 'pending',
            'bonus_amount' => (float) ($referred->referralEarningTriggered->amount ?? 0),
            'created_at' => $referred->created_at,
        ]);

        return response()->json([
            'earnings' => $data->items(),
            'meta' => [
                'current_page' => $referredUsers->currentPage(),
                'last_page' => $referredUsers->lastPage(),
                'total' => $referredUsers->total(),
            ],
        ]);
    }
}