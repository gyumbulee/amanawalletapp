<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('support_ticket_messages', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->foreignId('support_ticket_id')->constrained()->cascadeOnDelete();
            $table->string('sender_type'); // SupportTicketSenderType enum: 'user' | 'admin'
            // Nullable so a sender_id column doesn't have to be tied to a
            // single guard's table (user_id vs admin_id) — same reasoning
            // as this project's other admin-vs-user split (Sanctum 'users'
            // guard, session 'admins' guard on separate tables).
            $table->unsignedBigInteger('sender_id')->nullable();
            $table->text('message');
            $table->timestamps();

            $table->index(['support_ticket_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('support_ticket_messages');
    }
};
