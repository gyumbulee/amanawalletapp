<?php

namespace App\Filament\Resources\ProviderServicePriorities;

use App\Filament\Resources\ProviderServicePriorities\Pages\CreateProviderServicePriority;
use App\Filament\Resources\ProviderServicePriorities\Pages\EditProviderServicePriority;
use App\Filament\Resources\ProviderServicePriorities\Pages\ListProviderServicePriorities;
use App\Models\Provider;
use App\Models\ProviderServicePriority;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class ProviderServicePriorityResource extends Resource
{
    protected static ?string $model = ProviderServicePriority::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-arrows-right-left';

    protected static string|UnitEnum|null $navigationGroup = 'Configuration';

    protected static ?string $navigationLabel = 'Provider Routing';

    protected static ?string $modelLabel = 'routing rule';

    /**
     * Keep this in sync with App\Enums\TransactionType service names.
     */
    private const SERVICES = [
        'airtime' => 'Airtime',
        'data' => 'Data',
        'electricity' => 'Electricity',
        'cable' => 'Cable TV',
        'education' => 'Education',
    ];

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('service')
                ->options(self::SERVICES)
                ->required(),

            Select::make('provider_id')
                ->label('Provider')
                ->options(fn () => Provider::query()->pluck('name', 'id'))
                ->required(),

            TextInput::make('priority')
                ->numeric()
                ->required()
                ->default(1)
                ->helperText('Lower number = tried first for this service. Ties are undefined - use distinct numbers.'),

            Toggle::make('is_active')
                ->label('Active for this service')
                ->default(true)
                ->helperText('Off = this provider is skipped for this specific service, even if globally active.'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('service')
                    ->badge()
                    ->icon(fn (string $state): string => match ($state) {
                        'airtime' => 'heroicon-o-device-phone-mobile',
                        'data' => 'heroicon-o-wifi',
                        'electricity' => 'heroicon-o-bolt',
                        'cable' => 'heroicon-o-tv',
                        'education' => 'heroicon-o-academic-cap',
                        default => 'heroicon-o-cog',
                    })
                    ->formatStateUsing(fn (string $state) => self::SERVICES[$state] ?? $state),
                TextColumn::make('provider.name')
                    ->icon('heroicon-o-server-stack'),
                TextColumn::make('priority')
                    ->label('Order')
                    ->badge()
                    ->color('gray')
                    ->formatStateUsing(fn ($state) => "#{$state}")
                    ->sortable(),
                ToggleColumn::make('is_active')->label('Active'),
            ])
            ->defaultSort('service')
            ->filters([
                SelectFilter::make('service')->options(self::SERVICES),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListProviderServicePriorities::route('/'),
            'create' => CreateProviderServicePriority::route('/create'),
            'edit' => EditProviderServicePriority::route('/{record}/edit'),
        ];
    }
}
