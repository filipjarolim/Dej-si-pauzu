/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Dej si pauzu';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Zastav se. Nadechni. Všechno bude v pořádku.';

  // Timing constants
  static const Duration splashMinDuration = Duration(milliseconds: 1500);
  static const Duration refreshDelay = Duration(milliseconds: 700);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 300);

  // UI constants
  static const double minTouchTarget = 44.0;
  static const double maxContentWidth = 600.0;
  static const int maxRetries = 3;

  // Refresh indicator
  static const double refreshTriggerDistance = 100.0; // Increased for less sensitivity
  static const double refreshMaxDistance = 140.0;
}

