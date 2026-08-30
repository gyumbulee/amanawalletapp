<?php

namespace App\Services;

use App\Services\Concerns\ResolvesProvidersByService;
use App\Services\Providers\BigiSubElectricityProvider;
use App\Services\Providers\VtpassElectricityProvider;

class ElectricityProviderResolver
{
    use ResolvesProvidersByService;

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
        return $this->resolveForService('electricity', [
            'vtpass' => $this->vtpass,
            'bigisub' => $this->bigisub,
        ]);
    }
}
