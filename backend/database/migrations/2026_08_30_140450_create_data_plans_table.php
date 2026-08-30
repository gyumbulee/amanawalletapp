<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('data_plans', function (Blueprint $table) {
            $table->id();
            $table->string('network'); // matches App\Enums\AirtimeNetwork values
            $table->string('variation_code');
            $table->string('category'); // App\Enums\DataPlanCategory
            $table->string('name'); // raw plan name as returned by the provider
            // What the provider actually charges Amana for this exact plan.
            // Refreshed on every catalog import - never hand-edited.
            $table->decimal('cost_price', 10, 2);
            // What the customer pays. Defaults to cost_price on first import
            // (zero margin) until an admin sets a real markup. Preserved
            // across re-imports so re-syncing the catalog never wipes pricing.
            $table->decimal('selling_price', 10, 2);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['network', 'variation_code']);
            $table->index(['network', 'category']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('data_plans');
    }
};
