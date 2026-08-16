import 'package:flutter/material.dart';
import '../../../../constants/cable_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radii.dart';

/// Same visual pattern as NetworkSelector — brand-colored tappable cards —
/// just with 3 providers instead of 4.
class CableProviderSelector extends StatelessWidget {
  const CableProviderSelector({super.key, required this.selected, required this.onSelected});

  final CableProvider? selected;
  final ValueChanged<CableProvider> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CableProvider.values.map((provider) {
        final isSelected = selected == provider;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: provider == CableProvider.values.last ? 0 : 10),
            child: InkWell(
              onTap: () => onSelected(provider),
              borderRadius: AppRadii.cardRadius,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: provider.brandColor,
                  borderRadius: AppRadii.cardRadius,
                  border: isSelected
                      ? Border.all(color: AppColors.accent, width: 2.5)
                      : Border.all(color: Colors.transparent, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    provider.label,
                    style: TextStyle(
                      color: provider.onBrandColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
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
