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
    return Stack(
      children: <Widget>[
        // Playful soft gradient background, mostly light tones
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFFF7F3FF), // soft lilac
                Color(0xFFFDF6F0), // warm off-white
                Color(0xFFF1FAF0), // soft mint
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
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
        ),
      ],
    );
  }
}

