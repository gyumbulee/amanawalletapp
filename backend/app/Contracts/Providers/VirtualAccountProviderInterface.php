<?php

namespace App\Contracts\Providers;

use App\Models\User;

interface VirtualAccountProviderInterface
{
    /**
     * Create a dedicated virtual account for the given user.
     *
     * @return array{account_number: string, account_name: string, bank_name: string, reference: string}
     */
    public function createDedicatedVirtualAccount(User $user): array;

    /**
     * Verify that an inbound webhook signature genuinely came from this provider.
     */
    public function verifyWebhookSignature(string $signature): bool;
}