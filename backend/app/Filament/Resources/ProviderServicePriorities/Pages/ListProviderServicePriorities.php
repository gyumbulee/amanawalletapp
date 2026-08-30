<?php

namespace App\Filament\Resources\ProviderServicePriorities\Pages;

use App\Filament\Resources\ProviderServicePriorities\ProviderServicePriorityResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListProviderServicePriorities extends ListRecords
{
    protected static string $resource = ProviderServicePriorityResource::class;

    protected function getHeaderActions(): array
    {
        return [CreateAction::make()];
    }
}
