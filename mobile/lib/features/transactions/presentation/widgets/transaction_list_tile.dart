import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/transaction.dart';
import 'status_badge.dart';
import 'transaction_service_icon.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({super.key, required this.transaction, this.onTap});

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppColors.success : AppColors.primary;
    final sign = isCredit ? '+' : '-';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(transactionServiceIcon(transaction.service), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : transaction.service.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, y • h:mm a').format(transaction.createdAt),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${transaction.amountKobo.toNairaDisplay()}',
                  style: TextStyle(
                    color: isCredit ? AppColors.success : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                StatusBadge(status: transaction.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
