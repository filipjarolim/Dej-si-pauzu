import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

import '../foundations/motion.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.show,
    this.message,
  });

  final bool show;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return IgnorePointer(
      ignoring: !show,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: AppMotion.medium,
        curve: Curves.easeOutCubic,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Enhanced iOS-like blur with better performance
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const SizedBox.expand(),
            ),
            ColoredBox(
              color: AppColors.white.withOpacity(0.85),
            ),
            Center(
              child: RepaintBoundary(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: show ? 1.0 : 0.0),
                  duration: AppMotion.medium,
                  curve: Curves.easeOutCubic,
                  builder: (BuildContext context, double value, Widget? child) {
                    return Transform.scale(
                      scale: 0.85 + (0.15 * value), // Reduced scale range for smoother animation
                      child: Opacity(
                        opacity: value,
                        child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.lg + 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                          border: Border.all(
                            color: AppColors.gray200,
                            width: DesignTokens.borderMedium,
                          ),
                          boxShadow: DesignTokens.shadowLg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                              ),
                            ),
                            if (message != null) ...<Widget>{
                              const SizedBox(height: AppSpacing.md + 2),
                              Text(
                                message!,
                                textAlign: TextAlign.center,
                                style: text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            },
                          ],
                        ),
                      ),
                    ),
                  );
                },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
              if (message != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg + 4),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

