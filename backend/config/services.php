<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],
    'epins' => [
    'base_url' => env('EPINS_BASE_URL'),
    'api_key' => env('EPINS_API_KEY'),
    ],
    'vtpass' => [
    'base_url' => env('VTPASS_BASE_URL', 'https://sandbox.vtpass.com/api'),
    'api_key' => env('VTPASS_API_KEY'),
    'secret_key' => env('VTPASS_SECRET_KEY'),
    ],
    'bigisub' => [
    // Confirmed against Bigisub's official v2 API docs (api.bigisub.ng),
    // Aug 2026 - supersedes an earlier v1 integration attempt.
    // Auth: `Authorization: Token {api_key}` (Django REST Framework token).
    // Every response is enveloped as {"success": bool, "data": {...}, "message": "..."}.
    'base_url' => env('BIGISUB_BASE_URL', 'https://api.bigisub.ng/api/v2'),
    'api_key' => env('BIGISUB_API_KEY'),
    // Bigisub's own merchant transaction PIN (set once in your Bigisub
    // dashboard), required on every purchase call. This is NOT the
    // end-user's Amana Wallet transaction PIN - that's verified separately,
    // before we ever reach the provider layer.
    'pin' => env('BIGISUB_PIN'),
    ],
    'flutterwave' => [
    'base_url' => env('FLUTTERWAVE_BASE_URL', 'https://api.flutterwave.com/v3'),
    'secret_key' => env('FLUTTERWAVE_SECRET_KEY'),
    'public_key' => env('FLUTTERWAVE_PUBLIC_KEY'),
    'encryption_key' => env('FLUTTERWAVE_ENCRYPTION_KEY'),
    'webhook_secret_hash' => env('FLUTTERWAVE_WEBHOOK_SECRET_HASH'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

];
