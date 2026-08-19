import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/referral_entry.dart';

class ReferralEntryTile extends StatelessWidget {
  const ReferralEntryTile({super.key, required this.entry});

  final ReferralEntry entry;

  @override
  Widget build(BuildContext context) {
    final isCompleted = entry.status == ReferralStatus.completed;
    final statusColor = isCompleted ? AppColors.success : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.refereeName.isNotEmpty ? entry.refereeName : 'Referred user',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, y').format(entry.joinedAt),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${entry.bonusKobo.toNairaDisplay()}',
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
