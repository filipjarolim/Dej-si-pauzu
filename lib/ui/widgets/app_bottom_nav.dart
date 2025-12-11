import 'dart:ui' show ImageFilter;
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

class _AppBottomNavState extends State<AppBottomNav> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _expandController;
  late AnimationController _fadeController; // For smooth navbar fade out on AI Chat tab
  int _previousIndex = -1;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _expandController = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: AppMotion.medium,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _expandController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
    HapticFeedback.selectionClick();
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
    
    // Standard height for all tabs
    const double navbarHeight = 96.0;
    final bool isAIChatTab = selected == 2;
    
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
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: 32,
            right: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                ? 0 
                : 0, 
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: navbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Normalized padding
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.90), // Slightly more opaque
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: DesignTokens.shadowMd, // Always shadow
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: NavigationBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    height: navbarHeight,
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    selectedIndex: selected,
                    indicatorColor: AppColors.primary.withOpacity(0.1),
                    animationDuration: const Duration(milliseconds: 400),
                    onDestinationSelected: (int idx) {
                      HapticFeedback.selectionClick();
                      _handleTabChange(idx, selected);
                      context.go(_locationForIndex(idx));
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
                      _AnimatedNavDestination(
                        icon: Icons.chat_bubble_outline,
                        selectedIcon: Icons.chat_bubble,
                        label: 'Parťák',
                        isSelected: selected == 2,
                        animation: _animationController,
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
    
    // Determine colors
    final Color normalColor = AppColors.gray500;
    final Color selectedColor = AppColors.primary;
    
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
              color: isSelected ? selectedColor : normalColor,
            ),
          ),
          selectedIcon: Transform.scale(
            scale: scale,
            child: Icon(
              selectedIcon,
              size: 26,
              color: selectedColor,
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

class _ExpandedIconButton extends StatelessWidget {
  const _ExpandedIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
