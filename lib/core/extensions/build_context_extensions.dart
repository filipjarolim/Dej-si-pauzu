import 'package:flutter/material.dart';
import '../navigation/app_navigator.dart';
import '../constants/app_routes.dart';
import '../../ui/foundations/colors.dart';
import '../../ui/foundations/design_tokens.dart';

/// Extension methods for BuildContext
extension BuildContextExtensions on BuildContext {
  /// Get theme colors
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get media query
  MediaQueryData get media => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => media.size;

  /// Check if screen is small
  bool get isSmallScreen => screenSize.width < 600;

  /// Check if screen is large
  bool get isLargeScreen => screenSize.width >= 600;

  /// Show snackbar with consistent styling
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show loading dialog
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CircularProgressIndicator(),
                if (message != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }

  // Navigation shortcuts
  void navigateTo(String route) => AppNavigator.go(this, route);
  void navigateToHome() => AppNavigator.toHome(this);
  void navigateToPause() => AppNavigator.toPause(this);
  void navigateToMood() => AppNavigator.toMood(this);
  void navigateToTips() => AppNavigator.toTips(this);
  void navigateToPartner() => AppNavigator.toPartner(this);
  void navigateToSettings() => AppNavigator.toSettings(this);
  void navigateToProfile() => AppNavigator.toProfile(this);
}

