import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';

/// Centralized navigation helper
/// Provides type-safe navigation methods
class AppNavigator {
  AppNavigator._();

  /// Navigate to a route
  static void go(BuildContext context, String route) {
    context.go(route);
  }

  /// Push a route
  static Future<T?> push<T>(BuildContext context, String route) {
    return context.push<T>(route);
  }

  /// Pop current route
  static void pop<T>(BuildContext context, [T? result]) {
    context.pop(result);
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return context.canPop();
  }

  // Convenience methods for common routes
  static void toHome(BuildContext context) => go(context, AppRoutes.home);
  static void toPause(BuildContext context) => go(context, AppRoutes.pause);
  static void toMood(BuildContext context) => go(context, AppRoutes.mood);
  static void toTips(BuildContext context) => go(context, AppRoutes.tips);
  static void toPartner(BuildContext context) => go(context, AppRoutes.partner);
  static void toSettings(BuildContext context) => go(context, AppRoutes.settings);
  static void toProfile(BuildContext context) => go(context, AppRoutes.profile);
  static void toStats(BuildContext context) => go(context, AppRoutes.stats);
  static void toList(BuildContext context) => go(context, AppRoutes.list);
}

