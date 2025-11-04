import 'package:flutter/animation.dart';

/// Centralized motion system: durations, curves, and defaults for animations.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration veryFast = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 360);
  static const Duration verySlow = Duration(milliseconds: 480);
  static const Duration extremelySlow = Duration(milliseconds: 800);

  // Curves inspired by Material emphasized-easing.
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;
  static const Curve overshoot = Curves.easeOutBack;
}

