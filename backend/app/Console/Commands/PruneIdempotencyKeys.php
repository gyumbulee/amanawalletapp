<?php

namespace App\Console\Commands;

use App\Models\IdempotencyKey;
use Illuminate\Console\Command;

class PruneIdempotencyKeys extends Command
{
    protected $signature = 'idempotency:prune {--days=7 : Delete completed records older than this many days}';

    protected $description = 'Delete old completed idempotency-key records to keep the table small.';

    public function handle(): int
    {
        $days = (int) $this->option('days');

        $deleted = IdempotencyKey::query()
            ->where('status', 'completed')
            ->where('updated_at', '<', now()->subDays($days))
            ->delete();

        $this->info("Pruned {$deleted} idempotency-key record(s) older than {$days} day(s).");

        return self::SUCCESS;
    }
}
