import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class PausePage extends StatefulWidget {
  const PausePage({super.key});

  @override
  State<PausePage> createState() => _PausePageState();
}

class _PausePageState extends State<PausePage> with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: AppBar(title: const Text('Pauza')),
      bottomBar: const AppBottomNav(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Hero illustration with optimized animation
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _breathController,
                builder: (BuildContext context, Widget? child) {
                  // Smoother breathing animation with eased curve
                  final double t = Curves.easeInOut.transform(_breathController.value);
                  final double scale = 1.0 + (t * 0.04); // Reduced scale for smoother animation
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 200,
                      height: 200,
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.primary.withOpacity(0.12),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.self_improvement,
                        size: 100,
                        color: cs.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Zastav se a nadechni',
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md + 4),
                  Text(
                    'Krátká pauza ti může ulevit od stresu. Najdi si klidné místo a věnuj chvíli jen sobě.',
                    style: text.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl + 8),
                  AppButton(
                    label: 'Začít pauzu',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // Start pause session functionality will be implemented
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
