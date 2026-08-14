<?php

namespace App\Filament\Resources\Users\Schemas;

use App\Enums\UserStatus;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('uuid')
                    ->label('UUID')
                    ->required(),
                TextInput::make('first_name')
                    ->required(),
                TextInput::make('last_name')
                    ->required(),
                TextInput::make('email')
                    ->label('Email address')
                    ->email()
                    ->required(),
                TextInput::make('phone')
                    ->tel()
                    ->required(),
                TextInput::make('bvn')
                    ->default(null),
                DateTimePicker::make('bvn_verified_at'),
                TextInput::make('password')
                    ->password()
                    ->required(),
                TextInput::make('referral_code')
                    ->required(),
                TextInput::make('referred_by')
                    ->numeric()
                    ->default(null),
                Select::make('status')
                    ->options(UserStatus::class)
                    ->default('active')
                    ->required(),
                TextInput::make('profile_photo_path')
                    ->default(null),
                DateTimePicker::make('email_verified_at'),
            ]);
    }
}
