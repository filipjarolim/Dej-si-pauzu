import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'router/app_router.dart';
import 'debug/perf.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/foundations/colors.dart';
import 'ui/foundations/design_tokens.dart';
import 'core/widgets/update_checker.dart';
import 'core/services/app_service.dart';
import 'core/services/database_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/statistics_service.dart';
import 'core/services/video_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Make sure to create a .env file based on .env.example');
  }

  // Enable input resampling for smoother pointer events on high-refresh devices.
  GestureBinding.instance.resamplingEnabled = true;

  // Tune image cache for smoother scrolling through media-heavy screens.
  // Adjust conservatively to balance memory vs. jank reduction.
  PaintingBinding.instance.imageCache.maximumSizeBytes = 256 * 1024 * 1024; // 256 MB
  PaintingBinding.instance.imageCache.maximumSize = 1000; // max number of images

  // Robust error handling in release/profile without crashing the engine.
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };
  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (kDebugMode) {
      // Avoid crashing; log instead during development.
      // In production, hook your crash reporting here.
      // ignore: avoid_print
      print('Uncaught zone error: $error\n$stack');
    }
    return true;
  };

  // Initialize services
  ServiceRegistry.register<DatabaseService>(DatabaseService());
  ServiceRegistry.register<AuthService>(AuthService());
  ServiceRegistry.register<StatisticsService>(StatisticsService());
  ServiceRegistry.register<VideoService>(VideoService());
  
  // Initialize all services (includes video preloading)
  await ServiceRegistry.initializeAll();

  // Lock orientation to portrait for consistent mobile experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Ensure system UI overlay style is modern (transparent status bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Enable debug frame timings log to observe jank during development.
    if (kDebugMode) {
      PerfDebugTools.enableFrameTimingsLogging();
    }
    return UpdateChecker(
      checkOnStartup: true,
      forceUpdate: false, // Set to true to force updates
      child: MaterialApp.router(
        title: 'Dej si pauzu',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.white,
        colorScheme: AppColorScheme.light,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          titleTextStyle: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            side: BorderSide(
              color: AppColors.gray300.withOpacity(0.5),
              width: DesignTokens.borderMedium,
            ),
          ),
          color: AppColors.white,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            side: BorderSide(
              color: AppColors.gray300,
              width: DesignTokens.borderMedium,
            ),
          ),
          backgroundColor: AppColors.white,
          elevation: 8,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            side: BorderSide(
              color: AppColors.gray300,
              width: DesignTokens.borderMedium,
            ),
          ),
          backgroundColor: AppColors.white,
          contentTextStyle: GoogleFonts.quicksand(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            borderSide: BorderSide(
              color: AppColors.gray300,
              width: DesignTokens.borderMedium,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            borderSide: BorderSide(
              color: AppColors.gray300,
              width: DesignTokens.borderMedium,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: DesignTokens.borderThick,
            ),
          ),
          labelStyle: GoogleFonts.quicksand(
            color: AppColors.gray600,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: GoogleFonts.quicksand(
            color: AppColors.gray500,
          ),
        ),
        textTheme: GoogleFonts.quicksandTextTheme().copyWith(
          displayLarge: GoogleFonts.quicksand(
            fontSize: 57,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            height: 1.1,
          ),
          displayMedium: GoogleFonts.quicksand(
            fontSize: 45,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            height: 1.15,
          ),
          displaySmall: GoogleFonts.quicksand(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          headlineLarge: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          headlineMedium: GoogleFonts.quicksand(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.25,
          ),
          headlineSmall: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.3,
          ),
          titleLarge: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.3,
          ),
          titleMedium: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            height: 1.35,
          ),
          titleSmall: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
          ),
          bodyLarge: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 1.5,
          ),
          bodyMedium: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.5,
          ),
          bodySmall: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            height: 1.5,
          ),
          labelLarge: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            height: 1.4,
          ),
          labelMedium: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            height: 1.4,
          ),
          labelSmall: GoogleFonts.quicksand(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            height: 1.4,
          ),
        ).apply(
          bodyColor: AppColors.black,
          displayColor: AppColors.black,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.white,
          elevation: 0,
          indicatorColor: AppColors.primary.withOpacity(0.1),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                );
              }
              return GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              );
            },
          ),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.primary);
              }
              return IconThemeData(color: AppColors.gray600);
            },
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        // Lock text scaling globally for consistent typographic rhythm across all devices.
        final MediaQueryData mq = MediaQuery.of(context);
        final Widget wrappedChild = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
        // Force text scale factor to 1.0 regardless of system settings
        return MediaQuery(
          data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: wrappedChild,
        );
      },
      routerConfig: appRouter,
    ),
    );
  }
}

// Home is now provided via router: see ui/pages/home_page.dart

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  // Support smooth scrolling with touch, mouse, trackpad, stylus, etc.
  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };

  // Remove default glow overscroll for a cleaner, modern feel.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
