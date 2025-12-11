import 'package:flutter/material.dart';
import 'colors.dart';

/// Design tokens for consistent design system
class DesignTokens {
  DesignTokens._();

  // Border radius scale
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24; // Increased for friendlier look
  static const double radiusXl = 32;
  static const double radiusXxl = 40;
  static const double radiusRound = 999;

  // Elevation/shadow - Softened, colored shadows ("Glows")
  static List<BoxShadow> shadowSm = <BoxShadow>[
    BoxShadow(
      color: AppColors.deepBlue.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = <BoxShadow>[
    BoxShadow(
      color: AppColors.deepBlue.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> shadowLg = <BoxShadow>[
    BoxShadow(
      color: AppColors.deepBlue.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
  
  // Special "Floaty" shadow for key elements
  static List<BoxShadow> shadowFloat = <BoxShadow>[
    BoxShadow(
      color: AppColors.deepBlue.withValues(alpha: 0.15),
      blurRadius: 30,
      offset: const Offset(0, 10),
      spreadRadius: -5,
    ),
  ];

  // Border widths
  static const double borderThin = 1;
  static const double borderMedium = 1.5;
  static const double borderThick = 2;
  static const double borderXthick = 3;

  // Opacity levels
  static const double opacitySubtle = 0.06;
  static const double opacityLight = 0.12;
  static const double opacityMedium = 0.20;
  static const double opacityStrong = 0.40;
  static const double opacityHeavy = 0.60;

  // Icon sizes
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
  static const double iconXxl = 64;

  // Container sizes
  static const double containerXs = 32;
  static const double containerSm = 40;
  static const double containerMd = 48;
  static const double containerLg = 56;
  static const double containerXl = 64;
  static const double containerXxl = 80;
}
