<?php

namespace App\Services;

use App\Models\Provider;
use App\Services\Providers\BigiSubElectricityProvider;
use App\Services\Providers\VtpassElectricityProvider;

class ElectricityProviderResolver
{
    public function __construct(
        protected VtpassElectricityProvider $vtpass,
        protected BigiSubElectricityProvider $bigisub,
    ) {
    }

    /**
     * @return array<string, \App\Contracts\Providers\ElectricityProviderInterface>
     */
    public function resolve(): array
    {
        $providers = ['vtpass' => $this->vtpass, 'bigisub' => $this->bigisub];

        $activeSlugs = Provider::query()
            ->whereIn('slug', array_keys($providers))
            ->where('is_active', true)
            ->orderBy('priority')
            ->pluck('slug');

        $chain = [];

        foreach ($activeSlugs as $slug) {
            $chain[$slug] = $providers[$slug];
        }

        return $chain;
    }
}