<?php

namespace App\Services\Providers\Concerns;

use App\Models\Provider;

trait HasConfigurableTimeout
{
    protected function getTimeoutSeconds(string $slug): int
    {
        return Provider::query()->where('slug', $slug)->value('timeout_seconds') ?? 30;
    }
}