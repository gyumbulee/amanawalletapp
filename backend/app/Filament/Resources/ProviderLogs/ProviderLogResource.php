<?php

namespace App\Filament\Resources\ProviderLogs;

use App\Filament\Resources\ProviderLogs\Pages\ListProviderLogs;
use App\Filament\Resources\ProviderLogs\Pages\ViewProviderLog;
use App\Models\ProviderLog;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use BackedEnum;
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
                TextColumn::make('provider')->badge(),
                TextColumn::make('service_type'),
                TextColumn::make('request_reference')->searchable()->copyable(),
                TextColumn::make('status')->badge()
                    ->color(fn ($state): string => match ($state->value) {
    'success' => 'success',
    'failed' => 'danger',
    'timeout' => 'warning',
    default => 'gray',
}),
                TextColumn::make('duration_ms')->label('Duration (ms)'),
                TextColumn::make('retry_count'),
                TextColumn::make('error_message')->limit(40)->placeholder('-'),
                TextColumn::make('created_at')->dateTime()->sortable(),
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