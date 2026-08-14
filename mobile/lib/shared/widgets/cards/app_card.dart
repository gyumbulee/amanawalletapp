import 'package:flutter/material.dart';
import '../../../theme/app_radii.dart';

/// Base elevated card used throughout the app — soft shadow, 16px radius,
/// white surface. Wraps [Card] so screens don't repeat shape/elevation.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: margin ?? EdgeInsets.zero,
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    return InkWell(
      borderRadius: AppRadii.cardRadius,
      onTap: onTap,
      child: card,
    );
  }
}
