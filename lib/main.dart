import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'debug/perf.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Enable debug frame timings log to observe jank during development.
    PerfDebugTools.enableFrameTimingsLogging();
    return MaterialApp.router(
      title: 'Dej si pauzu',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        // iOS-like smoothness with slightly more rounded components and reduced visual noise.
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        // Lock text scaling on Android for consistent typographic rhythm across devices.
        final MediaQueryData mq = MediaQuery.of(context);
        final bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
        final Widget wrappedChild = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
        if (isAndroid) {
          return MediaQuery(
            data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
            child: wrappedChild,
          );
        }
        return wrappedChild;
      },
      routerConfig: appRouter,
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
