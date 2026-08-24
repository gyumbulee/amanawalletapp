import '../../domain/entities/support_ticket_message.dart';

class SupportTicketMessageModel {
  static SupportTicketMessage fromJson(Map<String, dynamic> json) {
    return SupportTicketMessage(
      id: json['id'] as String,
      senderType: SupportSenderType.fromApi(json['sender_type'] as String?),
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
