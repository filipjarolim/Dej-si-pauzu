/// Application route constants
/// Centralized route definitions for type-safe navigation
class AppRoutes {
  AppRoutes._();

  // Main routes
  static const String splash = '/';
  static const String home = '/home';
  
  // Feature routes
  static const String pause = '/pause';
  static const String mood = '/mood';
  static const String tips = '/tips';
  static const String partner = '/partner';
  
  // Utility routes
  static const String list = '/list';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String stats = '/stats';
  
  // Dev routes
  static const String database = '/database';
  static const String auth = '/auth';
  static const String debugChat = '/debug_chat';

  /// Get route name from path
  static String? routeName(String path) {
    switch (path) {
      case splash:
        return 'Splash';
      case home:
        return 'Home';
      case pause:
        return 'Pause';
      case mood:
        return 'Mood';
      case tips:
        return 'Tips';
      case partner:
        return 'Partner';
      case list:
        return 'List';
      case settings:
        return 'Settings';
      case profile:
        return 'Profile';
      case stats:
        return 'Stats';
      case database:
        return 'Database';
      case auth:
        return 'Auth';
      default:
        return null;
    }
  }
}

