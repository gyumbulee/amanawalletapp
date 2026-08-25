<?php

namespace App\Services;

use App\Models\Provider;
use App\Services\Providers\BigiSubCableProvider;

/**
 * Cable is routed to Bigisub strictly - no VTpass fallback. See
 * AirtimeProviderResolver for the full split rationale. Previously
 * VTpass-only (no Bigisub cable implementation existed); now the reverse.
 */
class CableProviderResolver
{
    public function __construct(protected BigiSubCableProvider $bigisub)
    {
    }

    /**
     * @return array<string, \App\Contracts\Providers\CableProviderInterface>
     */
    public function resolve(): array
    {
        $chain = [];

        if ($this->isActive('bigisub')) {
            $chain['bigisub'] = $this->bigisub;
        }

        return $chain;
    }

    protected function isActive(string $slug): bool
    {
        $provider = Provider::query()->where('slug', $slug)->first();

        return $provider?->is_active ?? true;
    }
}