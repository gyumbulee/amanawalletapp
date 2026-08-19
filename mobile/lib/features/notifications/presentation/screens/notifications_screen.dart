import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../providers/notification_list_provider.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(notificationListProvider);
    final hasUnread = listAsync.value?.notifications.any((n) => !n.isRead) ?? false;

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () => ref.read(notificationListProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationListProvider),
        child: listAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: List.generate(6, (_) => const SkeletonListTile()),
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: 'Could not load notifications. Pull down to try again.',
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(notificationListProvider),
                ),
              ),
            ],
          ),
          data: (listState) {
            if (listState.notifications.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: EmptyState(
                      icon: Icons.notifications_none_rounded,
                      message: "You're all caught up. No notifications yet.",
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: listState.notifications.length + (listState.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= listState.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final notification = listState.notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => ref.read(notificationListProvider.notifier).markAsRead(notification.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
