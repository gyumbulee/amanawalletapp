<?php

namespace App\Notifications;

use App\Models\Transaction;
use App\Notifications\Channels\FcmChannel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class TransactionStatusNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public Transaction $transaction) {}

    public function via(object $notifiable): array
    {
        return ['mail', 'database', FcmChannel::class];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $message = (new MailMessage)
            ->subject($this->title())
            ->greeting('Hello '.$notifiable->first_name.',');

        match ($this->transaction->status->value) {
            'successful' => $message
                ->line("Your {$this->transaction->type->value} transaction of ₦{$this->transaction->amount} was successful.")
                ->line("Reference: {$this->transaction->reference}"),
            'reversed' => $message
                ->line("Your {$this->transaction->type->value} transaction of ₦{$this->transaction->amount} was reversed.")
                ->line('The full amount has been refunded to your wallet.')
                ->line("Reference: {$this->transaction->reference}"),
            default => $message
                ->line("Your {$this->transaction->type->value} transaction of ₦{$this->transaction->amount} failed.")
                ->line('Any reserved funds have been refunded to your wallet.')
                ->line("Reference: {$this->transaction->reference}"),
        };

        return $message;
    }

    public function toArray(object $notifiable): array
    {
        return [
            'title' => $this->title(),
            'message' => ucfirst($this->transaction->type->value).' - ₦'.$this->transaction->amount,
            'transaction_reference' => $this->transaction->reference,
            'status' => $this->transaction->status->value,
        ];
    }

    public function toFcm(object $notifiable): array
    {
        $body = match ($this->transaction->status->value) {
            'successful' => ucfirst($this->transaction->type->value)." of ₦{$this->transaction->amount} was successful.",
            'reversed' => ucfirst($this->transaction->type->value)." of ₦{$this->transaction->amount} was reversed and refunded to your wallet.",
            default => ucfirst($this->transaction->type->value)." of ₦{$this->transaction->amount} failed."
                .' Any reserved funds have been refunded.',
        };

        return [
            'title' => $this->title(),
            'body' => $body,
            'data' => [
                // The mobile client looks up transactions by UUID, not the
                // human-readable TXN- reference (see GET /transactions/{id})
                // - and 'uuid' here, not 'id', since TransactionResource
                // maps ->uuid to the "id" field the client actually reads.
                'type' => 'transaction_status',
                'transaction_id' => $this->transaction->uuid,
                'transaction_reference' => $this->transaction->reference,
                'status' => $this->transaction->status->value,
            ],
        ];
    }

    private function title(): string
    {
        return match ($this->transaction->status->value) {
            'successful' => 'Transaction Successful',
            'reversed' => 'Transaction Reversed',
            default => 'Transaction Failed',
        };
    }
}
