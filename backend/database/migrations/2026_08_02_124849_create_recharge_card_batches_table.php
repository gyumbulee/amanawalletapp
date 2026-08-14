<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recharge_card_batches', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('network');
            $table->decimal('denomination', 20, 2);
            $table->unsignedInteger('quantity');
            $table->string('status')->default('pending'); // RechargeCardBatchStatus enum
            $table->foreignId('generated_by')->constrained('users')->cascadeOnDelete();
            $table->string('failure_reason')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recharge_card_batches');
    }
};