import '../../domain/entities/support_ticket.dart';
import 'support_ticket_message_model.dart';

class SupportTicketModel {
  static SupportTicket fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'] as List<dynamic>? ?? [];

    return SupportTicket(
      id: json['id'] as String,
      subject: json['subject'] as String? ?? '',
      status: SupportTicketStatus.fromApi(json['status'] as String?),
      transactionReference: json['transaction_reference'] as String?,
      lastMessageAt: json['last_message_at'] != null ? DateTime.parse(json['last_message_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      messages: messagesJson
          .map((m) => SupportTicketMessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
