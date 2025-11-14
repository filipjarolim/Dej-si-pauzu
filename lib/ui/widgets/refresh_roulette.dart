import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../foundations/colors.dart';

/// Custom refresh indicator - animated line at the top
class RefreshRoulette extends StatefulWidget {
  const RefreshRoulette({
    super.key,
    required this.refreshOffset,
    required this.isRefreshing,
  });

  final double refreshOffset;
  final bool isRefreshing;

  @override
  State<RefreshRoulette> createState() => _RefreshRouletteState();
}

class _RefreshRouletteState extends State<RefreshRoulette>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    if (widget.isRefreshing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RefreshRoulette oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !oldWidget.isRefreshing) {
      _controller.repeat();
    } else if (!widget.isRefreshing && oldWidget.isRefreshing) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double pullProgress = (widget.refreshOffset / AppConstants.refreshTriggerDistance).clamp(0.0, 1.0);

    return SizedBox(
      height: 3,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              size: Size(double.infinity, 3),
              painter: _RefreshLinePainter(
                progress: widget.isRefreshing ? 1.0 : pullProgress,
                isRefreshing: widget.isRefreshing,
                animationValue: _controller.value,
                color: AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RefreshLinePainter extends CustomPainter {
  _RefreshLinePainter({
    required this.progress,
    required this.isRefreshing,
    required this.animationValue,
    required this.color,
  });

  final double progress;
  final bool isRefreshing;
  final double animationValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    if (isRefreshing) {
      // Smooth animated wave effect when refreshing
      final Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = height
        ..strokeCap = StrokeCap.round;

      // Create smooth animated wave pattern
      final double waveLength = width / 2.5;
      final double waveSpeed = animationValue * 2 * math.pi;
      final Path path = Path();
      final int segments = (width / 2).round();

      for (int i = 0; i <= segments; i++) {
        final double x = (width / segments) * i;
        final double y = height / 2 + 
            (math.sin((x / waveLength) + waveSpeed) * (height / 2 - 0.5));
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    } else {
      // Animated progress bar when pulling
      final double progressWidth = width * progress;
      
      if (progressWidth > 0) {
        // Subtle background line
        final Paint backgroundPaint = Paint()
          ..color = color.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = height
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(0, height / 2),
          Offset(width, height / 2),
          backgroundPaint,
        );

        // Progress line
        final Paint progressPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = height
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(0, height / 2),
          Offset(progressWidth, height / 2),
          progressPaint,
        );

        // Animated glowing dot at the end
        if (progressWidth > 8) {
          final double dotX = progressWidth - 5;
          
          // Outer glow
          final Paint glowPaint = Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(dotX, height / 2), 5, glowPaint);
          
          // Inner dot
          final Paint dotPaint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(dotX, height / 2), 3, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_RefreshLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRefreshing != isRefreshing ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
