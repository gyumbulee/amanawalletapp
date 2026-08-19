import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_notification.dart';
import 'notification_repository_provider.dart';
import 'unread_count_provider.dart';

class NotificationListState {
  const NotificationListState({
    this.notifications = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<AppNotification> notifications;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  NotificationListState copyWith({
    List<AppNotification>? notifications,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Same pagination pattern as the wallet ledger / transactions / referral
/// history controllers, plus mark-as-read actions that update the local
/// list optimistically (no need to refetch the whole page for a read-state
/// flip) and refresh the unread badge count.
class NotificationListController extends AsyncNotifier<NotificationListState> {
  @override
  Future<NotificationListState> build() async {
    final result = await ref.read(notificationRepositoryProvider).getNotifications(page: 1);
    return NotificationListState(
      notifications: result.items,
      currentPage: result.currentPage,
      hasMore: result.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final result = await ref.read(notificationRepositoryProvider).getNotifications(page: nextPage);
      state = AsyncData(current.copyWith(
        notifications: [...current.notifications, ...result.items],
        currentPage: result.currentPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return;

    final alreadyRead = current.notifications.firstWhere((n) => n.id == id, orElse: () => current.notifications.first).isRead;
    if (alreadyRead) return;

    // Optimistic update — flip locally first so the tap feels instant.
    state = AsyncData(current.copyWith(
      notifications: [
        for (final n in current.notifications)
          if (n.id == id) n.copyWith(isRead: true) else n,
      ],
    ));

    try {
      await ref.read(notificationRepositoryProvider).markAsRead(id);
      ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {
      // Revert on failure.
      state = AsyncData(current);
    }
  }

  Future<void> markAllAsRead() async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      notifications: [for (final n in current.notifications) n.copyWith(isRead: true)],
    ));

    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
      ref.invalidate(unreadNotificationCountProvider);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final notificationListProvider =
    AsyncNotifierProvider<NotificationListController, NotificationListState>(
        NotificationListController.new);
