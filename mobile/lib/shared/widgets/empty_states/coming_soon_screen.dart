import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../responsive_scaffold.dart';

/// Temporary placeholder for feature screens not yet built, so the router
/// has somewhere valid to land during scaffolding. Delete usages of this
/// as each feature's presentation layer is implemented.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.featureName});

  final String featureName;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: AppBar(title: Text(featureName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('$featureName — coming soon', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
