import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/data_plan_category_info.dart';

/// Tappable chips like "Gifting (42)", "SME (9)" — lets the user narrow
/// a network's plan list down before browsing instead of scrolling
/// everything at once.
class DataCategoryChips extends StatelessWidget {
  const DataCategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<DataPlanCategoryInfo> categories;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.key == selected;

          return ChoiceChip(
            label: Text('${category.label} (${category.planCount})'),
            selected: isSelected,
            onSelected: (_) => onSelected(category.key),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            selectedColor: AppColors.accent,
            backgroundColor: AppColors.surface,
            side: BorderSide(color: isSelected ? AppColors.accent : AppColors.border),
          );
        },
      ),
    );
  }
}
