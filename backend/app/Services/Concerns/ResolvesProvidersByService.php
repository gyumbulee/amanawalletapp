<?php

namespace App\Services\Concerns;

use App\Models\ProviderServicePriority;

/**
 * Shared by every *ProviderResolver. Looks up active providers for a given
 * service from provider_service_priorities (per-service), NOT from the
 * old global Provider::is_active/priority (which was shared across every
 * service and couldn't express "BigiSub for Data only").
 */
trait ResolvesProvidersByService
{
    /**
     * @param  string  $service  e.g. 'airtime', 'data', 'electricity', 'cable', 'education'
     * @param  array<string, object>  $availableProviders  slug => provider instance, for every
     *         provider this service *could* use (whether or not currently active)
     * @return array<string, object> slug => provider instance, in priority order
     */
    protected function resolveForService(string $service, array $availableProviders): array
    {
        $activeSlugs = ProviderServicePriority::query()
            ->join('providers', 'providers.id', '=', 'provider_service_priorities.provider_id')
            ->where('provider_service_priorities.service', $service)
            ->where('provider_service_priorities.is_active', true)
            ->where('providers.is_active', true)
            ->whereIn('providers.slug', array_keys($availableProviders))
            ->orderBy('provider_service_priorities.priority')
            ->pluck('providers.slug');

        $chain = [];

        foreach ($activeSlugs as $slug) {
            $chain[$slug] = $availableProviders[$slug];
        }

        return $chain;
    }
}
