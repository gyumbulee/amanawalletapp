<?php

namespace App\Filament\Resources\Transactions;

use App\Filament\Resources\Transactions\Pages\ListTransactions;
use App\Filament\Resources\Transactions\Pages\ViewTransaction;
use App\Models\Transaction;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;
use App\Enums\TransactionStatus;
use Filament\Schemas\Components\Section;
use Filament\Infolists\Components\TextEntry;

class TransactionResource extends Resource
{
    protected static ?string $model = Transaction::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-banknotes';

    protected static string|UnitEnum|null $navigationGroup = 'Finance';

    protected static bool $canCreate = false;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('reference')->searchable()->copyable(),
                TextColumn::make('user.email')->label('User')->searchable(),
                TextColumn::make('type')->badge(),
                TextColumn::make('amount')->money('NGN')->sortable(),
                TextColumn::make('status')
    ->badge()
    ->formatStateUsing(fn (TransactionStatus $state) => ucfirst($state->value))
    ->color(fn (TransactionStatus $state) => match ($state) {
        TransactionStatus::Successful => 'success',
        TransactionStatus::Failed => 'danger',
        TransactionStatus::Reversed => 'warning',
        TransactionStatus::Processing => 'warning',
        TransactionStatus::Pending => 'gray',
    }),
                TextColumn::make('provider'),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->filters([
                SelectFilter::make('type')->options([
                    'wallet_funding' => 'Wallet Funding',
                    'airtime' => 'Airtime',
                    'data' => 'Data',
                    'electricity' => 'Electricity',
                    'cable' => 'Cable',
                    'education' => 'Education',
                    'referral_bonus' => 'Referral Bonus',
                ]),
                SelectFilter::make('status')->options([
    TransactionStatus::Pending->value => 'Pending',
    TransactionStatus::Processing->value => 'Processing',
    TransactionStatus::Successful->value => 'Successful',
    TransactionStatus::Failed->value => 'Failed',
    TransactionStatus::Reversed->value => 'Reversed',
]),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListTransactions::route('/'),
            'view' => ViewTransaction::route('/{record}'),
        ];
    }
    public static function infolist(Schema $schema): Schema
{
    return $schema
        ->components([
            Section::make('Transaction Details')
                ->schema([
                    TextEntry::make('reference')->copyable(),

                    TextEntry::make('user.email')
                        ->label('User'),

                    TextEntry::make('type')
                        ->badge(),

                    TextEntry::make('amount')
                        ->money('NGN'),

                    TextEntry::make('status')
                        ->badge(),

                    TextEntry::make('provider'),

                    TextEntry::make('created_at')
                        ->dateTime(),
                ]),
        ]);
}
}