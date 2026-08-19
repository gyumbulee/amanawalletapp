import 'package:flutter/material.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radii.dart';
import '../../domain/entities/education_plan.dart';

/// Same visual pattern as DataPlanTile/CablePackageTile — a fixed
/// always-light selection box, so text uses a fixed color rather than one
/// that inherits the ambient theme.
class EducationPlanTile extends StatelessWidget {
  const EducationPlanTile({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final EducationPlan plan;
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
                plan.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
            Text(
              plan.priceKobo.toNairaDisplay(),
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
