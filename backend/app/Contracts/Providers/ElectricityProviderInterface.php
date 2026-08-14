<?php

namespace App\Contracts\Providers;

interface ElectricityProviderInterface
{
    /**
     * @return array{customer_name: string, customer_address: ?string}
     *
     * @throws \Throwable if the meter number is invalid.
     */
    public function verifyMeter(string $disco, string $meterNumber, string $meterType): array;

    /**
     * @return array{provider_reference: string, status: string, token: ?string, customer_name: string}
     *
     * @throws \Throwable on failure - caller is responsible for fallback/reversal.
     */
    public function payBill(string $disco, string $meterType, string $meterNumber, float $amount, string $phone, string $reference): array;
}