import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  int _indexForLocation(String location) {
    if (location.startsWith('/pause')) return 1;
    if (location.startsWith('/mood')) return 2;
    if (location.startsWith('/tips')) return 3;
    if (location.startsWith('/partner')) return 4;
    return 0; // default to home
  }

  String _locationForIndex(int index) {
    switch (index) {
      case 1:
        return '/pause';
      case 2:
        return '/mood';
      case 3:
        return '/tips';
      case 4:
        return '/partner';
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
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: selected,
      onDestinationSelected: (int idx) {
        HapticFeedback.selectionClick();
        final String target = _locationForIndex(idx);
        if (target == location) {
          final ScrollController? c = PrimaryScrollController.maybeOf(context);
          c?.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
          return;
        }
        context.go(target);
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Domů'),
        NavigationDestination(icon: Icon(Icons.self_improvement_outlined), selectedIcon: Icon(Icons.self_improvement), label: 'Pauza'),
        NavigationDestination(icon: Icon(Icons.mood_outlined), selectedIcon: Icon(Icons.mood), label: 'Nálada'),
        NavigationDestination(icon: Icon(Icons.tips_and_updates_outlined), selectedIcon: Icon(Icons.tips_and_updates), label: 'Tipy'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Parťák'),
      ],
    );
  }
}
