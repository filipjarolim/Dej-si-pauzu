import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../ui/navigation/transitions.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/splash_page.dart';
import '../ui/pages/pause_menu_page.dart';
import '../ui/pages/breathing_page.dart';
import '../ui/pages/meditation_page.dart';
import '../ui/pages/stretching_page.dart';
import '../ui/pages/mood_page.dart';
import '../ui/pages/tips_page.dart';
import '../ui/pages/partner_page.dart';
import '../ui/pages/database_page.dart';
import '../ui/pages/profile_page.dart';
import '../ui/widgets/app_bottom_nav.dart';
import '../ui/widgets/app_back_button_handler.dart';
import '../ui/foundations/design_tokens.dart';
import '../core/services/navbar_service.dart';
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
    final Uri uri = state.uri;
    if (uri.scheme == 'dejsipauzu') {
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
            extendBody: true, // Always float navbar for consistent design
            body: navigator,
            bottomNavigationBar: ValueListenableBuilder<bool>(
              valueListenable: NavbarService.instance.isVisible,
              builder: (context, isVisible, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  height: isVisible ? 110.0 : 0.0, // accommodated for floating pill + margins
                  child: SingleChildScrollView( // Prevent overflow error when shrinking
                    physics: const NeverScrollableScrollPhysics(),
                    child: child,
                  ),
                );
              },
              child: const AppBottomNav(),
            ),
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
              child: const PauseMenuPage(),
            );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'breathing',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return AppTransitions.cardSlide(
              child: _wrapWithBackButtonHandler(
                const BreathingPage(),
                showConfirmation: false,
              ),
            );
          },
        ),
        GoRoute(
          path: 'meditation',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return AppTransitions.cardSlide(
              child: _wrapWithBackButtonHandler(
                const MeditationPage(),
                showConfirmation: false,
              ),
            );
          },
        ),
        GoRoute(
          path: 'stretching',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return AppTransitions.cardSlide(
              child: _wrapWithBackButtonHandler(
                const StretchingPage(),
                showConfirmation: false,
              ),
            );
          },
        ),
      ],
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
          GoRoute(
            path: AppRoutes.database,
            builder: (BuildContext context, GoRouterState state) {
              // Lazy import needed? No, we will add import at top.
              return const DatabasePage();
            },
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (BuildContext context, GoRouterState state) {
              return const ProfilePage();
            },
          ),
           GoRoute(
            path: AppRoutes.stats,
            builder: (BuildContext context, GoRouterState state) {
              // Placeholder for stats
              return const Scaffold(body: Center(child: Text('Statistiky coming soon')));
            },
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (BuildContext context, GoRouterState state) {
              // Placeholder for settings
              return const Scaffold(body: Center(child: Text('Nastavení coming soon')));
            },
          ),
      ],
    ),

  ],
);

