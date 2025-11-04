import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../foundations/motion.dart';

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
}

