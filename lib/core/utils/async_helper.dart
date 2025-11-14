import 'package:flutter/material.dart';

/// Helper utilities for async operations
class AsyncHelper {
  AsyncHelper._();

  /// Safely execute async operation with loading state
  static Future<T?> executeWithLoading<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    required void Function(bool) setLoading,
    Duration? delay,
  }) async {
    try {
      setLoading(true);
      if (delay != null) {
        await Future<void>.delayed(delay);
      }
      final T result = await operation();
      return result;
    } catch (e) {
      if (context.mounted) {
        // Handle error - could show snackbar or dialog
        debugPrint('Error: $e');
      }
      return null;
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }

  /// Retry operation with exponential backoff
  static Future<T?> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }
        await Future<void>.delayed(delay);
        delay = Duration(milliseconds: delay.inMilliseconds * 2);
      }
    }
    return null;
  }
}

