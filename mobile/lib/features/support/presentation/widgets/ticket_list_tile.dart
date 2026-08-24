import 'package:flutter/material.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/support_ticket.dart';
import 'ticket_status_badge.dart';

class TicketListTile extends StatelessWidget {
  const TicketListTile({super.key, required this.ticket, required this.onTap});

  final SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (ticket.transactionReference != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Re: ${ticket.transactionReference}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  _formatDate(ticket.lastMessageAt ?? ticket.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TicketStatusBadge(status: ticket.status),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}
