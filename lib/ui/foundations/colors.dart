import 'package:flutter/material.dart';

/// Signature color palette for Dej si pauzu
/// Refreshed for a more vibrant, modern, and less "corny" look.
class AppColors {
  AppColors._();

  // Primary signature colors - More vibrant and solid
  static const Color yellow = Color(0xFFFFD600); // Vivid Yellow
  static const Color skyBlue = Color(0xFF40C4FF); // Electric Sky Blue
  static const Color deepBlue = Color(0xFF2962FF); // Electric Blue
  static const Color mintGreen = Color(0xFF00E676); // Vivid Mint
  static const Color pink = Color(0xFFFF4081); // Vivid Pink
  static const Color lightGreen = Color(0xFF69F0AE); // Accent Green
  static const Color coral = Color(0xFFFF5252); // Vivid Coral
  static const Color violet = Color(0xFF7C4DFF); // Deep Violet
  
  // New "Surface" colors for subtle depth without heavy shadows
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8F9FA); // Very light gray-blue
  static const Color surfaceHilight = Color(0xFFF0F4FF); // Very light blue tint

  // Semantic colors - Mapped to the vibrant palette
  static const Color primary = deepBlue;
  static const Color secondary = pink;
  static const Color accent = yellow;
  static const Color success = mintGreen;
  static const Color warning = yellow;
  static const Color error = coral;

  // Neutral colors (for text, backgrounds) - slightly cooler grays
  static const Color black = Color(0xFF1A1A1A); // Softened black
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Deprecated gradients - kept for compatibility but should be avoided
  static const List<Color> gradientSunset = <Color>[yellow, pink];
  static const List<Color> gradientOcean = <Color>[skyBlue, deepBlue];
}

/// Extended color scheme with signature colors
class AppColorScheme {
  AppColorScheme._();

  static ColorScheme light = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    tertiary: AppColors.mintGreen,
    onTertiary: AppColors.black,
    surface: AppColors.surfaceWhite,
    onSurface: AppColors.black,
    surfaceContainerHighest: AppColors.surfaceSubtle, 
    onSurfaceVariant: AppColors.gray600,
    outline: AppColors.gray200,
    outlineVariant: AppColors.gray100,
    error: AppColors.error,
    onError: AppColors.white,
    // Modern "Tinted" containers
    primaryContainer: AppColors.deepBlue.withValues(alpha: 0.08),
    onPrimaryContainer: AppColors.deepBlue,
    secondaryContainer: AppColors.pink.withValues(alpha: 0.08),
    onSecondaryContainer: AppColors.pink,
    tertiaryContainer: AppColors.mintGreen.withValues(alpha: 0.15),
    onTertiaryContainer: AppColors.gray900,
  );
}
