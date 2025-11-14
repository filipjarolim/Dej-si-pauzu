import 'package:flutter/animation.dart';

/// Centralized motion system: durations, curves, and defaults for animations.
/// Optimized for 60fps performance with efficient curves.
class AppMotion {
  AppMotion._();

  // Durations - optimized for smooth 60fps
  static const Duration veryFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 500);
  static const Duration extremelySlow = Duration(milliseconds: 700);

  // Curves optimized for performance - using built-in curves for GPU acceleration
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve overshoot = Curves.easeOutCubic; // Changed from easeOutBack for better performance
  static const Curve smooth = Curves.easeOutCubic; // For smooth transitions
}

