<?php

namespace App\Contracts\Providers;

interface CableProviderInterface
{
    /**
     * @return array<int, array{variation_code: string, name: string, amount: float}>
     */
    public function listPlans(string $cableProvider): array;

    /**
     * @return array{customer_name: string, customer_number: string, status: ?string}
     *
     * @throws \Throwable if the smartcard number is invalid.
     */
    public function verifySmartcard(string $cableProvider, string $smartcardNumber): array;

    /**
     * @return array{provider_reference: string, status: string, customer_name: string}
     *
     * @throws \Throwable on failure - caller is responsible for reversal.
     */
    public function subscribe(string $cableProvider, string $smartcardNumber, string $variationCode, float $amount, string $phone, string $reference): array;
}