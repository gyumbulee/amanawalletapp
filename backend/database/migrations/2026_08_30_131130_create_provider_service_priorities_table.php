<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('provider_service_priorities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('provider_id')->constrained()->cascadeOnDelete();
            // Matches App\Enums\TransactionType service names: airtime, data,
            // electricity, cable, education. Not a DB enum so new services
            // don't need a migration to support.
            $table->string('service');
            $table->unsignedTinyInteger('priority')->default(1); // 1 = tried first
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['service', 'provider_id']);
        });

        // Seed reflecting your new routing decision: BigiSub is only used
        // for Data (its revenue/commission reporting isn't usable for the
        // other services). Every other service is VTpass-only.
        //   - Data:        BigiSub primary, VTpass fallback (resilience)
        //   - Airtime:     VTpass only
        //   - Electricity: VTpass only
        //   - Cable:       VTpass only
        //   - Education:   VTpass only
        $vtpassId = DB::table('providers')->where('slug', 'vtpass')->value('id');
        $bigisubId = DB::table('providers')->where('slug', 'bigisub')->value('id');

        $rows = [];

        if ($vtpassId) {
            $rows[] = ['service' => 'airtime', 'provider_id' => $vtpassId, 'priority' => 1, 'is_active' => true];
            $rows[] = ['service' => 'data', 'provider_id' => $vtpassId, 'priority' => 2, 'is_active' => true];
            $rows[] = ['service' => 'electricity', 'provider_id' => $vtpassId, 'priority' => 1, 'is_active' => true];
            $rows[] = ['service' => 'cable', 'provider_id' => $vtpassId, 'priority' => 1, 'is_active' => true];
            $rows[] = ['service' => 'education', 'provider_id' => $vtpassId, 'priority' => 1, 'is_active' => true];
        }

        if ($bigisubId) {
            $rows[] = ['service' => 'data', 'provider_id' => $bigisubId, 'priority' => 1, 'is_active' => true];
        }

        if (! empty($rows)) {
            $now = now();
            foreach ($rows as &$row) {
                $row['created_at'] = $now;
                $row['updated_at'] = $now;
            }
            DB::table('provider_service_priorities')->insert($rows);
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('provider_service_priorities');
    }
};
