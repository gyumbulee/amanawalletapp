<?php

namespace App\Filament\Pages;

use App\Services\ReportService;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Filament\Actions\Action;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Schema;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ViewReports extends Page implements HasForms
{
    use InteractsWithForms;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-chart-bar';

    protected static ?string $navigationLabel = 'Reports';

    protected string $view = 'filament.pages.view-reports';

    public ?array $data = [];

    public ?array $summary = null;

    public array $columns = [];

    public array $rows = [];

    public function mount(): void
    {
        $this->form->fill([
            'type' => 'daily-sales',
            'from' => now()->startOfMonth()->toDateString(),
            'to' => now()->toDateString(),
        ]);

        $this->generate();
    }

    public function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('type')
                ->label('Report Type')
                ->options([
                    'daily-sales' => 'Daily Sales',
                    'weekly-sales' => 'Weekly Sales',
                    'monthly-sales' => 'Monthly Sales',
                    'revenue' => 'Revenue',
                    'wallet-funding' => 'Wallet Funding',
                    'service-sales' => 'Service Sales',
                    'user-growth' => 'User Growth',
                ])
                ->live()
                ->required(),
            DatePicker::make('from')->required(),
            DatePicker::make('to')->required(),
        ])->statePath('data');
    }

    public function generate(): void
    {
        $state = $this->form->getState();
        [$type, $from, $to] = [$state['type'], Carbon::parse($state['from']), Carbon::parse($state['to'])];

        $service = app(ReportService::class);

        [$this->summary, $rows] = match ($type) {
            'daily-sales' => $this->splitSalesReport($service->dailySales($from)),
            'weekly-sales' => $this->splitSalesReport($service->weeklySales($from)),
            'monthly-sales' => $this->splitSalesReport($service->monthlySales($from)),
            'revenue' => [null, [$service->revenue($from, $to)]],
            'wallet-funding' => [null, [$service->walletFunding($from, $to)]],
            'service-sales' => [null, $service->serviceSales($from, $to)->toArray()],
            'user-growth' => [null, $service->userGrowth($from, $to)->toArray()],
        };

        $this->rows = $rows;
        $this->columns = empty($rows) ? [] : array_keys($rows[0]);
    }

    protected function splitSalesReport(array $report): array
    {
        $summary = [
            'from' => $report['from'],
            'to' => $report['to'],
            'total_transactions' => $report['total_transactions'],
            'total_amount' => number_format($report['total_amount'], 2),
        ];

        $rows = collect($report['by_type'])->toArray();

        return [$summary, $rows];
    }

    protected function getHeaderActions(): array
    {
        return [
            Action::make('export_csv')
                ->label('Export CSV')
                ->icon('heroicon-o-arrow-down-tray')
                ->action(fn () => $this->exportCsv()),
            Action::make('export_pdf')
                ->label('Export PDF')
                ->icon('heroicon-o-document-arrow-down')
                ->action(fn () => $this->exportPdf()),
        ];
    }

    protected function exportCsv(): StreamedResponse|null
    {
        if (empty($this->rows)) {
            Notification::make()->title('No data to export.')->warning()->send();

            return null;
        }

        $type = $this->data['type'];

        return response()->streamDownload(function () {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, $this->columns);

            foreach ($this->rows as $row) {
                fputcsv($handle, $row);
            }

            fclose($handle);
        }, "{$type}-report.csv");
    }

    protected function exportPdf()
    {
        if (empty($this->rows)) {
            Notification::make()->title('No data to export.')->warning()->send();

            return null;
        }

        $type = $this->data['type'];

        $pdf = Pdf::loadView('reports.export', [
            'title' => ucfirst(str_replace('-', ' ', $type)) . ' Report',
            'from' => $this->data['from'],
            'to' => $this->data['to'],
            'columns' => $this->columns,
            'rows' => $this->rows,
        ]);

        return response()->streamDownload(
    function () use ($pdf) {
        echo $pdf->output();
    },
    "{$type}-report.pdf"
);
    }
}