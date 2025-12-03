import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

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
    if (location.startsWith(AppRoutes.mood)) return 2;
    if (location.startsWith(AppRoutes.tips)) return 3;
    if (location.startsWith(AppRoutes.partner)) return 4;
    return 0; // default to home
  }

  String _locationForIndex(int index) {
    switch (index) {
      case 1:
        return AppRoutes.pause;
      case 2:
        return AppRoutes.mood;
      case 3:
        return AppRoutes.tips;
      case 4:
        return AppRoutes.partner;
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
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: DesignTokens.shadowMd,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.gray200,
                width: DesignTokens.borderThin,
              ),
            ),
          ),
          child: NavigationBar(
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            height: 76,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: selected,
            indicatorColor: AppColors.primary.withOpacity(0.1),
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
              _AnimatedNavDestination(
                icon: Icons.self_improvement_outlined,
                selectedIcon: Icons.self_improvement,
                label: 'Pauza',
                isSelected: selected == 1,
                animation: _animationController,
              ),
              _AnimatedNavDestination(
                icon: Icons.mood_outlined,
                selectedIcon: Icons.mood,
                label: 'Nálada',
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
                icon: Icons.chat_bubble_outline,
                selectedIcon: Icons.chat_bubble,
                label: 'Parťák',
                isSelected: selected == 4,
                animation: _animationController,
              ),
            ],
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
