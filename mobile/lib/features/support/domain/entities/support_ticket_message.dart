import 'package:equatable/equatable.dart';

enum SupportSenderType {
  user,
  admin;

  static SupportSenderType fromApi(String? value) {
    return value == 'admin' ? SupportSenderType.admin : SupportSenderType.user;
  }
}

class SupportTicketMessage extends Equatable {
  const SupportTicketMessage({
    required this.id,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final SupportSenderType senderType;
  final String message;
  final DateTime createdAt;

  bool get isFromAdmin => senderType == SupportSenderType.admin;

  @override
  List<Object?> get props => [id, senderType, message, createdAt];
}
