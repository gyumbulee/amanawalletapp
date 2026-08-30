<?php

namespace App\Filament\Resources\ProviderServicePriorities\Pages;

use App\Filament\Resources\ProviderServicePriorities\ProviderServicePriorityResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditProviderServicePriority extends EditRecord
{
    protected static string $resource = ProviderServicePriorityResource::class;

    protected function getHeaderActions(): array
    {
        return [DeleteAction::make()];
    }
}
