<?php

namespace App\Filament\Resources\Banners;

use App\Filament\Resources\Banners\Pages\CreateBanner;
use App\Filament\Resources\Banners\Pages\EditBanner;
use App\Filament\Resources\Banners\Pages\ListBanners;
use App\Models\Banner;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;
use BackedEnum;
use UnitEnum;

class BannerResource extends Resource
{
    protected static ?string $model = Banner::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-photo';

    protected static string|UnitEnum|null $navigationGroup = 'Configuration';

    /**
     * Deep-link targets a banner can point to. Keep in sync with the
     * Flutter app's GoRouter routes for each service.
     */
    private const SERVICE_LINKS = [
        'wallet_funding' => 'Fund Wallet',
        'airtime' => 'Airtime',
        'data' => 'Data',
        'electricity' => 'Electricity',
        'cable' => 'Cable TV',
        'education' => 'Education',
        'referral' => 'Referral',
    ];

    public static function form(Schema $schema): Schema
    {
        return $schema->components([
            TextInput::make('title')
                ->required()
                ->helperText('Not shown on the banner itself - used as the image alt text and here in admin.'),

            FileUpload::make('image_path')
                ->label('Banner Image')
                ->image()
                ->disk('public')
                ->directory('banners')
                ->imageEditor()
                ->required()
                ->helperText('Recommended: a wide banner image, e.g. 1200×500px, so it isn\'t stretched or cropped oddly on different screen sizes.'),

            Select::make('link_type')
                ->options([
                    'none' => 'Not tappable',
                    'service' => 'Open a service in the app',
                    'url' => 'Open a web link',
                ])
                ->default('none')
                ->required()
                ->live(),

            Select::make('link_value')
                ->label('Service')
                ->options(self::SERVICE_LINKS)
                ->required(fn (Get $get) => $get('link_type') === 'service')
                ->visible(fn (Get $get) => $get('link_type') === 'service')
                ->dehydrated(fn (Get $get) => $get('link_type') === 'service'),

            TextInput::make('link_value')
                ->label('URL')
                ->url()
                ->required(fn (Get $get) => $get('link_type') === 'url')
                ->visible(fn (Get $get) => $get('link_type') === 'url')
                ->dehydrated(fn (Get $get) => $get('link_type') === 'url'),

            TextInput::make('sort_order')
                ->numeric()
                ->default(0)
                ->helperText('Lower number shows first in the carousel.'),

            DateTimePicker::make('starts_at')
                ->label('Show from (optional)')
                ->helperText('Leave blank to show immediately.'),

            DateTimePicker::make('ends_at')
                ->label('Show until (optional)')
                ->helperText('Leave blank to show indefinitely.'),

            Toggle::make('is_active')->default(true),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image_path')->disk('public')->label('Preview'),
                TextColumn::make('title')->weight('semibold'),
                TextColumn::make('link_type')
                    ->badge()
                    ->icon(fn (string $state): string => match ($state) {
                        'service' => 'heroicon-o-arrow-top-right-on-square',
                        'url' => 'heroicon-o-link',
                        default => 'heroicon-o-no-symbol',
                    }),
                TextColumn::make('sort_order')
                    ->label('Order')
                    ->icon('heroicon-o-bars-3')
                    ->sortable(),
                ToggleColumn::make('is_active')->label('Active'),
                TextColumn::make('ends_at')
                    ->label('Expires')
                    ->icon('heroicon-o-calendar')
                    ->dateTime()
                    ->placeholder('Never')
                    ->color(fn ($state) => $state && $state->isPast() ? 'danger' : null),
            ])
            ->defaultSort('sort_order');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListBanners::route('/'),
            'create' => CreateBanner::route('/create'),
            'edit' => EditBanner::route('/{record}/edit'),
        ];
    }
}
