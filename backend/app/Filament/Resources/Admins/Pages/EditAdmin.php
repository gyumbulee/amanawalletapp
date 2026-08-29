<?php

namespace App\Filament\Resources\Admins\Pages;

use App\Filament\Resources\Admins\AdminResource;
use App\Notifications\AdminCredentialsNotification;
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class EditAdmin extends EditRecord
{
    protected static string $resource = AdminResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('resetPassword')
                ->label('Reset & Email Password')
                ->icon('heroicon-o-key')
                ->requiresConfirmation()
                ->modalDescription('A new password will be generated and emailed to this admin. Their current password stops working immediately.')
                ->action(function () {
                    $plainPassword = Str::password(14);

                    $this->record->forceFill([
                        'password' => Hash::make($plainPassword),
                    ])->save();

                    $this->record->notify(new AdminCredentialsNotification($plainPassword));

                    Notification::make()
                        ->title('New password emailed to ' . $this->record->email)
                        ->success()
                        ->send();
                }),
        ];
    }
}
