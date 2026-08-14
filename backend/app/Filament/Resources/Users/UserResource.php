<?php

namespace App\Filament\Resources\Users;

use App\Filament\Resources\Users\Pages\EditUser;
use App\Filament\Resources\Users\Pages\ListUsers;
use App\Filament\Resources\Users\Pages\ViewUser;
use App\Filament\Resources\Users\RelationManagers\TransactionsRelationManager;
use App\Models\AuditLog;
use App\Models\User;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-users';

    protected static UnitEnum|string|null $navigationGroup = 'Users';

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('first_name')->required(),
            TextInput::make('last_name')->required(),
            TextInput::make('email')->email()->required(),
            TextInput::make('phone')->required(),
            Select::make('status')
                ->options([
                    'active' => 'Active',
                    'suspended' => 'Suspended',
                ])
                ->required(),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('uuid')
                    ->label('ID')
                    ->limit(8)
                    ->copyable(),

                TextColumn::make('first_name')
                    ->searchable(),

                TextColumn::make('last_name')
                    ->searchable(),

                TextColumn::make('email')
                    ->searchable(),

                TextColumn::make('phone')
                    ->searchable(),

                TextColumn::make('wallet.balance')
                    ->label('Balance')
                    ->money('NGN')
                    ->sortable(),

                TextColumn::make('status')
                    ->badge()
                    ->color(fn ($state): string => match ($state->value) {
                        'active' => 'success',
                        'suspended' => 'danger',
                        default => 'gray',
                    }),

                TextColumn::make('referral_code')
                    ->label('Referral Code')
                    ->copyable(),

                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->options([
                        'active' => 'Active',
                        'suspended' => 'Suspended',
                    ]),
            ])
            ->recordActions([
                Action::make('suspend')
                    ->action(function (User $record) {
                        $record->update([
                            'status' => 'suspended',
                        ]);

                        AuditLog::record('user.suspend', $record);
                    })
                    ->requiresConfirmation()
                    ->color('danger')
                    ->visible(
                        fn (User $record) =>
                            $record->status->value === 'active'
                    )
                    ->successNotification(
                        Notification::make()
                            ->success()
                            ->title('User suspended')
                    ),

                Action::make('activate')
                    ->action(function (User $record) {
                        $record->update([
                            'status' => 'active',
                        ]);

                        AuditLog::record('user.activate', $record);
                    })
                    ->requiresConfirmation()
                    ->color('success')
                    ->visible(
                        fn (User $record) =>
                            $record->status->value === 'suspended'
                    )
                    ->successNotification(
                        Notification::make()
                            ->success()
                            ->title('User activated')
                    ),

                Action::make('reset_pin')
                    ->label('Reset Transaction PIN')
                    ->action(function (User $record) {
                        if ($record->wallet) {
                            $record->wallet->update([
                                'pin' => null,
                            ]);
                        }

                        AuditLog::record('user.reset_pin', $record);
                    })
                    ->requiresConfirmation()
                    ->color('warning')
                    ->successNotification(
                        Notification::make()
                            ->success()
                            ->title('Transaction PIN reset')
                    ),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            TransactionsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListUsers::route('/'),
            'view' => ViewUser::route('/{record}'),
            'edit' => EditUser::route('/{record}/edit'),
        ];
    }
}