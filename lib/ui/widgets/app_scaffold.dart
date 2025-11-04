import 'package:flutter/material.dart';

import '../foundations/spacing.dart';

/// A thin wrapper around Scaffold that standardizes safe areas and padding.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomBar,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomBar;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: padding,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: body,
          ),
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

