<?php

namespace App\Filament\Resources\Kycs;

use App\Filament\Resources\Kycs\Pages\ListKycs;
use App\Models\AuditLog;
use App\Models\Kyc;
use Filament\Actions\Action;
use Filament\Forms\Components\Textarea;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class KycResource extends Resource
{
    protected static ?string $model = Kyc::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-identification';

    protected static string|UnitEnum|null $navigationGroup = 'Customers';

    protected static bool $canCreate = false;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.email')->label('User')->searchable(),
                TextColumn::make('type')->badge(),
                TextColumn::make('status')->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'verified' => 'success',
                        'rejected' => 'danger',
                        default => 'warning',
                    }),
                TextColumn::make('rejection_reason')->limit(40)->placeholder('-'),
                TextColumn::make('verified_at')->dateTime()->placeholder('-'),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->filters([
                SelectFilter::make('type')->options([
                    'bvn' => 'BVN', 'nin' => 'NIN', 'id_card' => 'ID Card', 'proof_of_address' => 'Proof of Address',
                ]),
                SelectFilter::make('status')->options([
                    'pending' => 'Pending', 'verified' => 'Verified', 'rejected' => 'Rejected',
                ]),
            ])
            ->recordActions([
                Action::make('approve')
                    ->action(function (Kyc $record) {
                        $record->update(['status' => 'verified', 'verified_at' => now(), 'rejection_reason' => null]);
                        AuditLog::record('kyc.approve', $record);
                    })
                    ->requiresConfirmation()
                    ->color('success')
                    ->visible(fn (Kyc $record) => $record->status->value === 'pending'),
                Action::make('reject')
                    ->schema([Textarea::make('rejection_reason')->required()])
                    ->action(function (Kyc $record, array $data) {
                        $record->update(['status' => 'rejected', 'rejection_reason' => $data['rejection_reason']]);
                        AuditLog::record('kyc.reject', $record, $data);
                    })
                    ->requiresConfirmation()
                    ->color('danger')
                    ->visible(fn (Kyc $record) => $record->status->value === 'pending'),
            ])
            ->defaultSort('created_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListKycs::route('/'),
        ];
    }
}