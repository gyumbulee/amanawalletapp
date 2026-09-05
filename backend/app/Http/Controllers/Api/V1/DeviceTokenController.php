<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Notifications\RegisterDeviceTokenRequest;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    /**
     * Register (or re-point ownership of) a device's FCM token. Called on
     * login and on token-refresh - safe to call repeatedly with the same
     * token, it's an upsert.
     */
    public function store(RegisterDeviceTokenRequest $request): JsonResponse
    {
        // A token is unique globally (see migration comment): if the same
        // physical device token shows up under a different account (shared
        // device, account switch on the same phone), reassign it here
        // rather than erroring on the unique constraint - the old owner no
        // longer has that token active on their session anyway.
        DeviceToken::query()->updateOrCreate(
            ['token' => $request->validated('token')],
            [
                'user_id' => $request->user()->id,
                'platform' => $request->validated('platform'),
            ],
        );

        return response()->json(['message' => 'Device token registered.']);
    }

    /**
     * Unregister a device token, called on logout so a shared/former
     * device stops receiving push notifications for this account.
     */
    public function destroy(Request $request): JsonResponse
    {
        $request->validate(['token' => ['required', 'string']]);

        DeviceToken::query()
            ->where('user_id', $request->user()->id)
            ->where('token', $request->input('token'))
            ->delete();

        return response()->json(['message' => 'Device token unregistered.']);
    }
}
