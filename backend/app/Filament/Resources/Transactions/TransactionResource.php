<?php

namespace App\Filament\Resources\Transactions;

use App\Enums\TransactionStatus;
use App\Filament\Resources\Transactions\Pages\ListTransactions;
use App\Filament\Resources\Transactions\Pages\ViewTransaction;
use App\Models\Transaction;
use BackedEnum;
use App\Enums\TransactionType;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use UnitEnum;

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
                TextColumn::make('reference')
                    ->icon('heroicon-o-hashtag')
                    ->searchable()
                    ->copyable(),
                TextColumn::make('user.email')
                    ->label('User')
                    ->icon('heroicon-o-user')
                    ->searchable(),
                TextColumn::make('type')
                    ->badge()
                    ->icon(fn (TransactionType $state): string => match ($state->value) {
    'wallet_funding' => 'heroicon-o-arrow-down-tray',
    'airtime' => 'heroicon-o-device-phone-mobile',
    'data' => 'heroicon-o-wifi',
    'electricity' => 'heroicon-o-bolt',
    'cable' => 'heroicon-o-tv',
    'education' => 'heroicon-o-academic-cap',
    'referral_bonus' => 'heroicon-o-gift',
    default => 'heroicon-o-banknotes',
}),
                TextColumn::make('amount')
                    ->money('NGN')
                    ->weight('semibold')
                    ->sortable(),
                TextColumn::make('status')
                    ->badge()
                    ->formatStateUsing(fn (TransactionStatus $state) => ucfirst($state->value))
                    ->icon(fn (TransactionStatus $state): string => match ($state) {
                        TransactionStatus::Successful => 'heroicon-o-check-circle',
                        TransactionStatus::Failed => 'heroicon-o-x-circle',
                        TransactionStatus::Reversed => 'heroicon-o-arrow-uturn-left',
                        TransactionStatus::Processing => 'heroicon-o-arrow-path',
                        TransactionStatus::Pending => 'heroicon-o-clock',
                    })
                    ->color(fn (TransactionStatus $state) => match ($state) {
                        TransactionStatus::Successful => 'success',
                        TransactionStatus::Failed => 'danger',
                        TransactionStatus::Reversed => 'warning',
                        TransactionStatus::Processing => 'warning',
                        TransactionStatus::Pending => 'gray',
                    }),
                TextColumn::make('provider')
                    ->badge()
                    ->color('gray')
                    ->placeholder('-'),
                TextColumn::make('created_at')
                    ->since()
                    ->tooltip(fn ($record) => $record->created_at?->format('M j, Y \a\t g:i A'))
                    ->sortable(),
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
                    ->icon('heroicon-o-banknotes')
                    ->schema([
                        TextEntry::make('reference')
                            ->icon('heroicon-o-hashtag')
                            ->copyable(),

                        TextEntry::make('user.email')
                            ->label('User')
                            ->icon('heroicon-o-user'),

                        TextEntry::make('type')
                            ->badge(),

                        TextEntry::make('amount')
                            ->money('NGN')
                            ->weight('semibold'),

                        TextEntry::make('status')
                            ->badge()
                            ->formatStateUsing(fn (TransactionStatus $state) => ucfirst($state->value))
                            ->color(fn (TransactionStatus $state) => match ($state) {
                                TransactionStatus::Successful => 'success',
                                TransactionStatus::Failed => 'danger',
                                TransactionStatus::Reversed => 'warning',
                                TransactionStatus::Processing => 'warning',
                                TransactionStatus::Pending => 'gray',
                            }),

                        TextEntry::make('provider')
                            ->badge()
                            ->color('gray')
                            ->placeholder('-'),

                        TextEntry::make('created_at')
                            ->icon('heroicon-o-clock')
                            ->dateTime(),
                    ]),
            ]);
    }
}
