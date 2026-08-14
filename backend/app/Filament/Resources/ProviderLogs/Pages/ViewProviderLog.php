<?php

namespace App\Filament\Resources\ProviderLogs\Pages;

use App\Filament\Resources\ProviderLogs\ProviderLogResource;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Pages\ViewRecord;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ViewProviderLog extends ViewRecord
{
    protected static string $resource = ProviderLogResource::class;

    public function infolist(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Summary')
                ->columns(3)
                ->components([
                    TextEntry::make('provider')->badge(),
                    TextEntry::make('service_type'),
                    TextEntry::make('status')->badge(),
                    TextEntry::make('request_reference')->copyable(),
                    TextEntry::make('transaction_reference')->copyable(),
                    TextEntry::make('duration_ms'),
                    TextEntry::make('error_message')->columnSpanFull(),
                ]),
            Section::make('Request Payload')
                ->components([
                    TextEntry::make('request_payload')
                        ->formatStateUsing(fn ($state) => json_encode($state, JSON_PRETTY_PRINT))
                        ->columnSpanFull(),
                ]),
            Section::make('Response Payload')
                ->components([
                    TextEntry::make('response_payload')
                        ->formatStateUsing(fn ($state) => json_encode($state, JSON_PRETTY_PRINT))
                        ->columnSpanFull(),
                ]),
        ]);
    }
}