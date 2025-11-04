import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/navigation/transitions.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/splash_page.dart';
import '../ui/pages/list_page.dart';

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
      path: '/list',
      pageBuilder: (BuildContext context, GoRouterState state) {
        return AppTransitions.sharedAxisHorizontal(
          child: const ListPage(),
        );
      },
    ),
  ],
);

