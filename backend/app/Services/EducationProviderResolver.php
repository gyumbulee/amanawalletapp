<?php

namespace App\Services;

use App\Services\Concerns\ResolvesProvidersByService;
use App\Services\Providers\VtpassEducationProvider;

class EducationProviderResolver
{
    use ResolvesProvidersByService;

    public function __construct(protected VtpassEducationProvider $vtpass)
    {
    }

    /**
     * @return array<string, \App\Contracts\Providers\EducationProviderInterface>
     */
    public function resolve(): array
    {
        return $this->resolveForService('education', ['vtpass' => $this->vtpass]);
    }
}
