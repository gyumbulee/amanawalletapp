<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('recharge_card_batches', function (Blueprint $table) {
            // 'quantity' now reflects cards actually generated/stored;
            // providers (esp. in sandbox) can silently return fewer than requested.
            $table->unsignedInteger('requested_quantity')->nullable()->after('quantity');
        });

        DB::table('recharge_card_batches')->whereNull('requested_quantity')->update([
            'requested_quantity' => DB::raw('quantity'),
        ]);

        // Failure/partial-fulfillment messages (e.g. raw provider error bodies)
        // can exceed 255 chars — avoid on avoiding truncation errors.
        DB::statement('ALTER TABLE recharge_card_batches MODIFY failure_reason TEXT NULL');
    }

    public function down(): void
    {
        Schema::table('recharge_card_batches', function (Blueprint $table) {
            $table->dropColumn('requested_quantity');
        });

        DB::statement('ALTER TABLE recharge_card_batches MODIFY failure_reason VARCHAR(255) NULL');
    }
};
