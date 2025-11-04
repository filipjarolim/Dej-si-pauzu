import 'package:flutter/material.dart';

import '../foundations/motion.dart';
import '../foundations/spacing.dart';
import 'dart:ui' show ImageFilter;

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
    return IgnorePointer(
      ignoring: !show,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: AppMotion.fast,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Subtle iOS-like blur under the dim layer.
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const SizedBox.expand(),
            ),
            ColoredBox(
              color: Colors.black.withOpacity(0.25),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 3),
                    ),
                    if (message != null) ...<Widget>{
                      const SizedBox(height: AppSpacing.md),
                      Text(message!, textAlign: TextAlign.center),
                    },
                  ],
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator.adaptive(strokeWidth: 4),
              ),
              if (message != null) ...<Widget>{
                const SizedBox(height: AppSpacing.lg),
                Text(message!, textAlign: TextAlign.center),
              },
            ],
          ),
        ),
      ),
    );
  }
}

