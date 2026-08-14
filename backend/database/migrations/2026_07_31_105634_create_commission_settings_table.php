<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('commission_settings', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('service_type'); // airtime, data, electricity, cable, education
            $table->string('network')->nullable(); // mtn, glo, airtel, 9mobile - null = applies to all
            $table->string('type')->default('percentage'); // CommissionType enum: percentage, flat
            $table->decimal('value', 8, 4);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['service_type', 'network']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('commission_settings');
    }
};