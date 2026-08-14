<?php

namespace App\Filament\Resources\CommissionSettings;

use App\Filament\Resources\CommissionSettings\Pages\CreateCommissionSetting;
use App\Filament\Resources\CommissionSettings\Pages\EditCommissionSetting;
use App\Filament\Resources\CommissionSettings\Pages\ListCommissionSettings;
use App\Models\CommissionSetting;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class CommissionSettingResource extends Resource
{
    protected static ?string $model = CommissionSetting::class;
    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-percent-badge';
    protected static string|UnitEnum|null $navigationGroup = 'Configuration';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Select::make('service_type')
                ->options([
                    'airtime' => 'Airtime',
                    'data' => 'Data',
                    'electricity' => 'Electricity',
                    'cable' => 'Cable',
                    'education' => 'Education',
                ])
                ->required(),
            TextInput::make('network')
                ->helperText('Leave blank to apply to all networks for this service.'),
            Select::make('type')
                ->options(['percentage' => 'Percentage', 'flat' => 'Flat Amount'])
                ->default('percentage')
                ->required(),
            TextInput::make('value')->numeric()->required(),
            Toggle::make('is_active')->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('service_type')->badge(),
                TextColumn::make('network')->placeholder('All networks'),
                TextColumn::make('type'),
                TextColumn::make('value'),
                ToggleColumn::make('is_active')->label('Active'),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCommissionSettings::route('/'),
            'create' => CreateCommissionSetting::route('/create'),
            'edit' => EditCommissionSetting::route('/{record}/edit'),
        ];
    }
}