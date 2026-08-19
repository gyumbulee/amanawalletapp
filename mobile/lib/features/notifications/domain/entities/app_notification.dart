import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, message, isRead, createdAt];
}
