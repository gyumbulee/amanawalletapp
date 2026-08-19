import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/paginated_result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_api_service.dart';
import '../models/app_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._api);
  final NotificationApiService _api;

  @override
  Future<PaginatedResult<AppNotification>> getNotifications({int page = 1}) async {
    try {
      final response = await _api.getNotifications(page: page);
      final data = response.data as Map<String, dynamic>;
      // List wraps under "notifications", not "data" — confirmed from a
      // real response.
      final rawList = (data['notifications'] ?? data['data']) as List? ?? const [];
      final items =
          rawList.map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>)).toList();

      final meta = data['meta'] as Map<String, dynamic>?;
      return PaginatedResult(
        items: items,
        currentPage: meta?['current_page'] as int? ?? page,
        lastPage: meta?['last_page'] as int? ?? page,
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.getUnreadCount();
      final data = response.data as Map<String, dynamic>;
      final raw = data['count'] ?? data['unread_count'] ?? 0;
      return (raw as num).toInt();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _api.markAsRead(id);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _api.markAllAsRead();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
