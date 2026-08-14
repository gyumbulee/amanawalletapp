<?php

namespace App\Contracts\Providers;

interface AirtimeProviderInterface
{
    /**
     * @return array{provider_reference: string}
     *
     * @throws \Throwable on failure - caller is responsible for fallback/reversal.
     */
    public function purchase(string $network, string $phone, float $amount, string $reference): array;
}