<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ReportService;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ReportController extends Controller
{
    public function __construct(protected ReportService $reportService)
    {
    }

    public function dailySales(Request $request): JsonResponse
    {
        $date = $request->query('date') ? Carbon::parse($request->query('date')) : now();

        return response()->json($this->reportService->dailySales($date));
    }

    public function weeklySales(Request $request): JsonResponse
    {
        $weekStart = $request->query('week_start') ? Carbon::parse($request->query('week_start')) : now();

        return response()->json($this->reportService->weeklySales($weekStart));
    }

    public function monthlySales(Request $request): JsonResponse
    {
        $month = $request->query('month') ? Carbon::parse($request->query('month')) : now();

        return response()->json($this->reportService->monthlySales($month));
    }

    public function revenue(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);

        return response()->json($this->reportService->revenue($from, $to));
    }

    public function walletFunding(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);

        return response()->json($this->reportService->walletFunding($from, $to));
    }

    public function serviceSales(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);

        return response()->json(['data' => $this->reportService->serviceSales($from, $to)]);
    }

    public function userGrowth(Request $request): JsonResponse
    {
        [$from, $to] = $this->resolveRange($request);
        $groupBy = $request->query('group_by', 'day');

        return response()->json(['data' => $this->reportService->userGrowth($from, $to, $groupBy)]);
    }

    public function export(Request $request): Response|StreamedResponse|JsonResponse
    {
        $request->validate([
            'type' => ['required', 'in:service-sales,user-growth,revenue,wallet-funding'],
            'format' => ['required', 'in:csv,pdf'],
        ]);

        [$from, $to] = $this->resolveRange($request);
        $type = $request->query('type');

        $rows = match ($type) {
            'service-sales' => $this->reportService->serviceSales($from, $to)->toArray(),
            'user-growth' => $this->reportService->userGrowth($from, $to, $request->query('group_by', 'day'))->toArray(),
            'revenue' => [$this->reportService->revenue($from, $to)],
            'wallet-funding' => [$this->reportService->walletFunding($from, $to)],
        };

        if (empty($rows)) {
            return response()->json(['message' => 'No data available for this range.'], 422);
        }

        return $request->query('format') === 'csv'
            ? $this->streamCsv($type, $rows)
            : $this->renderPdf($type, $rows, $from, $to);
    }

    protected function resolveRange(Request $request): array
    {
        $from = $request->query('from') ? Carbon::parse($request->query('from'))->startOfDay() : now()->startOfMonth();
        $to = $request->query('to') ? Carbon::parse($request->query('to'))->endOfDay() : now()->endOfDay();

        return [$from, $to];
    }

    protected function streamCsv(string $type, array $rows): StreamedResponse
    {
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => "attachment; filename=\"{$type}-report.csv\"",
        ];

        return response()->stream(function () use ($rows) {
            $handle = fopen('php://output', 'w');
            fputcsv($handle, array_keys($rows[0]));

            foreach ($rows as $row) {
                $row = array_map(fn ($value) => $value instanceof \BackedEnum ? $value->value : $value, $row);
                fputcsv($handle, $row);
            }

            fclose($handle);
        }, 200, $headers);
    }

    protected function renderPdf(string $type, array $rows, Carbon $from, Carbon $to): Response
    {
        $pdf = Pdf::loadView('reports.export', [
            'title' => ucfirst(str_replace('-', ' ', $type)) . ' Report',
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'columns' => array_keys($rows[0]),
            'rows' => $rows,
        ]);

        return $pdf->download("{$type}-report.pdf");
    }
}