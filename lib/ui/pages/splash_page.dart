import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/update_service.dart';
import '../foundations/motion.dart';
import '../foundations/colors.dart';

/// Animated splash that runs an initialization task, then routes to [next].
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    required this.initialize,
    required this.next,
    this.title = 'Dej si pauzu',
    this.onReady,
  });

  final Future<void> Function() initialize;
  final Widget next;
  final String title;
  final void Function(BuildContext context)? onReady;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppConstants.splashMinDuration,
    lowerBound: 0.0,
    upperBound: 1.0,
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.wait(<Future<void>>[
      widget.initialize(),
      Future<void>.delayed(AppConstants.splashMinDuration),
    ]).then((_) async {
      if (!mounted) return;
      
      // Check for updates after splash screen
      await UpdateService().initialize();
      await UpdateService().checkForUpdates(context, forceUpdate: true);
      
      if (!mounted) return;
      
      if (widget.onReady != null) {
        widget.onReady!(context);
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<Widget>(
            transitionDuration: AppMotion.medium,
            reverseTransitionDuration: AppMotion.fast,
            pageBuilder: (_, __, ___) => widget.next,
            transitionsBuilder: (_, Animation<double> a, __, Widget child) {
              final Animation<double> curved = CurvedAnimation(parent: a, curve: AppMotion.emphasized);
              return FadeTransition(opacity: curved, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          final double t = _controller.value;
          final double iconScale = Tween<double>(begin: 0.8, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOutCubic))
              .transform(t);
          final double titleOpacity = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
          ).value;
          final double taglineOpacity = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ).value;

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.white,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Clean icon with subtle scale animation
                  ScaleTransition(
                    scale: AlwaysStoppedAnimation<double>(iconScale),
                    child: Hero(
                      tag: 'app-logo',
                      child: Image.asset(
                        'icon512.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title with fade in
                  Opacity(
                    opacity: titleOpacity,
                    child: Text(
                      widget.title,
                      style: text.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tagline with fade in
                  Opacity(
                    opacity: taglineOpacity,
                    child: Text(
                      'Zastav se. Nadechni. Všechno bude v pořádku.',
                      style: text.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

