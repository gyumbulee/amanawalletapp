import 'package:flutter/material.dart';

/// Breakpoints used across the app to decide mobile vs. web/tablet layout.
class AppBreakpoints {
  AppBreakpoints._();
  static const double tablet = 700;
  static const double desktop = 1100;
}

/// Wraps content so it doesn't just stretch full-width in a browser window.
/// On screens wider than [AppBreakpoints.tablet], content is centered and
/// capped at [maxContentWidth]; on narrower (mobile) screens it fills the
/// available width as normal.
///
/// Use this at the top of every feature screen's body instead of returning
/// raw mobile-first layouts, so Web gets a sane reading width for free.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.maxContentWidth = 480,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final double maxContentWidth;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(padding: padding, child: body),
          ),
        ),
      ),
    );
  }
}
