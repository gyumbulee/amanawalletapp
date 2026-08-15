import 'package:flutter/material.dart';
import '../../../constants/network_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';

/// Network selection grid — shared by Airtime and Data. Shows all four
/// Nigerian networks as tappable brand-colored cards.
class NetworkSelector extends StatelessWidget {
  const NetworkSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NetworkProvider? selected;
  final ValueChanged<NetworkProvider> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: NetworkProvider.values.map((network) {
        final isSelected = selected == network;
        return InkWell(
          onTap: () => onSelected(network),
          borderRadius: AppRadii.cardRadius,
          child: Container(
            decoration: BoxDecoration(
              color: network.brandColor,
              borderRadius: AppRadii.cardRadius,
              border: isSelected
                  ? Border.all(color: AppColors.accent, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
            ),
            child: Center(
              child: Text(
                network.label,
                style: TextStyle(
                  color: network.onBrandColor,
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
