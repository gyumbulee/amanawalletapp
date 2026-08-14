<?php

namespace App\Notifications;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ReferralBonusEarnedNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public float $amount, public User $referredUser)
    {
    }

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('You Earned a Referral Bonus!')
            ->greeting('Hello ' . $notifiable->first_name . ',')
            ->line("You just earned ₦{$this->amount} because {$this->referredUser->first_name} {$this->referredUser->last_name}, someone you referred, completed a qualifying transaction.")
            ->line('The bonus has been credited to your wallet.');
    }

    public function toArray(object $notifiable): array
    {
        return [
            'title' => 'Referral Bonus Earned',
            'message' => "You earned ₦{$this->amount} from referring {$this->referredUser->first_name} {$this->referredUser->last_name}.",
            'amount' => $this->amount,
        ];
    }
}