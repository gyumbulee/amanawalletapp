<?php

namespace App\Services;

use App\Services\Concerns\ResolvesProvidersByService;
use App\Services\Providers\BigiSubDataProvider;
use App\Services\Providers\VtpassDataProvider;

class DataProviderResolver
{
    use ResolvesProvidersByService;

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
        return $this->resolveForService('data', [
            'vtpass' => $this->vtpass,
            'bigisub' => $this->bigisub,
        ]);
    }
}
