<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('device_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            // FCM registration token. Unique globally, not just per-user - if
            // the same physical device token later shows up under a
            // different account (shared device, account switch), storing it
            // re-points ownership to that user rather than creating a stale
            // duplicate that would send push notifications to the wrong
            // person.
            $table->string('token')->unique();
            $table->enum('platform', ['android', 'ios', 'web'])->default('android');
            $table->timestamps();

            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('device_tokens');
    }
};
