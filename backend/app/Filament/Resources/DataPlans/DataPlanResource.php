<?php

namespace App\Filament\Resources\DataPlans;

use App\Enums\DataPlanCategory;
use App\Filament\Resources\DataPlans\Pages\EditDataPlan;
use App\Filament\Resources\DataPlans\Pages\ListDataPlans;
use App\Models\DataPlan;
use Filament\Forms\Components\Placeholder;
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

class DataPlanResource extends Resource
{
    protected static ?string $model = DataPlan::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-wifi';

    protected static string|UnitEnum|null $navigationGroup = 'Configuration';

    protected static ?string $navigationLabel = 'Data Plans';

    // Plans only ever come from data-plans:sync / the seeder - admins price
    // them, they don't hand-create catalog entries.
    protected static bool $canCreate = false;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            Placeholder::make('network')
                ->content(fn (DataPlan $record) => strtoupper($record->network)),
            Placeholder::make('name')
                ->label('Plan')
                ->content(fn (DataPlan $record) => $record->name),
            Placeholder::make('category')
                ->content(fn (DataPlan $record) => $record->category->label()),
            Placeholder::make('cost_price')
                ->label('Cost Price (from BigiSub)')
                ->content(fn (DataPlan $record) => '₦' . number_format((float) $record->cost_price, 2)),

            TextInput::make('selling_price')
                ->label('Selling Price (what the customer pays)')
                ->numeric()
                ->prefix('₦')
                ->required()
                ->helperText('Must cover the cost price above for this plan to be profitable.'),

            Toggle::make('is_active')
                ->label('Available for purchase'),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('network')
                    ->badge()
                    ->icon('heroicon-o-signal')
                    ->formatStateUsing(fn (string $state) => strtoupper($state)),
                TextColumn::make('category')
                    ->badge()
                    ->formatStateUsing(fn (DataPlanCategory $state) => $state->label()),
                TextColumn::make('name')
                    ->label('Plan')
                    ->searchable()
                    ->wrap(),
                TextColumn::make('cost_price')
                    ->label('Cost')
                    ->money('NGN')
                    ->sortable(),
                TextColumn::make('selling_price')
                    ->label('Selling Price')
                    ->money('NGN')
                    ->sortable(),
                TextColumn::make('revenue')
                    ->label('Revenue')
                    ->state(fn (DataPlan $record) => $record->revenue())
                    ->money('NGN')
                    ->color(fn (DataPlan $record) => $record->revenue() > 0 ? 'success' : ($record->revenue() < 0 ? 'danger' : 'gray'))
                    ->sortable(false),
                ToggleColumn::make('is_active')->label('Active'),
            ])
            ->defaultSort('network')
            ->filters([
                SelectFilter::make('network')->options([
                    'mtn' => 'MTN', 'glo' => 'Glo', 'airtel' => 'Airtel', '9mobile' => '9mobile',
                ]),
                SelectFilter::make('category')->options(
                    collect(DataPlanCategory::cases())->mapWithKeys(fn ($c) => [$c->value => $c->label()])->all()
                ),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListDataPlans::route('/'),
            'edit' => EditDataPlan::route('/{record}/edit'),
        ];
    }
}
