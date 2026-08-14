<x-filament-panels::page>
    <x-filament::section>
        <form wire:submit="generate">
            {{ $this->form }}

            <div class="mt-4">
                <x-filament::button type="submit">
                    Generate Report
                </x-filament::button>
            </div>
        </form>
    </x-filament::section>

    @if ($summary)
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:1rem; margin-top:1.5rem;">
            @foreach ($summary as $label => $value)
                <x-filament::section>
                    <div style="font-size:0.7rem; text-transform:uppercase; letter-spacing:0.05em; color:#6B7280;">
                        {{ str_replace('_', ' ', $label) }}
                    </div>
                    <div style="font-size:1.25rem; font-weight:600; margin-top:0.25rem;">
                        {{ $value }}
                    </div>
                </x-filament::section>
            @endforeach
        </div>
    @endif

    <x-filament::section class="mt-6">
        @if (empty($rows))
            <div style="text-align:center; padding:2rem; color:#6B7280;">
                No data available for this range.
            </div>
        @else
            <table style="width:100%; border-collapse:collapse; text-align:left; font-size:0.875rem;">
                <thead>
                    <tr style="background-color:#374151;">
                        @foreach ($columns as $column)
                            <th style="padding:0.5rem 0.75rem; color:#FFFFFF; text-transform:uppercase; font-size:0.7rem; letter-spacing:0.05em;">
                                {{ str_replace('_', ' ', $column) }}
                            </th>
                        @endforeach
                    </tr>
                </thead>
                <tbody>
                    @foreach ($rows as $i => $row)
                        <tr style="background-color: {{ $i % 2 === 0 ? '#F9FAFB' : '#FFFFFF' }}; border-bottom:1px solid #E5E7EB;">
                            @foreach ($row as $value)
                                <td style="padding:0.5rem 0.75rem;">{{ $value }}</td>
                            @endforeach
                        </tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    </x-filament::section>
</x-filament-panels::page>source ~/venvs/socialbot/bin/activate