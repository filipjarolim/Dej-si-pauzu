import 'package:flutter/material.dart';

import '../foundations/motion.dart';
import '../widgets/shimmer.dart';

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
  static const Duration _minDisplay = Duration(milliseconds: 2000);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _minDisplay,
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.wait(<Future<void>>[
      widget.initialize(),
      Future<void>.delayed(_minDisplay),
    ]).then((_) {
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
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          final double t = Curves.easeInOut.transform(_controller.value);
          final double bgShift = (t - 0.5) * 0.12; // subtle pan
          final double glowT = Curves.easeInOutCubic.transform(t);
          final double iconScale = TweenSequence<double>(<TweenSequenceItem<double>>[
            TweenSequenceItem<double>(tween: Tween<double>(begin: 0.9, end: 1.06).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 55),
            TweenSequenceItem<double>(tween: Tween<double>(begin: 1.06, end: 1.0).chain(CurveTween(curve: AppMotion.overshoot)), weight: 45),
          ]).transform(t);
          final double titleOpacity = CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
          ).value;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + bgShift, -0.6),
                end: Alignment(1.0 + bgShift, 0.8),
                colors: <Color>[
                  cs.primaryContainer.withOpacity(0.65),
                  cs.surface,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Soft radial glow pulse
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withOpacity(0.06 + 0.06 * glowT),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: cs.primary.withOpacity(0.20 * glowT),
                              blurRadius: 48 + 32 * glowT,
                              spreadRadius: 6 + 6 * glowT,
                            ),
                          ],
                        ),
                      ),
                      ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(iconScale),
                        child: Hero(
                          tag: 'app-logo',
                          child: Icon(Icons.self_improvement, size: 72, color: cs.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: titleOpacity,
                    child: Transform.translate(
                      offset: Offset(0, (1.0 - t) * 8),
                      child: Shimmer(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
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

