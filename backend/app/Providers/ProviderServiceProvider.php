<?php

namespace App\Providers;

use App\Contracts\Providers\EpinsProviderInterface;
use App\Contracts\Providers\VirtualAccountProviderInterface;
use App\Services\Providers\EpinsProvider;
use App\Services\Providers\FlutterwaveProvider;
use Illuminate\Support\ServiceProvider;

class ProviderServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(VirtualAccountProviderInterface::class, FlutterwaveProvider::class);
        $this->app->bind(EpinsProviderInterface::class, EpinsProvider::class);
    }

    public function boot(): void
    {
        //
    }
}