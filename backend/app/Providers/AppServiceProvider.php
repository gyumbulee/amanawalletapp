<?php

namespace App\Providers;

use App\Events\TransactionFailed;
use App\Events\TransactionSuccessful;
use App\Events\UserRegistered;
use App\Listeners\AwardReferralBonus;
use App\Listeners\CreateWalletForNewUser;
use App\Listeners\ProvisionVirtualAccountForNewUser;
use App\Listeners\SendTransactionFailedNotification;
use App\Listeners\SendTransactionSuccessfulNotification;
use App\Models\Admin;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        Event::listen(UserRegistered::class, CreateWalletForNewUser::class);
        Event::listen(UserRegistered::class, ProvisionVirtualAccountForNewUser::class);
        Event::listen(TransactionSuccessful::class, AwardReferralBonus::class);
        Event::listen(TransactionSuccessful::class, SendTransactionSuccessfulNotification::class);
        Event::listen(TransactionFailed::class, SendTransactionFailedNotification::class);

        // super-admin bypasses every Policy/permission check — no need to
        // grant individual permissions to that role.
        Gate::before(function ($user, string $ability) {
            return $user instanceof Admin && $user->hasRole('super-admin') ? true : null;
        });
    }
}