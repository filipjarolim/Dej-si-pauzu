import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../foundations/motion.dart';
import '../foundations/colors.dart';

/// Modern "Breathe & Flow" Splash Screen
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

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _breatheController;
  
  // Staggered Animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _breathe;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    
    // Main Entry Animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Slightly longer than minDuration to allow full ease
    );

    // Continuous Breathing Animation for Logo
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _setupAnimations();
    _startInitialization();

    // Hide status bar for immersive feel initially (optional, but looks premium)
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _setupAnimations() {
    // 1. Logo Entry (0.0 - 0.6)
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    // 2. Breathing Overlay (Looping)
    _breathe = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );

    // 3. Title Entry (0.3 - 0.7)
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );

    // 4. Tagline Entry (0.6 - 1.0)
    _taglineFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    
    _mainController.forward();
  }

  void _startInitialization() {
    Future.wait(<Future<void>>[
      widget.initialize(),
      Future<void>.delayed(AppConstants.splashMinDuration),
    ]).then((_) => _onComplete());
  }

  Future<void> _onComplete() async {
    if (!mounted) return;
    
    // Wait for main animation to minimally finish if it was super fast (unlikely given minDuration)
    if (_mainController.status == AnimationStatus.forward) {
      await _mainController.forward(); // Ensure animation completes
    }

    if (!mounted) return;

    if (widget.onReady != null) {
      widget.onReady!(context);
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<Widget>(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => widget.next,
          transitionsBuilder: (_, Animation<double> a, __, Widget child) {
            return FadeTransition(opacity: a, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fallback
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dynamic Background
          const _AnimatedGradientBackground(),
          
          // 2. Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO
                AnimatedBuilder(
                  animation: Listenable.merge([_mainController, _breatheController]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value * _breathe.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: child,
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'app-logo',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/iconexpanded.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // TITLE
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: const Color(0xFF1E1E2E), // Dark aesthetic
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // TAGLINE
                FadeTransition(
                  opacity: _taglineFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      AppConstants.appTagline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6B6B7F), // Subdued label color
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGradientBackground extends StatelessWidget {
  const _AnimatedGradientBackground();

  @override
  Widget build(BuildContext context) {
    // A subtle mesh gradient background
    // For now, using a high-quality static gradient that works well with "Breathe"
    // In future, this could be an AnimatedContainer looping colors.
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAFAFA), // Off-white top
            Color(0xFFF0F2FF), // Very subtle blue tint
            Color(0xFFEBEBFF), // Slightly stronger tint bottom
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}

