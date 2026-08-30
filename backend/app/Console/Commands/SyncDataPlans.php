<?php

namespace App\Console\Commands;

use App\Services\DataPlanImporter;
use App\Services\Providers\BigiSubDataProvider;
use Illuminate\Console\Command;

class SyncDataPlans extends Command
{
    protected $signature = 'data-plans:sync {network?* : Specific networks to sync (default: mtn glo airtel 9mobile)}';

    protected $description = 'Refresh the data_plans catalog from BigiSub for one or more networks.';

    public function handle(BigiSubDataProvider $provider, DataPlanImporter $importer): int
    {
        $networks = $this->argument('network') ?: ['mtn', 'glo', 'airtel', '9mobile'];

        foreach ($networks as $network) {
            $this->line("Fetching {$network} plans from BigiSub...");

            try {
                $plans = $provider->listPlans($network);
                $importer->import($network, $plans);
                $this->info("  {$network}: " . count($plans) . ' plans synced.');
            } catch (\Throwable $e) {
                $this->error("  {$network}: failed - {$e->getMessage()}");
            }
        }

        return self::SUCCESS;
    }
}
