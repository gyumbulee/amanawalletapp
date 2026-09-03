<?php

use App\Http\Controllers\Api\V1\AirtimeController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\BannerController;
use App\Http\Controllers\Api\V1\BannerImageController;
use App\Http\Controllers\Api\V1\CableController;
use App\Http\Controllers\Api\V1\DataController;
use App\Http\Controllers\Api\V1\EducationController;
use App\Http\Controllers\Api\V1\ElectricityController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\ReferralController;
use App\Http\Controllers\Api\V1\SupportTicketController;
use App\Http\Controllers\Api\V1\TransactionController;
use App\Http\Controllers\Api\V1\VirtualAccountController;
use App\Http\Controllers\Api\V1\WalletController;
use App\Http\Controllers\Api\V1\WebhookController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1/webhooks')->group(function () {
    Route::post('flutterwave', [WebhookController::class, 'flutterwave']);
    Route::post('vtpass', [WebhookController::class, 'vtpass']);
});

// Deliberately public + outside auth:sanctum: <img> tags, CachedNetworkImage,
// and direct browser navigation can't attach a bearer token, and these are
// promotional images meant to be publicly visible anyway.
Route::get('v1/banner-images/{filename}', [BannerImageController::class, 'show']);

Route::prefix('v1')->middleware('maintenance')->group(function () {

    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register'])->middleware('throttle:5,1');
        Route::post('verify-email', [AuthController::class, 'verifyEmail'])->middleware('throttle:10,1');
        Route::post('resend-otp', [AuthController::class, 'resendOtp'])->middleware('throttle:3,1');
        Route::post('login', [AuthController::class, 'login'])->middleware('throttle:5,1');
        Route::post('forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:3,1');
        Route::post('reset-password', [AuthController::class, 'resetPassword'])->middleware('throttle:5,1');

        Route::middleware('auth:sanctum')->group(function () {
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me', [AuthController::class, 'me']);
        });
    });
    Route::get('profile-photo/{filename}', [ProfileController::class, 'showPhoto'])
        ->where('filename', '[A-Za-z0-9._-]+');
        
    Route::middleware('auth:sanctum')->prefix('profile')->group(function () {
        Route::put('/', [ProfileController::class, 'update']);
        Route::post('change-password', [ProfileController::class, 'changePassword']);
        Route::post('set-pin', [ProfileController::class, 'setTransactionPin']);
        Route::post('verify-bvn', [ProfileController::class, 'verifyBvn']);
        Route::post('photo', [ProfileController::class, 'uploadPhoto']);
    });

    Route::middleware('auth:sanctum')->prefix('wallet')->group(function () {
        Route::get('/', [WalletController::class, 'show']);
        Route::get('ledgers', [WalletController::class, 'ledgers']);
    });

    Route::middleware('auth:sanctum')->get('banners', [BannerController::class, 'index']);

    Route::middleware('auth:sanctum')->prefix('virtual-account')->group(function () {
        Route::get('/', [VirtualAccountController::class, 'show']);
        Route::post('retry', [VirtualAccountController::class, 'retry']);
    });

    Route::middleware('auth:sanctum')->prefix('transactions')->group(function () {
        Route::get('/', [TransactionController::class, 'index']);
        Route::get('{uuid}', [TransactionController::class, 'show']);
    });

    Route::middleware('auth:sanctum')->prefix('airtime')->group(function () {
        Route::post('purchase', [AirtimeController::class, 'purchase'])
            ->middleware(['idempotent', 'throttle:15,1'])->name('airtime.purchase');
    });

    Route::middleware('auth:sanctum')->prefix('data')->group(function () {
        Route::get('categories', [DataController::class, 'categories']);
        Route::get('plans', [DataController::class, 'plans']);
        Route::post('purchase', [DataController::class, 'purchase'])
            ->middleware(['idempotent', 'throttle:15,1'])->name('data.purchase');
    });

    Route::middleware('auth:sanctum')->prefix('electricity')->group(function () {
        Route::post('verify-meter', [ElectricityController::class, 'verifyMeter'])
            ->middleware('throttle:20,1');
        Route::post('purchase', [ElectricityController::class, 'purchase'])
            ->middleware(['idempotent', 'throttle:15,1'])->name('electricity.purchase');
    });

    Route::middleware('auth:sanctum')->prefix('cable')->group(function () {
        Route::get('plans', [CableController::class, 'plans']);
        Route::post('verify-smartcard', [CableController::class, 'verifySmartcard'])
            ->middleware('throttle:20,1');
        Route::post('purchase', [CableController::class, 'purchase'])
            ->middleware(['idempotent', 'throttle:15,1'])->name('cable.purchase');
    });

    Route::middleware('auth:sanctum')->prefix('education')->group(function () {
        Route::get('plans', [EducationController::class, 'plans']);
        Route::post('verify-profile', [EducationController::class, 'verifyProfile'])
            ->middleware('throttle:20,1');
        Route::post('purchase', [EducationController::class, 'purchase'])
            ->middleware(['idempotent', 'throttle:15,1'])->name('education.purchase');
    });

    Route::middleware('auth:sanctum')->prefix('referrals')->group(function () {
        Route::get('summary', [ReferralController::class, 'summary']);
        Route::get('history', [ReferralController::class, 'history']);
    });

    Route::middleware('auth:sanctum')->prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::get('unread-count', [NotificationController::class, 'unreadCount']);
        Route::post('{id}/read', [NotificationController::class, 'markAsRead']);
        Route::post('read-all', [NotificationController::class, 'markAllAsRead']);
    });

    Route::middleware('auth:sanctum')->prefix('support')->group(function () {
        Route::get('tickets', [SupportTicketController::class, 'index']);
        Route::post('tickets', [SupportTicketController::class, 'store']);
        Route::get('tickets/{uuid}', [SupportTicketController::class, 'show']);
        Route::post('tickets/{uuid}/messages', [SupportTicketController::class, 'addMessage']);
    });

    // Deliberately not exposed here: business-wide report data (revenue,
    // user growth, service sales) has no business being reachable by a
    // customer's Sanctum token. Reports are admin-only and live entirely
    // inside the Filament panel (App\Filament\Pages\ViewReports), which
    // calls ReportService and generates CSV/PDF exports directly rather
    // than going through this API. If a future need arises to expose
    // reports over HTTP, gate it behind the 'admin' guard, not 'sanctum'.

});