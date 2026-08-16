import 'package:flutter/material.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radii.dart';
import '../../domain/entities/cable_package.dart';

/// Same visual pattern as DataPlanTile — a fixed always-light selection
/// box, so the price/name text uses a fixed color rather than one that
/// inherits the ambient theme (same dark-mode lesson from data_plan_tile).
class CablePackageTile extends StatelessWidget {
  const CablePackageTile({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  final CablePackage package;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardRadius,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: AppRadii.cardRadius,
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                package.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
            Text(
              package.priceKobo.toNairaDisplay(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isSelected ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
