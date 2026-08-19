import 'package:dio/dio.dart';
import '../../../../constants/api_endpoints.dart';

class NotificationApiService {
  NotificationApiService(this._dio);
  final Dio _dio;

  Future<Response> getNotifications({int page = 1}) =>
      _dio.get(ApiEndpoints.notifications, queryParameters: {'page': page});

  Future<Response> getUnreadCount() => _dio.get(ApiEndpoints.notificationsUnreadCount);

  Future<Response> markAsRead(String id) => _dio.post(ApiEndpoints.markNotificationRead(id));

  Future<Response> markAllAsRead() => _dio.post(ApiEndpoints.notificationsMarkAllRead);
}
