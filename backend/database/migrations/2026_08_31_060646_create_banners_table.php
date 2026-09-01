<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('banners', function (Blueprint $table) {
            $table->id();
            $table->string('title'); // admin-facing label + image alt text
            $table->string('image_path');
            // 'none' = not tappable, 'service' = deep-link to an in-app
            // service (link_value = 'airtime'/'data'/...), 'url' = external link.
            $table->string('link_type')->default('none');
            $table->string('link_value')->nullable();
            $table->unsignedSmallInteger('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            // Optional scheduling window - a banner outside this window is
            // treated as inactive without needing to remember to toggle it.
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('banners');
    }
};
