import 'package:flutter/material.dart';
import '../../../shared/extensions/currency_extensions.dart';
import '../../../theme/app_colors.dart';

/// Row of preset amount chips (in kobo) — tapping one fills the amount
/// field. Shared across airtime, data, electricity, and cable so each
/// screen just supplies its own preset list.
class AmountQuickChips extends StatelessWidget {
  const AmountQuickChips({
    super.key,
    required this.amountsKobo,
    required this.selectedKobo,
    required this.onSelected,
  });

  final List<int> amountsKobo;
  final int? selectedKobo;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amountsKobo.map((amount) {
        final isSelected = selectedKobo == amount;
        return ChoiceChip(
          label: Text(amount.toNairaDisplay()),
          selected: isSelected,
          onSelected: (_) => onSelected(amount),
          selectedColor: AppColors.accent.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.accent : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
          backgroundColor: AppColors.background,
          side: BorderSide(color: isSelected ? AppColors.accent : AppColors.border),
        );
      }).toList(),
    );
  }
}
