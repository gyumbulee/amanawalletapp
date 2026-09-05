<?php

namespace App\Filament\Resources\ProviderLogs;

use App\Filament\Resources\ProviderLogs\Pages\ListProviderLogs;
use App\Filament\Resources\ProviderLogs\Pages\ViewProviderLog;
use App\Models\ProviderLog;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use UnitEnum;

class ProviderLogResource extends Resource
{
    protected static ?string $model = ProviderLog::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-clipboard-document-list';

    protected static UnitEnum|string|null $navigationGroup = 'Configuration';

    protected static bool $canCreate = false;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('provider')
                    ->badge()
                    ->icon('heroicon-o-server-stack'),
                TextColumn::make('service_type')
                    ->icon(fn (?string $state): string => match ($state) {
                        'airtime' => 'heroicon-o-device-phone-mobile',
                        'data' => 'heroicon-o-wifi',
                        'electricity' => 'heroicon-o-bolt',
                        'cable' => 'heroicon-o-tv',
                        'education' => 'heroicon-o-academic-cap',
                        default => 'heroicon-o-cog',
                    }),
                TextColumn::make('request_reference')
                    ->icon('heroicon-o-hashtag')
                    ->searchable()
                    ->copyable(),
                TextColumn::make('status')
                    ->badge()
                    ->icon(fn ($state): string => match ($state->value) {
                        'success' => 'heroicon-o-check-circle',
                        'failed' => 'heroicon-o-x-circle',
                        'timeout' => 'heroicon-o-exclamation-triangle',
                        default => 'heroicon-o-question-mark-circle',
                    })
                    ->color(fn ($state): string => match ($state->value) {
                        'success' => 'success',
                        'failed' => 'danger',
                        'timeout' => 'warning',
                        default => 'gray',
                    }),
                TextColumn::make('duration_ms')
                    ->label('Duration')
                    ->icon('heroicon-o-clock')
                    ->formatStateUsing(fn ($state) => $state !== null ? number_format($state).'ms' : '-')
                    ->color(fn ($state) => $state !== null && $state > 5000 ? 'danger' : null),
                TextColumn::make('retry_count')
                    ->icon('heroicon-o-arrow-path'),
                TextColumn::make('error_message')->limit(40)->placeholder('-'),
                TextColumn::make('created_at')
                    ->since()
                    ->tooltip(fn ($record) => $record->created_at?->format('M j, Y \a\t g:i A'))
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('provider')->options([
                    'flutterwave' => 'Flutterwave',
                    'vtpass' => 'VTpass',
                    'bigisub' => 'BigiSub',
                    'epins' => 'ePINs',
                ]),
                SelectFilter::make('service_type')->options([
                    'airtime' => 'Airtime', 'data' => 'Data', 'electricity' => 'Electricity',
                    'cable' => 'Cable', 'education' => 'Education',
                ]),
                SelectFilter::make('status')->options([
                    'success' => 'Success', 'failed' => 'Failed', 'timeout' => 'Timeout',
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListProviderLogs::route('/'),
            'view' => ViewProviderLog::route('/{record}'),
        ];
    }
}
