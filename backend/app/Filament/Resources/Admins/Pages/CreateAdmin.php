<?php

namespace App\Filament\Resources\Admins\Pages;

use App\Filament\Resources\Admins\AdminResource;
use App\Notifications\AdminCredentialsNotification;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class CreateAdmin extends CreateRecord
{
    protected static string $resource = AdminResource::class;

    protected string $generatedPassword;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Password is never entered by the super-admin — generate a strong
        // random one, store the plain copy just long enough to email it.
        $this->generatedPassword = Str::password(14);
        $data['password'] = Hash::make($this->generatedPassword);

        return $data;
    }

    protected function afterCreate(): void
    {
        $this->record->notify(new AdminCredentialsNotification($this->generatedPassword));
    }
}
