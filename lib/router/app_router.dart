import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../ui/navigation/transitions.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/splash_page.dart';
import '../ui/pages/list_page.dart';
import '../ui/pages/database_page.dart';
import '../ui/pages/auth_page.dart';
import '../ui/pages/pause_page.dart';
import '../ui/pages/mood_page.dart';
import '../ui/pages/tips_page.dart';
import '../ui/pages/partner_page.dart';
import '../ui/pages/settings_page.dart';
import '../ui/pages/profile_page.dart';
import '../ui/pages/stats_page.dart';
import '../ui/widgets/app_bottom_nav.dart';
import '../ui/widgets/app_back_button_handler.dart';
import '../ui/foundations/design_tokens.dart';
import '../ui/foundations/colors.dart';

/// Helper to wrap route pages with back button handler
Widget _wrapWithBackButtonHandler(Widget child, {bool showConfirmation = false}) {
  return AppBackButtonHandler(
    showConfirmationOnExit: showConfirmation,
    child: child,
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (BuildContext context, GoRouterState state) {
    // Handle deep links from Android shortcuts
    final Uri? uri = state.uri;
    if (uri != null && uri.scheme == 'dejsipauzu') {
      final String path = uri.path;
      if (path == '/pause') {
        return AppRoutes.pause;
      } else if (path == '/stats') {
        return AppRoutes.stats;
      }
    }
    return null; // No redirect needed
  },
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeThrough(
          child: SplashPage(
            initialize: () async {
              // Put real startup work here: hydrate state, warm caches, etc.
            },
            onReady: (BuildContext ctx) => ctx.go(AppRoutes.home),
            next: const SizedBox.shrink(),
          ),
        );
      },
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget navigator) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {
            if (didPop) return;
            
            // Check if we can pop (if not, we're on a main tab page)
            if (!context.canPop()) {
              // Show confirmation dialog before exiting
              final bool? shouldExit = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                  ),
                  title: const Text('Opustit aplikaci?'),
                  content: const Text('Opravdu chceš aplikaci opustit?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: const Text('Zrušit'),
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Opustit'),
                    ),
                  ],
                ),
              );
              
              if (shouldExit == true && context.mounted) {
                // Exit the app
                SystemNavigator.pop();
              }
            } else {
              // Normal pop navigation
              context.pop();
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: navigator,
            bottomNavigationBar: const AppBottomNav(),
          ),
        );
      },
      routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (BuildContext context, GoRouterState state) {
            return AppTransitions.tabSlide(
              routePath: state.uri.path,
          child: const HomePage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.pause,
      pageBuilder: (BuildContext context, GoRouterState state) {
            return AppTransitions.tabSlide(
              routePath: state.uri.path,
              child: const PausePage(),
            );
      },
    ),
    GoRoute(
      path: AppRoutes.mood,
      pageBuilder: (BuildContext context, GoRouterState state) {
            return AppTransitions.tabSlide(
              routePath: state.uri.path,
              child: const MoodPage(),
            );
      },
    ),
    GoRoute(
      path: AppRoutes.tips,
      pageBuilder: (BuildContext context, GoRouterState state) {
            return AppTransitions.tabSlide(
              routePath: state.uri.path,
              child: const TipsPage(),
            );
      },
    ),
    GoRoute(
      path: AppRoutes.partner,
      pageBuilder: (BuildContext context, GoRouterState state) {
            return AppTransitions.tabSlide(
              routePath: state.uri.path,
              child: const PartnerPage(),
            );
      },
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.list,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.sharedAxisHorizontal(
          child: _wrapWithBackButtonHandler(
            const ListPage(),
            showConfirmation: false,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.database,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: _wrapWithBackButtonHandler(
            const DatabasePage(),
            showConfirmation: false,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.auth,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: _wrapWithBackButtonHandler(
            const AuthPage(),
            showConfirmation: false,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: _wrapWithBackButtonHandler(
            const SettingsPage(),
            showConfirmation: false,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: _wrapWithBackButtonHandler(
            const ProfilePage(),
            showConfirmation: false,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.stats,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: _wrapWithBackButtonHandler(
            const StatsPage(),
            showConfirmation: false,
          ),
        );
      },
    ),
  ],
);

