<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class AdminCredentialsNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public string $plainPassword)
    {
    }

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Your Amana Wallet Admin Account')
            ->greeting('Hello ' . $notifiable->name . ',')
            ->line('An admin account has been created for you on Amana Wallet.')
            ->line('Email: ' . $notifiable->email)
            ->line('Temporary password: **' . $this->plainPassword . '**')
            ->line('Please log in and change this password as soon as possible.')
            ->action('Go to Admin Panel', url('/admin/login'))
            ->line('If you were not expecting this account, please contact the platform owner.');
    }
}
