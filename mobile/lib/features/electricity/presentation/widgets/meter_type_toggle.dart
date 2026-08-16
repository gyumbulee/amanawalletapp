import 'package:flutter/material.dart';
import '../../../../constants/electricity_disco.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radii.dart';

class MeterTypeToggle extends StatelessWidget {
  const MeterTypeToggle({super.key, required this.selected, required this.onChanged});

  final MeterType selected;
  final ValueChanged<MeterType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MeterType.values.map((type) {
        final isSelected = selected == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: type == MeterType.prepaid ? 8 : 0),
            child: InkWell(
              onTap: () => onChanged(type),
              borderRadius: AppRadii.buttonRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : null,
                  borderRadius: AppRadii.buttonRadius,
                  border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
                ),
                child: Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
