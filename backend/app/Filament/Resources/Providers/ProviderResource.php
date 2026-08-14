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

            TextInput::make('priority')
                ->numeric()
                ->required()
                ->helperText(
                    'Lower number = tried first when multiple providers support a service.'
                ),

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
                ->label('Active'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name'),
                TextColumn::make('slug')->badge(),
                TextColumn::make('priority'),
                TextColumn::make('timeout_seconds')
                    ->label('Timeout (s)'),
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