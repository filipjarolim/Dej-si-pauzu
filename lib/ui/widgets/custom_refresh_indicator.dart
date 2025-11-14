import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'refresh_roulette.dart';

/// Custom refresh indicator with roulette animation
/// Simple wrapper that tracks pull state and shows custom indicator
class CustomRefreshIndicator extends StatefulWidget {
  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator> {
  bool _isRefreshing = false;
  double _pullProgress = 0.0;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
      _pullProgress = 1.0;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        // Brief delay for smooth fade out
        await Future<void>.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          setState(() {
            _isRefreshing = false;
            _pullProgress = 0.0;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // Track pull progress
        if (notification is ScrollUpdateNotification && !_isRefreshing) {
          final double overscroll = -notification.metrics.pixels;
          if (overscroll > 0) {
            final double progress = (overscroll / AppConstants.refreshTriggerDistance).clamp(0.0, 1.0);
            if ((progress - _pullProgress).abs() > 0.05) {
              setState(() => _pullProgress = progress);
            }
          } else if (_pullProgress > 0) {
            setState(() => _pullProgress = 0.0);
          }
        }
        return false;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          RefreshIndicator(
            onRefresh: _handleRefresh,
            backgroundColor: Colors.transparent,
            color: Colors.transparent,
            displacement: 0,
            child: widget.child,
          ),
          // Custom refresh line indicator at the top
          if (_pullProgress > 0.05 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: AnimatedOpacity(
                  opacity: (_pullProgress > 0.05 || _isRefreshing) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                    child: RefreshRoulette(
                      refreshOffset: _pullProgress * AppConstants.refreshTriggerDistance,
                      isRefreshing: _isRefreshing,
                    ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
