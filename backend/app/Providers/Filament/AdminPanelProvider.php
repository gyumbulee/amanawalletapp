<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\PreventRequestForgery;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->brandName('Amana Wallet')
            ->brandLogo(fn () => view('filament.brand-logo'))
            ->brandLogoHeight('1.75rem')
            ->favicon(asset('favicon.svg'))
            ->authGuard('admin')
            ->login()
            // Every one of these is an exact match to Branding.md's hex
            // values (Royal Blue #2563EB = Tailwind blue-600, Success
            // #22C55E = green-500, Warning #F59E0B = amber-500, Error
            // #EF4444 = red-500, Charcoal Gray #374151 = gray-700) - using
            // Filament's native palettes rather than one-off hex codes
            // gives every shade in the ramp (hover/focus/subtle-background
            // states) that Filament's components expect, not just the one
            // shade a single hex would define.
            ->colors([
                'primary' => Color::Blue,
                'gray' => Color::Gray,
                'success' => Color::Green,
                'warning' => Color::Amber,
                'danger' => Color::Red,
                'info' => Color::Sky,
            ])
            ->font('Poppins')
            ->spa()
            ->sidebarCollapsibleOnDesktop()

            ->discoverResources(
                in: app_path('Filament/Resources'),
                for: 'App\\Filament\\Resources'
            )

            ->discoverPages(
                in: app_path('Filament/Pages'),
                for: 'App\\Filament\\Pages'
            )

            ->pages([])

            ->discoverWidgets(
                in: app_path('Filament/Widgets'),
                for: 'App\\Filament\\Widgets'
            )

            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                PreventRequestForgery::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])

            ->authMiddleware([
                Authenticate::class,
            ]);
    }
}
