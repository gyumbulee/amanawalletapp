<?php

namespace App\Services;

use App\Models\Provider;
use App\Services\Providers\BigiSubDataProvider;
use App\Services\Providers\VtpassDataProvider;

class DataProviderResolver
{
    public function __construct(
        protected VtpassDataProvider $vtpass,
        protected BigiSubDataProvider $bigisub,
    ) {
    }

    /**
     * @return array<string, \App\Contracts\Providers\DataProviderInterface>
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