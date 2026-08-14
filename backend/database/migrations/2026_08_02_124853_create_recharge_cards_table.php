<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recharge_cards', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->foreignId('batch_id')->constrained('recharge_card_batches')->cascadeOnDelete();
            $table->string('network');
            $table->decimal('denomination', 20, 2);
            $table->string('serial_number')->unique();
            $table->text('pin'); // encrypted
            $table->boolean('is_printed')->default(false);
            $table->timestamps();

            $table->index(['network', 'denomination']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recharge_cards');
    }
};