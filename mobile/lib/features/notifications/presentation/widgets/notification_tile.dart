import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : AppColors.accent.withValues(alpha: 0.05),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: notification.isRead ? Colors.transparent : AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(notification.createdAt),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
