<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\ChangePasswordRequest;
use App\Http\Requests\Profile\SetTransactionPinRequest;
use App\Http\Requests\Profile\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Services\VirtualAccountService;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\Storage;
use RuntimeException;

class ProfileController extends Controller
{
    public function __construct(
        protected WalletService $walletService,
        protected VirtualAccountService $virtualAccountService,
    ) {
    }

    public function update(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $user->update($request->validated());

        return response()->json([
            'message' => 'Profile updated successfully.',
            'user' => new UserResource($user->fresh()),
        ]);
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $user = $request->user();

        if (! Hash::check($request->current_password, $user->password)) {
            throw ValidationException::withMessages([
                'current_password' => ['Your current password is incorrect.'],
            ]);
        }

        $user->update(['password' => Hash::make($request->password)]);

        // Revoke all other sessions for security - keep only the current one.
        $currentTokenId = $request->user()->currentAccessToken()?->id;
        $user->tokens()->where('id', '!=', $currentTokenId)->delete();

        return response()->json(['message' => 'Password changed successfully.']);
    }

    public function setTransactionPin(SetTransactionPinRequest $request): JsonResponse
    {
        $wallet = $request->user()->wallet;

        $this->walletService->setPin($wallet, $request->pin, $request->current_pin);

        return response()->json(['message' => 'Transaction PIN set successfully.']);
    }

    public function verifyBvn(Request $request): JsonResponse
    {
        $request->validate([
            'bvn' => ['required', 'string', 'digits:11'],
        ]);

        $user = $request->user();
        $user->update(['bvn' => $request->bvn, 'bvn_verified_at' => null]);

        try {
            $account = $this->virtualAccountService->provisionForUser($user->fresh());

            return response()->json([
                'message' => $account->status->value === 'active'
                    ? 'BVN verified and virtual account provisioned successfully.'
                    : 'BVN verification failed.',
                'virtual_account_status' => $account->status->value,
                'failure_reason' => $account->failure_reason,
            ]);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }

    public function uploadPhoto(Request $request): JsonResponse
    {
        $request->validate([
            'photo' => ['required', 'image', 'max:2048'],
        ]);

        $user = $request->user();

        if ($user->profile_photo_path) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($user->profile_photo_path);
        }

        $path = $request->file('photo')->store('profile-photos', 'public');
        $user->update(['profile_photo_path' => $path]);

        return response()->json([
            'message' => 'Profile photo uploaded successfully.',
            'profile_photo_url' => \Illuminate\Support\Facades\Storage::disk('public')->url($path),
        ]);
    }

    public function showPhoto(string $filename)
    {
        $filename = basename($filename);
        $path = 'profile-photos/' . $filename;

        if (! Storage::disk('public')->exists($path)) {
            abort(404);
        }

        return response()->file(
            Storage::disk('public')->path($path)
        );
    }
}