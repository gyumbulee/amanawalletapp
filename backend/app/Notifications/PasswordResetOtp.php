<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class PasswordResetOtp extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public string $token)
    {
    }

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Reset your Amana Wallet password')
            ->greeting('Hello ' . $notifiable->first_name . ',')
            ->line('Your password reset code is:')
            ->line("**{$this->token}**")
            ->line('This code expires in 60 minutes.')
            ->line('If you did not request a password reset, no further action is required.');
    }
}