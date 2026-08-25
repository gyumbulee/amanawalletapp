<?php

namespace App\Services;

use App\Enums\SupportTicketSenderType;
use App\Enums\SupportTicketStatus;
use App\Models\SupportTicket;
use App\Models\Transaction;
use App\Models\User;
use App\Notifications\SupportTicketReplyNotification;
use App\Repositories\Interfaces\SupportTicketRepositoryInterface;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class SupportTicketService
{
    public function __construct(
        protected SupportTicketRepositoryInterface $ticketRepository
    ) {}

    public function createTicket(User $user, string $subject, string $message, ?string $transactionReference = null): SupportTicket
    {
        return DB::transaction(function () use ($user, $subject, $message, $transactionReference) {
            $transaction = null;

            if ($transactionReference) {
                $transaction = Transaction::query()
                    ->where('reference', $transactionReference)
                    ->where('user_id', $user->id)
                    ->first();

                if (! $transaction) {
                    throw new RuntimeException('That transaction could not be found on your account.');
                }
            }

            $ticket = $this->ticketRepository->create([
                'user_id' => $user->id,
                'transaction_id' => $transaction?->id,
                'subject' => $subject,
                'status' => SupportTicketStatus::Open,
                'last_message_at' => now(),
            ]);

            $ticket->messages()->create([
                'sender_type' => SupportTicketSenderType::User,
                'sender_id' => $user->id,
                'message' => $message,
            ]);

            return $ticket->load('messages', 'transaction');
        });
    }

    /**
     * User adds a follow-up reply. A closed/resolved ticket is reopened as
     * 'pending' - the user replying is a clear signal it isn't actually
     * resolved for them, and this keeps it visible in the admin queue
     * instead of silently attaching to a ticket nobody is watching.
     */
    public function addUserReply(SupportTicket $ticket, User $user, string $message): SupportTicket
    {
        return DB::transaction(function () use ($ticket, $user, $message) {
            $ticket->messages()->create([
                'sender_type' => SupportTicketSenderType::User,
                'sender_id' => $user->id,
                'message' => $message,
            ]);

            $newStatus = in_array($ticket->status, [SupportTicketStatus::Resolved, SupportTicketStatus::Closed], true)
                ? SupportTicketStatus::Pending
                : $ticket->status;

            $ticket->update([
                'status' => $newStatus,
                'last_message_at' => now(),
            ]);

            return $ticket->load('messages', 'transaction');
        });
    }

    /**
     * Admin reply, called from the Filament resource. Sets status to
     * 'pending' (awaiting the user) and notifies them - mirrors the
     * TransactionStatusNotification pattern (mail + in-app database
     * notification) used elsewhere in this app.
     */
    public function addAdminReply(SupportTicket $ticket, int $adminId, string $message): SupportTicket
    {
        return DB::transaction(function () use ($ticket, $adminId, $message) {
            $ticket->messages()->create([
                'sender_type' => SupportTicketSenderType::Admin,
                'sender_id' => $adminId,
                'message' => $message,
            ]);

            $ticket->update([
                'status' => SupportTicketStatus::Pending,
                'last_message_at' => now(),
            ]);

            $ticket->user->notify(new SupportTicketReplyNotification($ticket, Str::limit($message, 100)));

            return $ticket->load('messages', 'transaction');
        });
    }
}
