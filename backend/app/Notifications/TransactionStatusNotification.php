<?php

namespace App\Notifications;

use App\Models\Transaction;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class TransactionStatusNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public Transaction $transaction)
    {
    }

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $successful = $this->transaction->status->value === 'successful';

        $message = (new MailMessage)
            ->subject($successful ? 'Transaction Successful' : 'Transaction Failed')
            ->greeting('Hello ' . $notifiable->first_name . ',');

        if ($successful) {
            $message->line("Your {$this->transaction->type->value} transaction of ₦{$this->transaction->amount} was successful.")
                ->line("Reference: {$this->transaction->reference}");
        } else {
            $message->line("Your {$this->transaction->type->value} transaction of ₦{$this->transaction->amount} failed.")
                ->line('Any reserved funds have been refunded to your wallet.')
                ->line("Reference: {$this->transaction->reference}");
        }

        return $message;
    }

    public function toArray(object $notifiable): array
    {
        return [
            'title' => $this->transaction->status->value === 'successful' ? 'Transaction Successful' : 'Transaction Failed',
            'message' => ucfirst($this->transaction->type->value) . ' - ₦' . $this->transaction->amount,
            'transaction_reference' => $this->transaction->reference,
            'status' => $this->transaction->status->value,
        ];
    }
}