<?php

namespace App\Notifications;

use App\Models\SupportTicket;
use App\Notifications\Channels\FcmChannel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class SupportTicketReplyNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public SupportTicket $ticket, public string $messagePreview) {}

    public function via(object $notifiable): array
    {
        return ['mail', 'database', FcmChannel::class];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('New reply on your support ticket')
            ->greeting('Hello '.$notifiable->first_name.',')
            ->line("There's a new reply on your ticket: \"{$this->ticket->subject}\"")
            ->line($this->messagePreview)
            ->line('Open the app to view the full conversation and reply.');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'title' => 'New reply on your support ticket',
            'message' => $this->messagePreview,
            'ticket_id' => $this->ticket->uuid,
            'subject' => $this->ticket->subject,
        ];
    }

    public function toFcm(object $notifiable): array
    {
        return [
            'title' => 'New reply on your support ticket',
            'body' => $this->messagePreview,
            'data' => [
                'type' => 'support_ticket_reply',
                'ticket_id' => $this->ticket->uuid,
            ],
        ];
    }
}
