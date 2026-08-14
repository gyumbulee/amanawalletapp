<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Pages\ViewRecord;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ViewUser extends ViewRecord
{
    protected static string $resource = UserResource::class;

    public function infolist(Schema $schema): Schema
    {
        return $schema->components([
            Section::make('Profile')
                ->columns(2)
                ->components([
                    TextEntry::make('first_name'),
                    TextEntry::make('last_name'),
                    TextEntry::make('email'),
                    TextEntry::make('phone'),
                    TextEntry::make('status')->badge(),
                    TextEntry::make('referral_code')->copyable(),
                ]),
            Section::make('Wallet')
                ->columns(3)
                ->components([
                    TextEntry::make('wallet.balance')->label('Balance')->money('NGN'),
                    TextEntry::make('wallet.status')->label('Wallet Status')->badge(),
                    TextEntry::make('wallet.currency')->label('Currency'),
                ]),
            Section::make('Virtual Account')
                ->columns(3)
                ->components([
                    TextEntry::make('virtualAccount.account_number')->label('Account Number')->copyable(),
                    TextEntry::make('virtualAccount.bank_name')->label('Bank'),
                    TextEntry::make('virtualAccount.status')->label('Status')->badge(),
                ]),
        ]);
    }
}