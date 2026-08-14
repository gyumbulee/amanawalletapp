<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('providers', function (Blueprint $table) {
            $table->unsignedInteger('priority')->default(0)->after('is_active'); // lower = tried first
            $table->unsignedInteger('retry_attempts')->default(1)->after('priority');
            $table->unsignedInteger('timeout_seconds')->default(30)->after('retry_attempts');
        });
    }

    public function down(): void
    {
        Schema::table('providers', function (Blueprint $table) {
            $table->dropColumn(['priority', 'retry_attempts', 'timeout_seconds']);
        });
    }
};