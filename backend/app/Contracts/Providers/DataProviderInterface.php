<?php

namespace App\Contracts\Providers;

interface DataProviderInterface
{
    /**
     * @return array<int, array{variation_code: string, name: string, amount: float}>
     */
    public function listPlans(string $network): array;

    /**
     * @return array{provider_reference: string, status: string}
     *
     * @throws \Throwable on failure - caller is responsible for fallback/reversal.
     */
    public function purchase(string $network, string $phone, string $variationCode, float $amount, string $reference): array;
}