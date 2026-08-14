<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('recharge_card_batches', function (Blueprint $table) {
            $table->foreign('generated_by')
                ->references('id')
                ->on('admins')
                ->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('recharge_card_batches', function (Blueprint $table) {
            $table->dropForeign(['generated_by']);
        });
    }
};