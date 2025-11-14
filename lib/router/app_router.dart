import 'package:flutter/material.dart';
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

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
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
    GoRoute(
      path: AppRoutes.home,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.sharedAxisHorizontal(
          child: const HomePage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.pause,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(child: const PausePage());
      },
    ),
    GoRoute(
      path: AppRoutes.mood,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(child: const MoodPage());
      },
    ),
    GoRoute(
      path: AppRoutes.tips,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(child: const TipsPage());
      },
    ),
    GoRoute(
      path: AppRoutes.partner,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(child: const PartnerPage());
      },
    ),
    GoRoute(
      path: AppRoutes.list,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.sharedAxisHorizontal(
          child: const ListPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.database,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: const DatabasePage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.auth,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: const AuthPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: const SettingsPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.profile,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: const ProfilePage(),
        );
      },
    ),
  ],
);

