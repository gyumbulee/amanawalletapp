<?php

namespace App\Jobs;

use App\Enums\WebhookStatus;
use App\Models\Webhook;
use App\Services\Providers\VtpassRequeryService;
use App\Services\TransactionConfirmationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Throwable;

class ProcessVtpassWebhook implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, SerializesModels;

    /**
     * VTpass inner transaction statuses that map directly onto our
     * TransactionConfirmationService vocabulary ('delivered'/'failed'/'reversed').
     * Anything else (pending, initiated, or unrecognized) is left alone -
     * either the transaction isn't final yet, or the status is unexpected
     * enough that we'd rather flag it than guess.
     */
    protected const ACTIONABLE_STATUSES = ['delivered', 'failed', 'reversed'];

    public function __construct(public int $webhookId)
    {
    }

    public function handle(
        VtpassRequeryService $requeryService,
        TransactionConfirmationService $confirmationService
    ): void {
        $webhook = Webhook::query()->find($this->webhookId);

        if (! $webhook) {
            return;
        }

        try {
            $payload = $webhook->payload;

            // Our Transaction::reference is what we sent VTpass as request_id
            // when the purchase was made - it's the only reliable correlation
            // key back to our own record. VTpass echoes it back under several
            // possible keys depending on endpoint/version, so check them all.
            $requestId = $payload['requestId']
                ?? $payload['request_id']
                ?? $payload['content']['transactions']['unique_element']
                ?? null;

            if (! $requestId) {
                throw new \RuntimeException('Webhook payload missing requestId - cannot correlate to a transaction.');
            }

            // Never trust the webhook body's status directly - VTpass sends
            // no signature on this callback, so anyone who discovers the
            // callback URL could forge a payload (e.g. a fake "failed" status
            // on someone else's real pending transaction to trigger a bogus
            // refund). Requery VTpass server-to-server and act on that alone.
            $confirmed = $requeryService->requery($requestId);
            $status = $confirmed['status'];

            if (in_array($status, self::ACTIONABLE_STATUSES, true)) {
                $confirmationService->confirm($requestId, $status, $confirmed['provider_reference']);
            } else {
                Log::info('VTpass webhook requery returned a non-final status - leaving transaction as-is.', [
                    'webhook_id' => $webhook->id,
                    'request_id' => $requestId,
                    'status' => $status,
                ]);
            }

            $webhook->update([
                'status' => WebhookStatus::Processed,
                'processed_at' => now(),
            ]);
        } catch (Throwable $e) {
            Log::error('VTpass webhook processing failed', [
                'webhook_id' => $webhook->id,
                'error' => $e->getMessage(),
            ]);

            $webhook->update(['status' => WebhookStatus::Failed]);
        }
    }
}
