<?php

namespace App\Filament\Resources\Users\RelationManagers;

use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class TransactionsRelationManager extends RelationManager
{
    protected static string $relationship = 'transactions';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('reference')
            ->columns([
                TextColumn::make('reference')->copyable(),
                TextColumn::make('type')->badge(),
                TextColumn::make('amount')->money('NGN'),
                TextColumn::make('status')
    ->badge()
    ->color(fn ($state): string => match ($state->value) {
        'successful' => 'success',
        'failed' => 'danger',
        'reversed' => 'warning',
        default => 'gray',
    }),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->defaultSort('created_at', 'desc');
    }
}