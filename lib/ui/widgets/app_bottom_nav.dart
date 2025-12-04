import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_routes.dart';
import '../foundations/motion.dart';
import '../foundations/colors.dart';
import '../foundations/design_tokens.dart';

class AppBottomNav extends StatefulWidget {
  const AppBottomNav({super.key});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _previousIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _indexForLocation(String location) {
    if (location.startsWith(AppRoutes.pause)) return 1;
    if (location.startsWith(AppRoutes.partner)) return 2; // AI Chat in middle
    if (location.startsWith(AppRoutes.tips)) return 3;
    if (location.startsWith(AppRoutes.mood)) return 4;
    return 0; // default to home
  }

  String _locationForIndex(int index) {
    switch (index) {
      case 1:
        return AppRoutes.pause;
      case 2:
        return AppRoutes.partner; // AI Chat in middle
      case 3:
        return AppRoutes.tips;
      case 4:
        return AppRoutes.mood;
      case 0:
      default:
        return AppRoutes.home;
    }
  }

  void _handleTabChange(int newIndex, int currentIndex) {
    if (newIndex != currentIndex) {
      _animationController.forward(from: 0.0).then((_) {
        if (mounted) {
          _animationController.reverse();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final int selected = _indexForLocation(location);
    final ColorScheme cs = Theme.of(context).colorScheme;

    // Trigger animation when selection changes
    if (selected != _previousIndex && _previousIndex != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleTabChange(selected, _previousIndex);
          _previousIndex = selected;
        }
      });
    } else if (_previousIndex == -1) {
      _previousIndex = selected;
    }

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
        decoration: BoxDecoration(
              color: AppColors.gray50,
          boxShadow: DesignTokens.shadowMd,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DesignTokens.radiusXl),
                topRight: Radius.circular(DesignTokens.radiusXl),
              ),
            ),
            child: SafeArea(
              top: false,
        child: Container(
          decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(DesignTokens.radiusXl),
                    topRight: Radius.circular(DesignTokens.radiusXl),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    navigationBarTheme: NavigationBarThemeData(
                      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            // Bigger text for pause tab (index 1)
                            final double fontSize = selected == 1 ? 16 : 12;
                            final Color textColor = selected == 1 
                                ? const Color(0xFFFFB800) // Yellow color
                                : AppColors.primary;
                            return GoogleFonts.quicksand(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            );
                          }
                          return GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray600,
                          );
                        },
                      ),
                      iconTheme: MaterialStateProperty.resolveWith<IconThemeData?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            final Color iconColor = selected == 1 
                                ? const Color(0xFFFFB800) // Yellow color
                                : AppColors.primary;
                            return IconThemeData(color: iconColor);
                          }
                          return IconThemeData(color: AppColors.gray600);
                        },
              ),
            ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(DesignTokens.radiusXl),
                      topRight: Radius.circular(DesignTokens.radiusXl),
          ),
          child: NavigationBar(
                      backgroundColor: AppColors.gray50,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            height: 76,
                      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            selectedIndex: selected,
                      indicatorColor: selected == 2 
                          ? Colors.transparent 
                          : (selected == 1 
                              ? const Color(0xFFFFB800).withOpacity(0.15) // Yellow
                              : AppColors.primary.withOpacity(0.1)),
                      animationDuration: const Duration(milliseconds: 400), // Match page transition duration
            onDestinationSelected: (int idx) {
              HapticFeedback.selectionClick();
              _handleTabChange(idx, selected);
              _previousIndex = selected;
              final String target = _locationForIndex(idx);
              if (target == location) {
                final ScrollController? c = PrimaryScrollController.maybeOf(context);
                c?.animateTo(
                  0,
                  duration: AppMotion.medium,
                  curve: Curves.easeOutCubic,
                );
                return;
              }
                        // Use go() - the PageView in _TabShell will handle the animation
              context.go(target);
            },
            destinations: <Widget>[
              _AnimatedNavDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Domů',
                isSelected: selected == 0,
                animation: _animationController,
              ),
                        _PauseNavDestination(
                icon: Icons.self_improvement_outlined,
                selectedIcon: Icons.self_improvement,
                label: 'Pauza',
                isSelected: selected == 1,
                animation: _animationController,
              ),
                        // Special AI Chat tab with image - placeholder, actual image rendered above
                        _AIChatNavDestination(
                isSelected: selected == 2,
                animation: _animationController,
                          showImage: false, // Don't show image here, it's rendered above
              ),
              _AnimatedNavDestination(
                icon: Icons.tips_and_updates_outlined,
                selectedIcon: Icons.tips_and_updates,
                label: 'Tipy',
                isSelected: selected == 3,
                animation: _animationController,
              ),
              _AnimatedNavDestination(
                          icon: Icons.mood_outlined,
                          selectedIcon: Icons.mood,
                          label: 'Nálada',
                isSelected: selected == 4,
                animation: _animationController,
              ),
            ],
          ),
        ),
                ),
              ),
            ),
          ),
          // Overlay AI Chat image that can overflow navbar bounds
          Positioned(
            bottom: 18, // Position higher to allow overflow above navbar (76/2 - 20 for overflow space)
            left: MediaQuery.of(context).size.width / 2 - 49.5, // Center horizontally, offset by half image width (99/2)
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _handleTabChange(2, selected);
                _previousIndex = selected;
                final String target = _locationForIndex(2);
                if (target == location) {
                  final ScrollController? c = PrimaryScrollController.maybeOf(context);
                  c?.animateTo(
                    0,
                    duration: AppMotion.medium,
                    curve: Curves.easeOutCubic,
                  );
                  return;
                }
                context.go(target);
              },
              child: Opacity(
                opacity: selected == 2 ? 1.0 : 0.6,
                child: _AIChatImageOverlay(
                  isSelected: selected == 2,
                  animation: _animationController,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNavDestination extends StatelessWidget {
  const _AnimatedNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.animation,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        // Smooth scale animation when selected - subtle bounce effect
        final double scale = isSelected 
            ? 1.0 + (animation.value * 0.1) 
            : 1.0;
        
        return NavigationDestination(
          icon: Transform.scale(
            scale: isSelected ? scale : 1.0,
            child: Icon(
              icon,
              size: DesignTokens.iconMd,
              color: isSelected 
                  ? AppColors.primary 
                  : AppColors.gray500,
            ),
          ),
          selectedIcon: Transform.scale(
            scale: scale,
            child: Icon(
              selectedIcon,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          label: label,
        );
      },
    );
  }
}

class _AIChatNavDestination extends StatelessWidget {
  const _AIChatNavDestination({
    required this.isSelected,
    required this.animation,
    this.showImage = true,
  });

  final bool isSelected;
  final Animation<double> animation;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    if (!showImage) {
      // Return empty destination when image is shown as overlay
      return NavigationDestination(
        icon: const SizedBox(width: 24, height: 24),
        selectedIcon: const SizedBox(width: 24, height: 24),
        label: '',
      );
    }
    
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double scale = isSelected 
            ? 1.0 + (animation.value * 0.1) 
            : 1.0;
        
        return NavigationDestination(
          icon: Opacity(
            opacity: isSelected ? 1.0 : 0.6,
            child: Transform.scale(
              scale: isSelected ? scale : 1.0,
              child: SizedBox(
                width: 92, // 80 * 1.15
                height: 92, // 80 * 1.15
                child: Image.asset(
                  'menubarchar.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          selectedIcon: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 99, // 86 * 1.15
              height: 99, // 86 * 1.15
              child: Image.asset(
                'menubarchar.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          label: '', // Empty label - image takes full space
        );
      },
    );
  }
}

class _AIChatImageOverlay extends StatelessWidget {
  const _AIChatImageOverlay({
    required this.isSelected,
    required this.animation,
  });

  final bool isSelected;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double scale = isSelected 
            ? 1.0 + (animation.value * 0.1) 
            : 1.0;
        
        return Transform.scale(
          scale: scale,
          child: Image.asset(
            'menubarchar.png',
            width: 99, // 86 * 1.15
            height: 99, // 86 * 1.15
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}

class _PauseNavDestination extends StatelessWidget {
  const _PauseNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.animation,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double scale = isSelected 
            ? 1.0 + (animation.value * 0.1) 
            : 1.0;
        
        return NavigationDestination(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: isSelected
                ? Image.asset(
                    'charmeditating.png',
                    key: const ValueKey<String>('pause-image'),
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    icon,
                    key: const ValueKey<String>('pause-icon'),
                    size: DesignTokens.iconMd,
                    color: AppColors.gray500,
                  ),
          ),
          selectedIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: Transform.scale(
              scale: scale,
              child: Image.asset(
                'charmeditating.png',
                key: const ValueKey<String>('pause-image-selected'),
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
          ),
          label: label,
          tooltip: label,
        );
      },
    );
  }
}
