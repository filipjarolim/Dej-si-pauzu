import 'dart:async';

/// Debouncer utility for delaying function calls
class Debouncer {
  Debouncer({required this.duration});

  final Duration duration;
  Timer? _timer;

  /// Execute function after delay, canceling previous calls
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel pending execution
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
  }
}

