<?php

namespace App\Services;

use App\Services\Concerns\ResolvesProvidersByService;
use App\Services\Providers\VtpassCableProvider;

class CableProviderResolver
{
    use ResolvesProvidersByService;

    public function __construct(protected VtpassCableProvider $vtpass)
    {
    }

    /**
     * @return array<string, \App\Contracts\Providers\CableProviderInterface>
     */
    public function resolve(): array
    {
        return $this->resolveForService('cable', ['vtpass' => $this->vtpass]);
    }
}
