import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

typedef TimingsCallback = void Function(List<FrameTiming> timings);

class PerfDebugTools {
  PerfDebugTools._();

  static TimingsCallback? _registered;
  static Timer? _timer;
  static int _thresholdMs = 24; // Default to >60Hz budget to avoid noise.
  static bool _logAll = false; // When true, always print summaries.
  static int _summaryIntervalMs = 2000; // Aggregate and print every 2s.

  static const int _maxSamples = 600; // Ring buffer cap (~10s @ 60fps)
  static final List<int> _buildSamples = <int>[];
  static final List<int> _rasterSamples = <int>[];

  static void enableFrameTimingsLogging({int thresholdMs = 24, bool logAll = false, int summaryIntervalMs = 2000}) {
    if (!kDebugMode) return;
    _disposeInternal();
    _thresholdMs = thresholdMs;
    _logAll = logAll;
    _summaryIntervalMs = summaryIntervalMs;
    _registered = (List<FrameTiming> timings) {
      for (final FrameTiming t in timings) {
        final int buildMs = t.buildDuration.inMilliseconds;
        final int rasterMs = t.rasterDuration.inMilliseconds;
        if (_buildSamples.length >= _maxSamples) _buildSamples.removeAt(0);
        if (_rasterSamples.length >= _maxSamples) _rasterSamples.removeAt(0);
        _buildSamples.add(buildMs);
        _rasterSamples.add(rasterMs);
      }
    };
    SchedulerBinding.instance.addTimingsCallback(_registered!);
    _timer = Timer.periodic(Duration(milliseconds: _summaryIntervalMs), (_) => _flushSummary());
  }

  static void disableFrameTimingsLogging() {
    if (!kDebugMode) return;
    _disposeInternal();
  }

  static void _disposeInternal() {
    if (_registered != null) {
      SchedulerBinding.instance.removeTimingsCallback(_registered!);
      _registered = null;
    }
    _timer?.cancel();
    _timer = null;
    _buildSamples.clear();
    _rasterSamples.clear();
  }

  static void _flushSummary() {
    if (_buildSamples.isEmpty || _rasterSamples.isEmpty) return;
    final int n = _buildSamples.length;
    final double avgBuild = _buildSamples.reduce((a, b) => a + b) / n;
    final double avgRaster = _rasterSamples.reduce((a, b) => a + b) / n;
    final int maxBuild = _buildSamples.reduce((a, b) => a > b ? a : b);
    final int maxRaster = _rasterSamples.reduce((a, b) => a > b ? a : b);
    final int p95Build = _percentile(_buildSamples, 0.95);
    final int p95Raster = _percentile(_rasterSamples, 0.95);

    final bool exceeds =
        maxBuild >= _thresholdMs || maxRaster >= _thresholdMs || p95Build >= _thresholdMs || p95Raster >= _thresholdMs;
    if (_logAll || exceeds) {
      // ignore: avoid_print
      print('[frames] n=$n avg(build)=${avgBuild.toStringAsFixed(1)}ms avg(raster)=${avgRaster.toStringAsFixed(1)}ms '
          'p95(build)=${p95Build}ms p95(raster)=${p95Raster}ms '
          'max(build)=${maxBuild}ms max(raster)=${maxRaster}ms');
    }

    _buildSamples.clear();
    _rasterSamples.clear();
  }

  static int _percentile(List<int> values, double p) {
    if (values.isEmpty) return 0;
    final List<int> sorted = List<int>.from(values)..sort();
    final int idx = (p * (sorted.length - 1)).round();
    return sorted[idx];
  }
}

