<?php

namespace App\Filament\Resources\Admins;

use App\Filament\Resources\Admins\Pages\CreateAdmin;
use App\Filament\Resources\Admins\Pages\EditAdmin;
use App\Filament\Resources\Admins\Pages\ListAdmins;
use App\Models\Admin;
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\Placeholder;
use Filament\Schemas\Components\Section;
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

class AdminResource extends Resource
{
    protected static ?string $model = Admin::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-shield-check';

    protected static string|UnitEnum|null $navigationGroup = 'Configuration';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('name')->required(),
            TextInput::make('email')->email()->required()->unique(ignoreRecord: true),

            Placeholder::make('password_note')
                ->label('Password')
                ->content('A secure password is generated automatically and emailed to this admin. Use "Reset & Email Password" on the edit page to issue a new one.')
                ->visible(fn (string $operation) => $operation === 'create'),

            Select::make('roles')
                ->label('Role')
                ->relationship(
                    name: 'roles',
                    titleAttribute: 'name',
                    modifyQueryUsing: fn ($query) => $query->where('guard_name', 'admin'),
                )
                ->getOptionLabelFromRecordUsing(fn ($record) => str($record->name)->headline())
                ->required()
                ->native(false)
                ->helperText('Super Admin always has full access, regardless of the checklist below.'),

            Section::make('Access Permissions')
                ->description('Tick everything this admin should be able to do. Ignored if Role = Super Admin.')
                ->schema([
                    CheckboxList::make('permissions')
                        ->label('')
                        ->relationship(
                            name: 'permissions',
                            titleAttribute: 'name',
                            modifyQueryUsing: fn ($query) => $query->where('guard_name', 'admin'),
                        )
                        ->columns(2)
                        ->gridDirection('row'),
                ])
                ->collapsible(),

            Toggle::make('is_active')->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name'),
                TextColumn::make('email')->searchable(),
                TextColumn::make('roles.name')->badge(),
                TextColumn::make('permissions_count')
                    ->label('Permissions')
                    ->counts('permissions')
                    ->badge(),
                ToggleColumn::make('is_active')->label('Active'),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListAdmins::route('/'),
            'create' => CreateAdmin::route('/create'),
            'edit' => EditAdmin::route('/{record}/edit'),
        ];
    }
}
