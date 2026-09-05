<x-filament-panels::page>
    <x-filament::section>
        <form wire:submit="generate">
            {{ $this->form }}

            <div class="mt-4">
                <x-filament::button type="submit" icon="heroicon-o-chart-bar">
                    Generate Report
                </x-filament::button>
            </div>
        </form>
    </x-filament::section>

    @if ($summary)
        <div class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            @foreach ($summary as $label => $value)
                @php
                    $icon = match (true) {
                        str_contains($label, 'amount') => 'heroicon-o-banknotes',
                        str_contains($label, 'transactions') => 'heroicon-o-arrows-right-left',
                        str_contains($label, 'from') || str_contains($label, 'to') => 'heroicon-o-calendar',
                        default => 'heroicon-o-chart-bar',
                    };
                @endphp
                <x-filament::section>
                    <div class="flex items-start gap-3">
                        <x-filament::icon
                            :icon="$icon"
                            class="mt-0.5 h-5 w-5 shrink-0 text-gray-400 dark:text-gray-500"
                        />
                        <div class="min-w-0">
                            <div class="text-xs font-medium uppercase tracking-wide text-gray-500 dark:text-gray-400">
                                {{ str_replace('_', ' ', $label) }}
                            </div>
                            <div class="mt-1 truncate text-xl font-semibold text-gray-950 dark:text-white">
                                {{ $value }}
                            </div>
                        </div>
                    </div>
                </x-filament::section>
            @endforeach
        </div>
    @endif

    <x-filament::section class="mt-6">
        @if (empty($rows))
            <div class="flex flex-col items-center gap-2 py-12 text-center text-gray-500 dark:text-gray-400">
                <x-filament::icon icon="heroicon-o-document-chart-bar" class="h-10 w-10 text-gray-300 dark:text-gray-600" />
                <p>No data available for this range.</p>
            </div>
        @else
            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left text-sm">
                    <thead>
                        <tr class="bg-gray-700 dark:bg-gray-800">
                            @foreach ($columns as $column)
                                <th class="px-3 py-2 text-xs font-medium uppercase tracking-wide text-white first:rounded-l-lg last:rounded-r-lg">
                                    {{ str_replace('_', ' ', $column) }}
                                </th>
                            @endforeach
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($rows as $i => $row)
                            <tr
                                @class([
                                    'border-b border-gray-200 dark:border-white/10',
                                    'bg-gray-50 dark:bg-white/5' => $i % 2 === 0,
                                    'bg-white dark:bg-gray-900' => $i % 2 !== 0,
                                ])
                            >
                                @foreach ($row as $value)
                                    <td class="px-3 py-2 text-gray-700 dark:text-gray-200">{{ $value }}</td>
                                @endforeach
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </x-filament::section>
</x-filament-panels::page>
