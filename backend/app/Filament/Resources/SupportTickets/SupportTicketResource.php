<?php

namespace App\Filament\Resources\SupportTickets;

use App\Filament\Resources\SupportTickets\Pages\ListSupportTickets;
use App\Models\AuditLog;
use App\Models\SupportTicket;
use App\Services\SupportTicketService;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Forms\Components\Placeholder;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use App\Enums\SupportTicketStatus;
use Illuminate\Support\HtmlString;
use UnitEnum;

class SupportTicketResource extends Resource
{
    protected static ?string $model = SupportTicket::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-lifebuoy';

    protected static string|UnitEnum|null $navigationGroup = 'Customers';

    protected static bool $canCreate = false;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.email')->label('User')->searchable(),
                TextColumn::make('subject')->limit(40)->searchable(),
                TextColumn::make('transaction.reference')->label('Transaction')->placeholder('—'),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (SupportTicketStatus $state): string => match ($state) {
                        SupportTicketStatus::Open => 'danger',
                        SupportTicketStatus::Pending => 'warning',
                        SupportTicketStatus::Resolved => 'success',
                        SupportTicketStatus::Closed => 'gray',
                    }),
                TextColumn::make('messages_count')->counts('messages')->label('Messages'),
                TextColumn::make('last_message_at')->dateTime()->sortable(),
                TextColumn::make('created_at')->dateTime()->sortable(),
            ])
            ->filters([
                SelectFilter::make('status')->options([
    SupportTicketStatus::Open->value => 'Open',
    SupportTicketStatus::Pending->value => 'Pending',
    SupportTicketStatus::Resolved->value => 'Resolved',
    SupportTicketStatus::Closed->value => 'Closed',
]),
            ])
            ->recordActions([
                Action::make('viewThread')
                    ->label('View / Reply')
                    ->icon('heroicon-o-chat-bubble-left-right')
                    ->schema(fn (SupportTicket $record) => [
                        Placeholder::make('thread')
                            ->label('Conversation')
                            ->content(fn () => new HtmlString(
                                $record->messages->map(fn ($m) => sprintf(
                                    '<div style="margin-bottom:14px;padding-bottom:10px;border-bottom:1px solid #e5e7eb;">'
                                        . '<strong>%s</strong> <span style="color:#6b7280;font-size:12px;">%s</span>'
                                        . '<div style="margin-top:4px;">%s</div></div>',
                                    $m->sender_type->value === 'admin' ? 'Support Team' : 'Customer',
                                    $m->created_at->format('M j, Y g:ia'),
                                    nl2br(e($m->message))
                                ))->implode('')
                            )),
                        Textarea::make('reply')
                            ->label('Your reply')
                            ->rows(4)
                            ->required(),
                        Select::make('status')
                            ->label('Set status to')
                            ->options([
                                'pending' => 'Pending (default after replying)',
                                'resolved' => 'Resolved',
                                'closed' => 'Closed',
                            ])
                            ->default('pending'),
                    ])
                    ->action(function (SupportTicket $record, array $data) {
                        app(SupportTicketService::class)->addAdminReply(
                            $record,
                            auth('admin')->id(),
                            $data['reply']
                        );

                        // addAdminReply always sets 'pending' — only override
                        // if the admin explicitly picked resolved/closed.
                        if (in_array($data['status'] ?? null, ['resolved', 'closed'], true)) {
                            $record->update(['status' => $data['status']]);
                        }

                        AuditLog::record('support_ticket.reply', $record, ['message' => $data['reply']]);
                    }),
                Action::make('resolve')
                    ->action(function (SupportTicket $record) {
                        $record->update(['status' => 'resolved']);
                        AuditLog::record('support_ticket.resolve', $record);
                    })
                    ->requiresConfirmation()
                    ->color('success')
                    ->icon('heroicon-o-check-circle')
                    ->visible(fn (SupportTicket $record) => in_array($record->status->value, ['open', 'pending'], true)),
                Action::make('close')
                    ->action(function (SupportTicket $record) {
                        $record->update(['status' => 'closed']);
                        AuditLog::record('support_ticket.close', $record);
                    })
                    ->requiresConfirmation()
                    ->color('gray')
                    ->icon('heroicon-o-x-circle')
                    ->visible(fn (SupportTicket $record) => $record->status->value !== 'closed'),
            ])
            ->defaultSort('last_message_at', 'desc');
    }

    public static function getPages(): array
    {
        return [
            'index' => ListSupportTickets::route('/'),
        ];
    }
}
