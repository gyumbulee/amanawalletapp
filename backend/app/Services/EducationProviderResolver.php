<?php

namespace App\Services;

use App\Models\Provider;
use App\Services\Providers\VtpassEducationProvider;

class EducationProviderResolver
{
    public function __construct(protected VtpassEducationProvider $vtpass)
    {
    }

    /**
     * @return array<string, \App\Contracts\Providers\EducationProviderInterface>
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