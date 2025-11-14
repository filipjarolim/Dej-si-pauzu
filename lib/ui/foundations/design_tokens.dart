import 'package:flutter/material.dart';
import 'colors.dart';

/// Design tokens for consistent design system
class DesignTokens {
  DesignTokens._();

  // Border radius scale
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;
  static const double radiusXxl = 32;
  static const double radiusRound = 999;

  // Elevation/shadow
  static List<BoxShadow> shadowSm = <BoxShadow>[
    BoxShadow(
      color: AppColors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = <BoxShadow>[
    BoxShadow(
      color: AppColors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg = <BoxShadow>[
    BoxShadow(
      color: AppColors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowXl = <BoxShadow>[
    BoxShadow(
      color: AppColors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 12),
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

/// Gradient presets using signature colors
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientOcean,
  );

  static const LinearGradient secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientSunset,
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientNature,
  );

  static const LinearGradient playful = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientPlayful,
  );

  static const LinearGradient calm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.gradientCalm,
  );

  static LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AppColors.white,
      AppColors.skyBlue.withOpacity(0.05),
      AppColors.mintGreen.withOpacity(0.03),
    ],
  );
}

