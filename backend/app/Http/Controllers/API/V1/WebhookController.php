<?php

namespace App\Http\Controllers\Api\V1;

use App\Contracts\Providers\VirtualAccountProviderInterface;
use App\Http\Controllers\Controller;
use App\Jobs\ProcessFlutterwaveWebhook;
use App\Models\Webhook;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WebhookController extends Controller
{
    public function __construct(protected VirtualAccountProviderInterface $provider)
    {
    }

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
}