import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';

/// Shimmering placeholder block — use while wallet balance, transaction
/// lists, etc. are loading, instead of a bare spinner, for a more polished
/// fintech feel.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius,
  });

  final double height;
  final double width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkBorder : AppColors.border,
      highlightColor: isDark ? AppColors.darkSurface : AppColors.surface,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppRadii.inputRadius,
        ),
      ),
    );
  }
}

/// Pre-built skeleton for a transaction-list row.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SkeletonLoader(height: 40, width: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(height: 14, width: 140),
                SizedBox(height: 6),
                SkeletonLoader(height: 12, width: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
