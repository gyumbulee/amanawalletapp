<?php

namespace App\Services;

use App\Models\Provider;
use App\Services\Providers\BigiSubDataProvider;

/**
 * Data is routed to Bigisub strictly - no VTpass fallback. Deliberate
 * product decision, not a technical limitation - see
 * AirtimeProviderResolver for the other half of the split (Airtime stays
 * VTpass-only).
 */
class DataProviderResolver
{
    public function __construct(
        protected BigiSubDataProvider $bigisub,
    ) {
    }

    /**
     * @return array<string, \App\Contracts\Providers\DataProviderInterface>
     */
    public function resolve(): array
    {
        $isActive = Provider::query()->where('slug', 'bigisub')->value('is_active') ?? true;

        return $isActive ? ['bigisub' => $this->bigisub] : [];
    }
}