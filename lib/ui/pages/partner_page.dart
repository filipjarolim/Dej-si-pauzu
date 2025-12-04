import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../foundations/motion.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_button.dart';
import '../widgets/frosted_app_bar.dart';

class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});

  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> with TickerProviderStateMixin {
  int? _expandedIndex;
  late AnimationController _stackController;
  final List<AnimationController> _cardControllers = <AnimationController>[];
  
  // Random rotations for each card (slight)
  final List<double> _rotations = <double>[
    -0.05, // Slight left rotation
    0.03,  // Slight right rotation
    -0.02, // Slight left rotation
  ];

  // Only 3 mascot personalities
  final List<Map<String, dynamic>> _personalities = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'wise',
      'name': 'Moudrý',
      'description': 'Trpělivý a moudrý rádce, který ti pomůže najít odpovědi na tvé otázky',
      'image': 'menubarchar.png',
      'color': AppColors.deepBlue,
    },
    <String, dynamic>{
      'id': 'cheerful',
      'name': 'Veselý',
      'description': 'Plný energie a optimismu, vždy připravený tě rozveselit a povzbudit',
      'image': 'menubarchar2.png',
      'color': AppColors.yellow,
    },
    <String, dynamic>{
      'id': 'calm',
      'name': 'Klidný',
      'description': 'Uklidňující přítel, který ti pomůže najít vnitřní mír a rovnováhu',
      'image': 'menubarchar3.png',
      'color': AppColors.mintGreen,
    },
  ];

  @override
  void initState() {
    super.initState();
    _stackController = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
    )..forward();

    // Create animation controller for each card
    for (int i = 0; i < _personalities.length; i++) {
      final AnimationController controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
        reverseDuration: const Duration(milliseconds: 700),
      );
      _cardControllers.add(controller);
      // Stagger initial animations
      Future<void>.delayed(Duration(milliseconds: 150 * i), () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _stackController.dispose();
    for (final AnimationController controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _expandCard(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedIndex == index) {
        // Collapse current card
        _expandedIndex = null;
        _cardControllers[index].reverse();
      } else {
        // Expand new card
        final int? previousIndex = _expandedIndex;
        _expandedIndex = index;
        if (previousIndex != null) {
          _cardControllers[previousIndex].reverse();
        }
        _cardControllers[index].forward();
      }
    });
  }

  void _handleSwipe(int index, DragUpdateDetails details) {
    // Optional: Add visual feedback during swipe
    // Could add slight rotation or translation based on swipe direction
  }

  void _startChat() {
    if (_expandedIndex == null) return;
    HapticFeedback.mediumImpact();
    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Začínáš konverzaci s ${_personalities[_expandedIndex!]['name']}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _personalities[_expandedIndex!]['color'] as Color,
        duration: const Duration(seconds: 2),
      ),
    );
    // Navigate to chat screen with selected personality
    // This will be implemented later
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width - (AppSpacing.lg * 2);

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar(
        title: const Text('AI Parťák'),
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _stackController,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + AppSpacing.xl,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Vyber si svého parťáka',
                      style: text.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Klikni na kartu a objev svého ideálního společníka',
                      style: text.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl + 8),
                // Stacked cards - fixed height container
                SizedBox(
                  height: _expandedIndex != null ? 600 : 500,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: List<Widget>.generate(
                      _personalities.length,
                      (int index) {
                        return _buildStackedCard(
                          index,
                          text,
                          cs,
                          cardWidth,
                          screenSize.width,
                        );
                      },
                    ),
                  ),
                ),
                // Swipe hint
                if (_expandedIndex == null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.swipe_up,
                        size: 16,
                        color: cs.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Swipe nahoru nebo klikni na kartu',
                        style: text.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Collapse hint when expanded
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.swipe_down,
                        size: 14,
                        color: cs.onSurfaceVariant.withOpacity(0.4),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Swipe dolů pro zavření',
                        style: text.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                // Start chat button
                if (_expandedIndex != null) ...[
                  AppButton(
                    label: 'Začít konverzaci s ${_personalities[_expandedIndex!]['name']}',
                    onPressed: _startChat,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStackedCard(
    int index,
    TextTheme text,
    ColorScheme cs,
    double cardWidth,
    double screenWidth,
  ) {
    final Map<String, dynamic> personality = _personalities[index];
    final bool isExpanded = _expandedIndex == index;
    final bool isOtherExpanded = _expandedIndex != null && _expandedIndex != index;
    final AnimationController controller = _cardControllers[index];
    final double rotation = _rotations[index];

    // Stack positioning - higher cards placed lower, showing more height
    // Top card (index 0) shows most, bottom card (index 2) shows least
    final double baseOffset = 60.0; // More visible height
    final double stackOffset = baseOffset * index; // Higher index = lower position
    
    // Animation values - no scale or opacity changes, all cards same size
    final double collapsedHeight = 180.0; // More visible peek height
    final double expandedHeight = 550.0;
    
    // Calculate side offset when other card is expanded - move completely off screen
    final double sideOffset = isOtherExpanded 
        ? (index < _expandedIndex! ? -screenWidth * 1.2 : screenWidth * 1.2)
        : 0.0;

    return AnimatedBuilder(
      animation: Listenable.merge(_cardControllers),
      builder: (BuildContext context, Widget? child) {
        // Get progress from the relevant controller
        double progress = 0.0;
        if (isExpanded) {
          progress = Curves.easeInOutCubicEmphasized.transform(controller.value);
        } else if (isOtherExpanded) {
          progress = Curves.easeInOutCubicEmphasized.transform(_cardControllers[_expandedIndex!].value);
        }
        
        // Smooth animations with emphasized curve
        final double animatedOffset = isExpanded
            ? stackOffset + ((0 - stackOffset) * progress)
            : stackOffset;
        final double animatedHeight = isExpanded
            ? collapsedHeight + ((expandedHeight - collapsedHeight) * progress)
            : collapsedHeight;
        final double animatedRotation = isExpanded
            ? rotation + ((0 - rotation) * progress) // Straighten when expanded
            : rotation;
        final double animatedSideOffset = isOtherExpanded
            ? sideOffset * progress
            : 0.0;

        return Positioned(
          top: animatedOffset,
          left: animatedSideOffset,
          right: -animatedSideOffset,
            child: Transform.rotate(
            angle: animatedRotation,
            child: GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                // Swipe right to expand, swipe left to collapse
                final double velocity = details.velocity.pixelsPerSecond.dx;
                if (velocity > 300 && !isExpanded) {
                  HapticFeedback.mediumImpact();
                  _expandCard(index);
                } else if (velocity < -300 && isExpanded) {
                  HapticFeedback.lightImpact();
                  _expandCard(index); // Collapse
                }
              },
              onVerticalDragEnd: (DragEndDetails details) {
                // Swipe up to expand, swipe down to collapse
                final double velocity = details.velocity.pixelsPerSecond.dy;
                if (velocity < -300 && !isExpanded) {
                  HapticFeedback.mediumImpact();
                  _expandCard(index);
                } else if (velocity > 300 && isExpanded) {
                  HapticFeedback.lightImpact();
                  _expandCard(index); // Collapse
                }
                          },
                          child: Container(
                width: cardWidth,
                height: animatedHeight,
                            decoration: BoxDecoration(
                  color: personality['color'] as Color, // No transparency
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXxl), // More rounded
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (personality['color'] as Color).withOpacity(0.4),
                      blurRadius: isExpanded ? 40 : 20,
                      offset: Offset(0, isExpanded ? 15 : 8),
                      spreadRadius: isExpanded ? 3 : 1,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXxl),
                    onTap: () => _expandCard(index),
                    splashColor: AppColors.white.withOpacity(0.1),
                    highlightColor: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusXxl),
                      child: AnimatedSwitcher(
                        duration: AppMotion.fast,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: isExpanded
                            ? _buildExpandedContent(personality, text, cs, key: ValueKey<int>(index))
                            : _buildPeekContent(personality, text, cs, index, key: ValueKey<int>(index + 100)),
                      ),
                    ),
                  ),
                ),
                                    ),
                                  ),
                                ),
        );
      },
    );
  }

  Widget _buildPeekContent(
    Map<String, dynamic> personality,
    TextTheme text,
    ColorScheme cs,
    int index, {
    required Key key,
  }) {
    final Color cardColor = personality['color'] as Color;

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXxl),
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allow overflow for icon
        children: <Widget>[
          // Card background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXxl),
                            ),
                          ),
                        ),
          // Peek content - name and icon going over border
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Row(
              children: <Widget>[
                    // Mascot image going over border
                    Transform.translate(
                      offset: const Offset(-8, -8), // Go over border
                      child: Image.asset(
                        personality['image'] as String,
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                    ),
                const SizedBox(width: AppSpacing.md),
                // Name
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      personality['name'] as String,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        fontSize: 24,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Arrow indicator
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ],
                    ),
                  ),
                ],
      ),
    );
  }

  Widget _buildExpandedContent(
    Map<String, dynamic> personality,
    TextTheme text,
    ColorScheme cs, {
    required Key key,
  }) {
    final Color cardColor = personality['color'] as Color;

    return Container(
      key: key,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXxl),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
          // Large mascot image
          Image.asset(
            personality['image'] as String,
            width: 140,
            height: 140,
            fit: BoxFit.contain,
          ),
            const SizedBox(height: AppSpacing.lg),
            // Name
            Text(
              personality['name'] as String,
              style: text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.white,
                fontSize: 32,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Description
            Text(
              personality['description'] as String,
              style: text.bodyLarge?.copyWith(
                color: AppColors.white.withOpacity(0.95),
                height: 1.6,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Check indicator
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
