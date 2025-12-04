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
  double _overscroll = 0.0;
  bool _hasTriggeredRefresh = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
      _pullProgress = 1.0;
      _hasTriggeredRefresh = true;
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
            _overscroll = 0.0;
            _hasTriggeredRefresh = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // Detect overscroll from the top - listen to both scroll and overscroll notifications
        if (notification is ScrollUpdateNotification) {
          final ScrollMetrics metrics = notification.metrics;
          // Check if we're at the top and pulling down
          final bool atTop = metrics.pixels <= 0;
          final double overscroll = atTop ? -metrics.pixels : 0.0;
          
          if (overscroll > 0) {
            // User is pulling down - show blue bar immediately
            _overscroll = overscroll;
            final double progress = (overscroll / AppConstants.refreshTriggerDistance).clamp(0.0, 1.0);
            
            // Always update to show the bar - no threshold check
            if (_pullProgress != progress) {
              setState(() {
                _pullProgress = progress;
              });
            }
          } else if (!_isRefreshing && _pullProgress > 0) {
            // User scrolled back up (not during refresh)
            if (!_hasTriggeredRefresh) {
              setState(() {
                _pullProgress = 0.0;
                _overscroll = 0.0;
              });
            }
          }
        } else if (notification is OverscrollNotification) {
          // Also listen to overscroll notifications for better detection
          final double overscroll = notification.overscroll < 0 ? -notification.overscroll : 0.0;
          if (overscroll > 0) {
            _overscroll = overscroll;
            final double progress = (overscroll / AppConstants.refreshTriggerDistance).clamp(0.0, 1.0);
            if (_pullProgress != progress) {
              setState(() {
                _pullProgress = progress;
              });
            }
            }
        } else if (notification is ScrollEndNotification && !_isRefreshing) {
          // User released - check if we should trigger refresh
          if (_overscroll >= AppConstants.refreshTriggerDistance && !_hasTriggeredRefresh) {
            _handleRefresh();
          } else if (_overscroll < AppConstants.refreshTriggerDistance) {
            // Reset if not enough pull
            setState(() {
              _pullProgress = 0.0;
              _overscroll = 0.0;
              _hasTriggeredRefresh = false;
            });
          }
        }
        
        return false; // Don't consume the notification
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Use RefreshIndicator ONLY for enabling overscroll gesture
          // Move indicator way off-screen (below viewport) so it's never visible at 0 pixels
          RefreshIndicator(
            onRefresh: _handleRefresh,
            backgroundColor: Colors.transparent,
            color: Colors.transparent,
            displacement: 10000, // Move indicator way off-screen - completely hidden, never appears
            child: widget.child,
          ),
          // Custom refresh line indicator at the top - always show when pulling or refreshing
          if (_pullProgress > 0.0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
              child: RepaintBoundary(
                child: AnimatedOpacity(
                    opacity: (_pullProgress > 0.0 || _isRefreshing) ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: RefreshRoulette(
                      refreshOffset: _isRefreshing ? AppConstants.refreshTriggerDistance : _overscroll,
                      isRefreshing: _isRefreshing,
                    ),
                    ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
