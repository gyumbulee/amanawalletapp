import '../../domain/entities/app_notification.dart';

/// JSON <-> [AppNotification] mapping.
///
/// Actual `GET /notifications` row shape (list wraps under "notifications",
/// handled in the repository), confirmed from a real response:
/// ```
/// { "id": "...", "type": "Referral Bonus Earned",
///   "data": { "title": "...", "message": "...", "amount": 200 },
///   "read": false, "created_at": "..." }
/// ```
/// Title/message are nested under "data", and read state is a plain
/// boolean "read" — not "read_at"/"is_read" as first guessed.
class AppNotificationModel {
  static AppNotification fromJson(Map<String, dynamic> json) {
    final inner = json['data'] as Map<String, dynamic>?;
    final isRead = json['read'] == true || json['read_at'] != null || json['is_read'] == true;

    return AppNotification(
      id: json['id'].toString(),
      title: (inner?['title'] ?? json['title']) as String? ?? '',
      message: (inner?['message'] ?? json['message'] ?? json['body']) as String? ?? '',
      isRead: isRead,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
