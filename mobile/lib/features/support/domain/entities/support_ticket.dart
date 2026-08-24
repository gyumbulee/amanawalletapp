import 'package:equatable/equatable.dart';
import 'support_ticket_message.dart';

enum SupportTicketStatus {
  open,
  pending,
  resolved,
  closed;

  static SupportTicketStatus fromApi(String? value) {
    switch (value) {
      case 'pending':
        return SupportTicketStatus.pending;
      case 'resolved':
        return SupportTicketStatus.resolved;
      case 'closed':
        return SupportTicketStatus.closed;
      case 'open':
      default:
        return SupportTicketStatus.open;
    }
  }

  String get label {
    switch (this) {
      case SupportTicketStatus.open:
        return 'Open';
      case SupportTicketStatus.pending:
        return 'Pending';
      case SupportTicketStatus.resolved:
        return 'Resolved';
      case SupportTicketStatus.closed:
        return 'Closed';
    }
  }
}

class SupportTicket extends Equatable {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
    this.transactionReference,
    this.lastMessageAt,
    this.messages = const [],
  });

  final String id;
  final String subject;
  final SupportTicketStatus status;
  final String? transactionReference;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final List<SupportTicketMessage> messages;

  @override
  List<Object?> get props => [id, subject, status, transactionReference, lastMessageAt, createdAt, messages];
}
