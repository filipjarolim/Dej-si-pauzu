import 'package:flutter/material.dart';

/// Signature color palette for Dej si pauzu
class AppColors {
  AppColors._();

  // Primary signature colors
  static const Color yellow = Color(0xFFFFF564); // Bright yellow
  static const Color skyBlue = Color(0xFF9FEAFF); // Light sky blue
  static const Color deepBlue = Color(0xFF3858FB); // Deep blue
  static const Color mintGreen = Color(0xFF8BEF90); // Mint green
  static const Color pink = Color(0xFFFF8CDD); // Pink
  static const Color lightGreen = Color(0xFF88DD7E); // Light green
  static const Color coral = Color(0xFFEF8B8D); // Coral/salmon

  // Color combinations for gradients
  static const List<Color> gradientSunset = <Color>[yellow, pink, coral];
  static const List<Color> gradientOcean = <Color>[skyBlue, deepBlue];
  static const List<Color> gradientNature = <Color>[mintGreen, lightGreen];
  static const List<Color> gradientPlayful = <Color>[pink, yellow, mintGreen];
  static const List<Color> gradientCalm = <Color>[skyBlue, mintGreen];

  // Semantic colors
  static const Color primary = deepBlue;
  static const Color secondary = pink;
  static const Color accent = yellow;
  static const Color success = lightGreen;
  static const Color warning = yellow;
  static const Color error = coral;

  // Neutral colors (for text, backgrounds)
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
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
    surface: AppColors.white,
    onSurface: AppColors.black,
    surfaceVariant: AppColors.gray50,
    onSurfaceVariant: AppColors.gray700,
    background: AppColors.white,
    onBackground: AppColors.black,
    error: AppColors.error,
    onError: AppColors.white,
    outline: AppColors.gray300,
    outlineVariant: AppColors.gray200,
    shadow: AppColors.black,
    scrim: AppColors.black,
    inverseSurface: AppColors.gray900,
    onInverseSurface: AppColors.white,
    inversePrimary: AppColors.skyBlue,
    primaryContainer: AppColors.skyBlue.withOpacity(0.1),
    onPrimaryContainer: AppColors.primary,
    secondaryContainer: AppColors.pink.withOpacity(0.1),
    onSecondaryContainer: AppColors.secondary,
    tertiaryContainer: AppColors.mintGreen.withOpacity(0.1),
    onTertiaryContainer: AppColors.mintGreen,
  );
}

