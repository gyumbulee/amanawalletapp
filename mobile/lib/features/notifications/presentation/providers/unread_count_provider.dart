import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_repository_provider.dart';

/// Backs the small badge dot on the dashboard's notification bell icon.
/// Invalidate this after marking notifications as read so the badge
/// updates without needing a full app restart.
final unreadNotificationCountProvider = FutureProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).getUnreadCount();
});
