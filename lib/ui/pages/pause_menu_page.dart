import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

enum PauseActivityType {
  breathing('Dýchání', 'Dýchací cvičení pro relaxaci', Icons.air_rounded, AppColors.primary),
  meditation('Meditace', 'Vedená meditace a mindfulness', Icons.self_improvement_rounded, AppColors.skyBlue),
  stretching('Protahování', 'Jemné protahovací cviky', Icons.fitness_center_rounded, AppColors.mintGreen);

  const PauseActivityType(this.name, this.description, this.icon, this.color);
  final String name;
  final String description;
  final IconData icon;
  final Color color;
}

class PauseMenuPage extends StatefulWidget {
  const PauseMenuPage({super.key});

  @override
  State<PauseMenuPage> createState() => _PauseMenuPageState();
}

class _PauseMenuPageState extends State<PauseMenuPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle, // Clean background
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: screenSize.height * 0.04), // Reduced top spacing
              // Title section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pauza',
                      style: text.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.gray900,
                        letterSpacing: -2,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Vyber aktivitu pro relaxaci',
                      style: text.titleLarge?.copyWith(
                        color: AppColors.gray500, // Softer gray
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.height * 0.04), // Reduced gap
              // Activity cards - CLEAN & WHITE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: <Widget>[
                    ...PauseActivityType.values.asMap().entries.map((MapEntry<int, PauseActivityType> entry) {
                      final int index = entry.key;
                      final PauseActivityType activity = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < PauseActivityType.values.length - 1 ? AppSpacing.lg : 0,
                        ),
                        child: _ActivityCard(
                          activity: activity,
                          index: index,
                          animationController: _animationController,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _navigateToActivity(context, activity);
                          },
                        ),
                      );
                    }),
                    SizedBox(height: screenSize.height * 0.15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToActivity(BuildContext context, PauseActivityType activity) {
    switch (activity) {
      case PauseActivityType.breathing:
        context.push('${AppRoutes.pause}/breathing');
        break;
      case PauseActivityType.meditation:
        context.push('${AppRoutes.pause}/meditation');
        break;
      case PauseActivityType.stretching:
        context.push('${AppRoutes.pause}/stretching');
        break;
    }
  }
}

class _ActivityCard extends StatefulWidget {
  const _ActivityCard({
    required this.activity,
    required this.index,
    required this.animationController,
    required this.onTap,
  });

  final PauseActivityType activity;
  final int index;
  final AnimationController animationController;
  final VoidCallback onTap;

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _shakeAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: -4.0) // Reduced shake amplitude
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 1.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -4.0, end: 4.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 4.0, end: -2.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -2.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 1.0,
        ),
      ],
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    HapticFeedback.mediumImpact();
    
    // Quick press animation
    await _pressController.forward();
    
    // Small delay then navigate
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      widget.onTap();
    }
    
    // Reset animation
    _pressController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[widget.animationController, _pressController]),
      builder: (BuildContext context, Widget? child) {
        final double offset = (widget.animationController.value * 2 * math.pi) + (widget.index * 0.5);
        final double subtleMove = (math.sin(offset) * 2).abs();
        
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, subtleMove),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                child: Container(
                  padding: const EdgeInsets.all(24), // Approx equivalent to AppSpacing.xl + 4
                  decoration: BoxDecoration(
                    color: Colors.white, // Solid white
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: widget.activity.color.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      // Large icon container
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.activity.color.withOpacity(0.1),
                        ),
                        child: Icon(
                          widget.activity.icon,
                          color: widget.activity.color,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.activity.name,
                              style: text.headlineSmall?.copyWith( // Slightly smaller than Display
                                fontWeight: FontWeight.w900,
                                color: AppColors.gray900,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.activity.description,
                              style: text.bodyMedium?.copyWith(
                                color: AppColors.gray500,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow indicator
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.gray300,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
