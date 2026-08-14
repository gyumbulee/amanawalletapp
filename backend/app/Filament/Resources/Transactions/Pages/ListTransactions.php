<?php

namespace App\Filament\Resources\Transactions\Pages;

use App\Filament\Resources\Transactions\TransactionResource;
use App\Models\Transaction;
use Filament\Actions\Action;
use Filament\Resources\Pages\ListRecords;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Illuminate\Database\Eloquent\Builder;

class ListTransactions extends ListRecords
{
    protected static string $resource = TransactionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('export')
                ->label('Export CSV')
                ->icon('heroicon-o-arrow-down-tray')
                ->action(function () {
                    return $this->exportCsv();
                }),
        ];
    }

    protected function exportCsv(): StreamedResponse
    {
        // Exports whatever the current table filters/search have narrowed down to.
        $rows = $this->getFilteredTableQuery()->latest()->limit(5000)->get();

        return response()->streamDownload(function () use ($rows) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, ['Reference', 'User', 'Type', 'Amount', 'Status', 'Provider', 'Created At']);

            foreach ($rows as $row) {
                fputcsv($handle, [
                    $row->reference,
                    $row->user?->email,
                    $row->type->value,
                    $row->amount,
                    $row->status->value,
                    $row->provider,
                    $row->created_at,
                ]);
            }

            fclose($handle);
        }, 'transactions-export.csv');
    }

    public function getFilteredTableQuery(): ?Builder
    {
        return Transaction::query()
            ->when($this->tableFilters['type']['value'] ?? null, fn ($q, $v) => $q->where('type', $v))
            ->when($this->tableFilters['status']['value'] ?? null, fn ($q, $v) => $q->where('status', $v))
            ->when($this->tableSearch, fn ($q, $search) => $q->where('reference', 'like', "%{$search}%"));
    }
}