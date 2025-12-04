import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../foundations/motion.dart';
import '../../core/constants/app_routes.dart';

/// Shared transitions builders for route pages.
class AppTransitions {
  AppTransitions._();

  static CustomTransitionPage<T> sharedAxisHorizontal<T>({
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      transitionDuration: AppMotion.medium,
      reverseTransitionDuration: AppMotion.fast,
      child: child,
      transitionsBuilder: (
        BuildContext _,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        return SharedAxisTransition(
          animation: CurvedAnimation(parent: animation, curve: AppMotion.emphasized),
          secondaryAnimation: secondary,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<T> fadeThrough<T>({
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      transitionDuration: AppMotion.medium,
      reverseTransitionDuration: AppMotion.fast,
      child: child,
      transitionsBuilder: (
        BuildContext _,
        Animation<double> animation,
        Animation<double> secondary,
        Widget child,
      ) {
        return FadeThroughTransition(
          animation: CurvedAnimation(parent: animation, curve: AppMotion.emphasized),
          secondaryAnimation: secondary,
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<T> fadeScale<T>({
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      transitionDuration: AppMotion.medium,
      reverseTransitionDuration: AppMotion.fast,
      child: child,
      transitionsBuilder: (
        BuildContext _,
        Animation<double> animation,
        Animation<double> __,
        Widget child,
      ) {
        return FadeScaleTransition(
          animation: CurvedAnimation(parent: animation, curve: AppMotion.emphasized),
          child: child,
        );
      },
    );
  }

  /// Slide transition for bottom navigation tabs
  /// Push-style transition: old page slides out while new page slides in
  /// Uses SharedAxisTransition for proper push effect
  static Page<T> tabSlide<T>({
    required Widget child,
    required String routePath,
  }) {

    return CustomTransitionPage<T>(
      key: ValueKey<String>(routePath), // Important: unique key for each route
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      child: child,
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        // SharedAxisTransition handles both pages sliding horizontally
        // It automatically slides the old page out while the new one slides in
        return SharedAxisTransition(
          animation: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    );
  }

  /// Check if route is a bottom nav tab route
  static bool _isTabRoute(String path) {
    return path == AppRoutes.home ||
        path == AppRoutes.pause ||
        path == AppRoutes.mood ||
        path == AppRoutes.tips ||
        path == AppRoutes.partner;
  }
}

