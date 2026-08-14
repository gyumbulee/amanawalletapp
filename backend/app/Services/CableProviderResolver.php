<?php

namespace App\Services;

use App\Models\Provider;
use App\Services\Providers\VtpassCableProvider;

class CableProviderResolver
{
    public function __construct(protected VtpassCableProvider $vtpass)
    {
    }

    /**
     * @return array<string, \App\Contracts\Providers\CableProviderInterface>
     */
    public function resolve(): array
    {
        $chain = [];

        if ($this->isActive('vtpass')) {
            $chain['vtpass'] = $this->vtpass;
        }

        return $chain;
    }

    protected function isActive(string $slug): bool
    {
        $provider = Provider::query()->where('slug', $slug)->first();

        return $provider?->is_active ?? true;
    }
}