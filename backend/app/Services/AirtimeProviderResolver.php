<?php

namespace App\Services;

use App\Services\Concerns\ResolvesProvidersByService;
use App\Services\Providers\BigiSubAirtimeProvider;
use App\Services\Providers\VtpassAirtimeProvider;

class AirtimeProviderResolver
{
    use ResolvesProvidersByService;

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
        return $this->resolveForService('airtime', [
            'vtpass' => $this->vtpass,
            'bigisub' => $this->bigisub,
        ]);
    }
}
