<?php

namespace App\Services;

use App\Models\Provider;
use App\Services\Providers\BigiSubElectricityProvider;

/**
 * Electricity is routed to Bigisub strictly - no VTpass fallback. See
 * AirtimeProviderResolver for the full split rationale.
 */
class ElectricityProviderResolver
{
    public function __construct(
        protected BigiSubElectricityProvider $bigisub,
    ) {
    }

    /**
     * @return array<string, \App\Contracts\Providers\ElectricityProviderInterface>
     */
    public function resolve(): array
    {
        $isActive = Provider::query()->where('slug', 'bigisub')->value('is_active') ?? true;

        return $isActive ? ['bigisub' => $this->bigisub] : [];
    }
}