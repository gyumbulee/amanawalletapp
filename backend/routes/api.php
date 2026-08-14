<?php

use App\Http\Controllers\Api\V1\AirtimeController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CableController;
use App\Http\Controllers\Api\V1\DataController;
use App\Http\Controllers\Api\V1\EducationController;
use App\Http\Controllers\Api\V1\ElectricityController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\ReferralController;
use App\Http\Controllers\Api\V1\ReportController;
use App\Http\Controllers\Api\V1\TransactionController;
use App\Http\Controllers\Api\V1\VirtualAccountController;
use App\Http\Controllers\Api\V1\WalletController;
use App\Http\Controllers\Api\V1\WebhookController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1/webhooks')->group(function () {
    Route::post('flutterwave', [WebhookController::class, 'flutterwave']);
    Route::post('vtpass', [WebhookController::class, 'vtpass']);
});

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

    Route::middleware('auth:sanctum')->prefix('virtual-account')->group(function () {
        Route::get('/', [VirtualAccountController::class, 'show']);
        Route::post('retry', [VirtualAccountController::class, 'retry']);
    });

    Route::middleware('auth:sanctum')->prefix('transactions')->group(function () {
        Route::get('/', [TransactionController::class, 'index']);
        Route::get('{uuid}', [TransactionController::class, 'show']);
    });

    Route::middleware('auth:sanctum')->prefix('airtime')->group(function () {
        Route::post('purchase', [AirtimeController::class, 'purchase']);
    });

    Route::middleware('auth:sanctum')->prefix('data')->group(function () {
        Route::get('plans', [DataController::class, 'plans']);
        Route::post('purchase', [DataController::class, 'purchase']);
    });

    Route::middleware('auth:sanctum')->prefix('electricity')->group(function () {
        Route::post('verify-meter', [ElectricityController::class, 'verifyMeter']);
        Route::post('purchase', [ElectricityController::class, 'purchase']);
    });

    Route::middleware('auth:sanctum')->prefix('cable')->group(function () {
        Route::get('plans', [CableController::class, 'plans']);
        Route::post('verify-smartcard', [CableController::class, 'verifySmartcard']);
        Route::post('purchase', [CableController::class, 'purchase']);
    });

    Route::middleware('auth:sanctum')->prefix('education')->group(function () {
        Route::get('plans', [EducationController::class, 'plans']);
        Route::post('verify-profile', [EducationController::class, 'verifyProfile']);
        Route::post('purchase', [EducationController::class, 'purchase']);
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

    // TODO: restrict to admin role once the roles/permissions system is built in Phase 14.
    Route::middleware('auth:sanctum')->prefix('reports')->group(function () {
        Route::get('daily-sales', [ReportController::class, 'dailySales']);
        Route::get('weekly-sales', [ReportController::class, 'weeklySales']);
        Route::get('monthly-sales', [ReportController::class, 'monthlySales']);
        Route::get('revenue', [ReportController::class, 'revenue']);
        Route::get('wallet-funding', [ReportController::class, 'walletFunding']);
        Route::get('service-sales', [ReportController::class, 'serviceSales']);
        Route::get('user-growth', [ReportController::class, 'userGrowth']);
        Route::get('export', [ReportController::class, 'export']);
    });

});