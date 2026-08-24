import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/support_ticket.dart';

class TicketStatusBadge extends StatelessWidget {
  const TicketStatusBadge({super.key, required this.status});

  final SupportTicketStatus status;

  Color get _color {
    switch (status) {
      case SupportTicketStatus.open:
        return AppColors.error;
      case SupportTicketStatus.pending:
        return AppColors.warning;
      case SupportTicketStatus.resolved:
        return AppColors.success;
      case SupportTicketStatus.closed:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
