import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/transaction.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final TransactionStatus status;

  Color get _color {
    switch (status) {
      case TransactionStatus.successful:
        return AppColors.success;
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        return AppColors.warning;
      case TransactionStatus.failed:
      case TransactionStatus.reversed:
        return AppColors.error;
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
