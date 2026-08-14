<?php

namespace App\Filament\Resources\RechargeCardBatches\RelationManagers;

use App\Models\RechargeCard;
use Filament\Actions\Action;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class CardsRelationManager extends RelationManager
{
    protected static string $relationship = 'cards';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('serial_number')
            ->columns([
                TextColumn::make('serial_number')->searchable()->copyable(),
                TextColumn::make('pin')->label('PIN')->copyable(),
                TextColumn::make('denomination')->money('NGN'),
                IconColumn::make('is_printed')->boolean()->label('Printed'),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->filters([
                TernaryFilter::make('is_printed'),
            ])
            ->recordActions([
                Action::make('mark_printed')
                    ->label('Mark Printed')
                    ->icon('heroicon-o-printer')
                    ->visible(fn (RechargeCard $record) => ! $record->is_printed)
                    ->action(fn (RechargeCard $record) => $record->update(['is_printed' => true])),
            ]);
    }
}