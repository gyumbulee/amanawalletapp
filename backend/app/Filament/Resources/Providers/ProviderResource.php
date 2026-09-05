<?php

namespace App\Filament\Resources\Providers;

use App\Filament\Resources\Providers\Pages\ListProviders;
use App\Models\Provider;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class ProviderResource extends Resource
{
    protected static ?string $model = Provider::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-server-stack';

    protected static string|UnitEnum|null $navigationGroup = 'Configuration';

    protected static bool $canCreate = false;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name')->required(),

            TextInput::make('slug')
                ->required()
                ->disabled(),

            TextInput::make('retry_attempts')
                ->numeric()
                ->required()
                ->helperText(
                    'Not yet enforced in the request loop - reserved for a future retry-before-failover implementation.'
                ),

            TextInput::make('timeout_seconds')
                ->numeric()
                ->required(),

            Toggle::make('is_active')
                ->label('Active')
                ->helperText(
                    'Global kill-switch — turning this off disables the provider for every service, ' .
                    'regardless of the per-service priority settings below.'
                ),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->icon('heroicon-o-server-stack')
                    ->weight('semibold')
                    ->searchable(),
                TextColumn::make('slug')
                    ->badge()
                    ->color('gray'),
                TextColumn::make('retry_attempts')
                    ->label('Retries')
                    ->icon('heroicon-o-arrow-path')
                    ->alignCenter(),
                TextColumn::make('timeout_seconds')
                    ->label('Timeout')
                    ->icon('heroicon-o-clock')
                    ->formatStateUsing(fn ($state) => "{$state}s")
                    ->alignCenter(),
                ToggleColumn::make('is_active')
                    ->label('Active'),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListProviders::route('/'),
        ];
    }
}