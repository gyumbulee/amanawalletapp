<?php

namespace App\Filament\Resources\AuditLogs;

use App\Filament\Resources\AuditLogs\Pages\ListAuditLogs;
use App\Models\AuditLog;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use UnitEnum;

class AuditLogResource extends Resource
{
    protected static ?string $model = AuditLog::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-document-magnifying-glass';

    protected static string|UnitEnum|null $navigationGroup = 'Configuration';

    protected static bool $canCreate = false;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('admin.name')
                    ->label('Admin')
                    ->placeholder('System')
                    ->icon('heroicon-o-user-circle')
                    ->searchable(),
                TextColumn::make('action')
                    ->badge()
                    ->color(fn (string $state): string => match (true) {
                        str_contains($state, 'approve'), str_contains($state, 'activate'), str_contains($state, 'resolve') => 'success',
                        str_contains($state, 'suspend'), str_contains($state, 'reject'), str_contains($state, 'close') => 'danger',
                        str_contains($state, 'update'), str_contains($state, 'save'), str_contains($state, 'reset') => 'warning',
                        default => 'gray',
                    })
                    ->searchable(),
                TextColumn::make('subject_type')
                    ->label('Subject')
                    ->icon('heroicon-o-cube')
                    ->formatStateUsing(fn ($state) => $state ? class_basename($state) : '-'),
                TextColumn::make('ip_address')
                    ->icon('heroicon-o-globe-alt')
                    ->copyable()
                    ->placeholder('-'),
                TextColumn::make('created_at')
                    ->label('When')
                    ->since()
                    ->tooltip(fn ($record) => $record->created_at?->format('M j, Y \a\t g:i A'))
                    ->icon('heroicon-o-clock')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListAuditLogs::route('/'),
        ];
    }
}
