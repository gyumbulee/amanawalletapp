import 'package:flutter/material.dart';
import '../../../../shared/extensions/currency_extensions.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radii.dart';
import '../../domain/entities/data_plan.dart';

class DataPlanTile extends StatelessWidget {
  const DataPlanTile({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final DataPlan plan;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.sizeLabel,
                    // Container background is fixed (surface/accent-tint)
                    // regardless of theme, so this needs an explicit color
                    // too — same reasoning as PinConfirmSheet.
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.validityLabel,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
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
