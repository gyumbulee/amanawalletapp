<?php

namespace App\Contracts\Providers;

interface EpinsProviderInterface
{
    /**
     * @return array<int, array{serial_number: string, pin: string}>
     *
     * @throws \Throwable on failure.
     */
    public function generateCards(string $network, float $denomination, int $quantity): array;
}