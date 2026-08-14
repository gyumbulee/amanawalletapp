import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Standard centered spinner for full-screen or full-section loading states.
class AppSpinner extends StatelessWidget {
  const AppSpinner({super.key, this.size = 28, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color ?? AppColors.accent,
        ),
      ),
    );
  }
}
