<?php

namespace App\Services;

use App\Enums\ProviderLogStatus;
use App\Models\ProviderLog;

class ProviderLogService
{
    public function log(
        string $provider,
        string $serviceType,
        string $requestReference,
        ?string $transactionReference,
        ?array $requestPayload,
        ?array $responsePayload,
        ProviderLogStatus $status,
        ?string $errorMessage,
        int $durationMs,
        int $retryCount = 0
    ): ProviderLog {
        return ProviderLog::query()->create([
            'provider' => $provider,
            'service_type' => $serviceType,
            'request_reference' => $requestReference,
            'transaction_reference' => $transactionReference,
            'request_payload' => $requestPayload,
            'response_payload' => $responsePayload,
            'status' => $status,
            'error_message' => $errorMessage,
            'retry_count' => $retryCount,
            'duration_ms' => $durationMs,
        ]);
    }
}