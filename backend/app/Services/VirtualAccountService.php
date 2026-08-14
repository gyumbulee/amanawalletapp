<?php

namespace App\Services;

use App\Contracts\Providers\VirtualAccountProviderInterface;
use App\Enums\KycStatus;
use App\Enums\KycType;
use App\Enums\VirtualAccountStatus;
use App\Models\Kyc;
use App\Models\User;
use App\Models\VirtualAccount;
use App\Repositories\Interfaces\VirtualAccountRepositoryInterface;
use Illuminate\Support\Facades\Log;
use Throwable;

class VirtualAccountService
{
    public function __construct(
        protected VirtualAccountRepositoryInterface $virtualAccountRepository,
        protected VirtualAccountProviderInterface $provider,
    ) {
    }

    public function provisionForUser(User $user): VirtualAccount
    {
        $account = $this->virtualAccountRepository->firstOrCreatePending($user);

        if ($account->status === VirtualAccountStatus::Active) {
            return $account;
        }

        try {
            $result = $this->provider->createDedicatedVirtualAccount($user);

            $account = $this->virtualAccountRepository->update($account, [
                'account_number' => $result['account_number'],
                'account_name' => $result['account_name'],
                'bank_name' => $result['bank_name'],
                'provider_reference' => $result['reference'],
                'status' => VirtualAccountStatus::Active,
                'failure_reason' => null,
            ]);

            $user->forceFill([
                'bvn_verified_at' => now(),
            ])->save();

            $this->recordKyc($user, KycStatus::Verified, null);

            return $account;
        } catch (Throwable $e) {
            Log::error('Virtual account provisioning failed', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);

            $this->recordKyc(
                $user,
                KycStatus::Rejected,
                $e->getMessage()
            );

            return $this->virtualAccountRepository->update($account, [
                'status' => VirtualAccountStatus::Failed,
                'failure_reason' => $e->getMessage(),
            ]);
        }
    }

    protected function recordKyc(
        User $user,
        KycStatus $status,
        ?string $rejectionReason
    ): void {
        Kyc::query()->updateOrCreate(
            [
                'user_id' => $user->id,
                'type' => KycType::Bvn,
            ],
            [
                'status' => $status,
                'reference' => $user->bvn,
                'rejection_reason' => $rejectionReason,
                'verified_at' => $status === KycStatus::Verified
                    ? now()
                    : null,
            ]
        );
    }
}