import 'package:flutter/material.dart';
import '../../../../constants/education_exam_type.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radii.dart';

/// Same visual pattern as NetworkSelector/CableProviderSelector — a
/// tappable grid, 4 exam boards, no brand colors here since these aren't
/// consumer brands with a fixed identity the way telecoms/cable are.
class ExamTypeSelector extends StatelessWidget {
  const ExamTypeSelector({super.key, required this.selected, required this.onSelected});

  final EducationExamType? selected;
  final ValueChanged<EducationExamType> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: EducationExamType.values.map((examType) {
        final isSelected = selected == examType;
        return InkWell(
          onTap: () => onSelected(examType),
          borderRadius: AppRadii.cardRadius,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.primary,
              borderRadius: AppRadii.cardRadius,
              border: isSelected ? Border.all(color: AppColors.accent, width: 2.5) : null,
            ),
            child: Center(
              child: Text(
                examType.label,
                style: TextStyle(
                  color: isSelected ? AppColors.accent : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
