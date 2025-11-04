import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  int _indexForLocation(String location) {
    if (location.startsWith('/list')) return 1;
    return 0; // default to home
  }

  String _locationForIndex(int index) {
    switch (index) {
      case 1:
        return '/list';
      case 0:
      default:
        return '/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final int selected = _indexForLocation(location);

    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (int idx) {
        final String target = _locationForIndex(idx);
        if (target != location) {
          context.go(target);
        }
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'List'),
      ],
    );
  }
}
