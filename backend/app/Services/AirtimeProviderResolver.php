<?php

namespace App\Services;

use App\Models\Provider;
use App\Services\Providers\BigiSubAirtimeProvider;
use App\Services\Providers\VtpassAirtimeProvider;

class AirtimeProviderResolver
{
    public function __construct(
        protected VtpassAirtimeProvider $vtpass,
        protected BigiSubAirtimeProvider $bigisub,
    ) {
    }

    /**
     * @return array<string, \App\Contracts\Providers\AirtimeProviderInterface> slug => provider, in priority order
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