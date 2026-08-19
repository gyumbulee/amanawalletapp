import '../../../../core/network/paginated_result.dart';
import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Future<PaginatedResult<AppNotification>> getNotifications({int page = 1});

  Future<int> getUnreadCount();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}
