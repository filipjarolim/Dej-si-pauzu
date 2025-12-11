import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../foundations/colors.dart';

/// A thin wrapper around Scaffold that standardizes safe areas and padding.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomBar,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomBar;
  final EdgeInsets padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.white,
      appBar: appBar,
      body: Container(
        color: backgroundColor ?? AppColors.white,
        child: SafeArea(
          child: Padding(
            padding: padding,
            child: RepaintBoundary(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.015),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: body,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

