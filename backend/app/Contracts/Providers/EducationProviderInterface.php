<?php

namespace App\Contracts\Providers;

interface EducationProviderInterface
{
    /**
     * @return array<int, array{variation_code: string, name: string, amount: float}>
     */
    public function listPlans(string $educationType): array;

    /**
     * Only meaningful for JAMB (profile ID verification). Returns an empty
     * array for services that don't require pre-purchase verification (e.g. WAEC).
     *
     * @throws \Throwable if the profile ID is invalid.
     */
    public function verifyProfile(string $educationType, string $profileId): array;

    /**
     * @return array{provider_reference: string, status: string, pin: ?string, serial: ?string}
     *
     * @throws \Throwable on failure - caller is responsible for reversal.
     */
    public function purchase(string $educationType, string $variationCode, float $amount, string $phone, ?string $profileId, string $reference): array;
}