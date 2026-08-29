<?php

namespace App\Services\Providers;

use App\Contracts\Providers\EpinsProviderInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use RuntimeException;

class EpinsProvider implements EpinsProviderInterface
{
    /**
     * ePINs recharge-card PIN service variations.
     * Key = Naira denomination, Value = ePINs "pinDenomination" variation code.
     * @see https://epins.com.ng/developers/ (Recharge Card PIN API Integration)
     */
    private const DENOMINATION_VARIATIONS = [
        100 => 1,
        200 => 2,
        400 => 4,
        500 => 5,
        1000 => 10,
    ];

    public function generateCards(string $network, float $denomination, int $quantity): array
    {
        $variationCode = self::DENOMINATION_VARIATIONS[(int) $denomination] ?? null;

        if ($variationCode === null) {
            throw new RuntimeException(sprintf(
                'ePINs does not support ₦%s recharge cards. Supported denominations: %s',
                (int) $denomination,
                implode(', ', array_keys(self::DENOMINATION_VARIATIONS))
            ));
        }

        $url = rtrim(config('services.epins.base_url'), '/') . '/epin/';
        $ref = 'EPIN-' . Str::upper(Str::random(12));

        $payload = [
            'network' => strtolower($network),
            'pinDenomination' => $variationCode,
            'pinQuantity' => $quantity,
            'cardname' => config('services.epins.card_name', config('app.name')),
            'ref' => $ref,
        ];

        Log::info('EPINS Request', [
            'url' => $url,
            'payload' => $payload,
            'api_key_present' => ! empty(config('services.epins.api_key')),
        ]);

        $timeout = \App\Models\Provider::query()
            ->where('slug', 'epins')
            ->value('timeout_seconds') ?? 30;

        $response = Http::withToken(config('services.epins.api_key'))
            ->acceptJson()
            ->timeout($timeout)
            ->post($url, $payload);

        Log::info('EPINS Response', [
            'status' => $response->status(),
            'body' => $response->body(),
            'json' => $response->json(),
        ]);

        $body = $response->json() ?? [];
        $code = $body['code'] ?? null;

        if (! $response->successful() || $code === null) {
            throw new RuntimeException(
                sprintf('HTTP %d: %s', $response->status(), $response->body())
            );
        }

        // ePINs uses numeric "code" for status, not an HTTP-style success/fail string.
        // 101 = Transaction successful; anything else is a documented failure code.
        if ((int) $code !== 101) {
            throw new RuntimeException(
                $body['description']['response_description']
                    ?? $body['description']
                    ?? "ePINs card generation failed (code {$code})."
            );
        }

        $cards = $body['description']['PIN'] ?? [];

        $usableCards = array_values(array_filter(
            array_map(fn ($card) => [
                'serial_number' => $card['serial'] ?? null,
                'pin' => $card['pin'] ?? null,
            ], $cards),
            fn ($card) => filled($card['serial_number']) && filled($card['pin'])
        ));

        if (empty($usableCards)) {
            throw new RuntimeException(
                "ePINs reported success but returned no usable PINs for {$network} (denomination ₦{$denomination})."
            );
        }

        return $usableCards;
    }
}
