<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Providers\VirtualAccountProviderInterface;
use App\Http\Controllers\Controller;
use App\Jobs\ProcessFlutterwaveWebhook;
use App\Jobs\ProcessVtpassWebhook;
use App\Models\Webhook;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WebhookController extends Controller
{
    public function __construct(protected VirtualAccountProviderInterface $provider) {}

    public function flutterwave(Request $request): JsonResponse
    {
        $signature = $request->header('verif-hash', '');

        if (! $this->provider->verifyWebhookSignature($signature)) {
            return response()->json(['message' => 'Invalid signature.'], 401);
        }

        $webhook = Webhook::query()->create([
            'provider' => 'flutterwave',
            'event_type' => $request->input('event'),
            'payload' => $request->all(),
            'signature' => $signature,
        ]);

        ProcessFlutterwaveWebhook::dispatch($webhook->id);

        return response()->json(['message' => 'Webhook received.']);
    }

    /**
     * VTpass sends no signature/HMAC on this callback (unlike Flutterwave's
     * verif-hash header), so there's nothing to verify here. We log the raw
     * payload for audit purposes and dispatch the job, which independently
     * requeries VTpass server-to-server before acting on anything - that's
     * where the actual trust decision happens.
     */
    public function vtpass(Request $request): JsonResponse
    {
        $webhook = Webhook::query()->create([
            'provider' => 'vtpass',
            'event_type' => $request->input('type', 'transaction-update'),
            'payload' => $request->all(),
            'signature' => null,
        ]);

        ProcessVtpassWebhook::dispatch($webhook->id);

        return response()->json(['message' => 'Webhook received.']);
    }
}
