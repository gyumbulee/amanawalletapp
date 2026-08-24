import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/support_ticket_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final SupportTicketMessage message;

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isFromAdmin;
    // Admin bubble uses the theme's surface color (not a hardcoded
    // AppColors constant) so it stays legible in dark mode — same reasoning
    // as AppCard relying on CardTheme rather than a fixed white background.
    final adminBubbleColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final adminTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textPrimary;

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isAdmin ? adminBubbleColor : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isAdmin ? 2 : 14),
            bottomRight: Radius.circular(isAdmin ? 14 : 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isAdmin ? 'Support Team' : 'You',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isAdmin ? adminTextColor.withValues(alpha: 0.6) : Colors.white70,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message.message,
              style: TextStyle(fontSize: 14, color: isAdmin ? adminTextColor : Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isAdmin ? adminTextColor.withValues(alpha: 0.6) : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
