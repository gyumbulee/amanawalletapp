<?php

namespace App\Filament\Pages;

use App\Models\AuditLog;
use App\Models\Setting;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ManageSettings extends Page implements HasForms
{
    use InteractsWithForms;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static string|\UnitEnum|null $navigationGroup = 'Configuration';

    protected string $view = 'filament.pages.manage-settings';

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill([
            'maintenance_mode' => (bool) Setting::get('maintenance_mode', false),
            'referral_bonus_amount' => Setting::get('referral_bonus_amount', 200),
            'company_name' => Setting::get('company_name', 'Amana Global Enterprise'),
            'company_email' => Setting::get('company_email', ''),
            'company_phone' => Setting::get('company_phone', ''),
            'support_email' => Setting::get('support_email', ''),
        ]);
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Platform')
                    ->icon('heroicon-o-adjustments-horizontal')
                    ->description('Maintenance mode and the referral bonus every new user\'s referrer earns.')
                    ->components([
                        Toggle::make('maintenance_mode')
                            ->helperText('When enabled, the mobile/web app should show a maintenance screen. (Enforcement happens client-side / via a middleware check on this setting.)'),
                        TextInput::make('referral_bonus_amount')->numeric()->required()->prefix('₦'),
                    ]),
                Section::make('Company Information')
                    ->icon('heroicon-o-building-office')
                    ->description('Shown across customer-facing communications and receipts.')
                    ->columns(2)
                    ->components([
                        TextInput::make('company_name')->required(),
                        TextInput::make('company_email')->email(),
                        TextInput::make('company_phone'),
                    ]),
                Section::make('Email Settings')
                    ->icon('heroicon-o-envelope')
                    ->components([
                        TextInput::make('support_email')->email()
                            ->helperText('Shown to users as the support contact address.'),
                    ]),
            ])
            ->statePath('data');
    }

    public function save(): void
    {
        $data = $this->form->getState();

        foreach ($data as $key => $value) {
            Setting::set($key, is_bool($value) ? (int) $value : $value);
        }

        AuditLog::record('settings.update', changes: $data);

        Notification::make()->title('Settings saved')->success()->send();
    }
}
