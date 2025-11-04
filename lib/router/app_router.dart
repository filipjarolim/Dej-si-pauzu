import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeThrough(
          child: SplashPage(
            initialize: () async {
              // Put real startup work here: hydrate state, warm caches, etc.
            },
            onReady: (BuildContext ctx) => ctx.go('/home'),
            // Keeping `next` unused when using router to avoid double nav.
            next: const SizedBox.shrink(),
          ),
        );
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.sharedAxisHorizontal(
          child: const HomePage(),
        );
      },
    ),
    GoRoute(
      path: '/pause',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(child: const PausePage());
      },
    ),
    GoRoute(
      path: '/mood',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(child: const MoodPage());
      },
    ),
    GoRoute(
      path: '/tips',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(child: const TipsPage());
      },
    ),
    GoRoute(
      path: '/partner',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(child: const PartnerPage());
      },
    ),
    GoRoute(
      path: '/list',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.sharedAxisHorizontal(
          child: const ListPage(),
        );
      },
    ),
    GoRoute(
      path: '/database',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: const DatabasePage(),
        );
      },
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.fadeScale(
          child: const AuthPage(),
        );
      },
    ),
  ],
);

