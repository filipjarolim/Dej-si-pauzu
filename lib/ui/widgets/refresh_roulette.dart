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
      duration: const Duration(milliseconds: 1500), // Slightly slower for smoother animation
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    // Always repeat for smooth dot pulse animation
    _controller.repeat();
  }

  @override
  void didUpdateWidget(RefreshRoulette oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always keep controller repeating for smooth pulse animation
    if (!_controller.isAnimating) {
      _controller.repeat();
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
      height: 4, // Slightly taller for better visibility
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              size: Size(double.infinity, 4),
              painter: _RefreshLinePainter(
                progress: widget.isRefreshing ? 1.0 : pullProgress,
                isRefreshing: widget.isRefreshing,
                animationValue: _controller.value,
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
  });

  final double progress;
  final bool isRefreshing;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    if (isRefreshing) {
      // Beautiful animated gradient wave effect when refreshing
      final Rect rect = Rect.fromLTWH(0, 0, width, height);
      
      // Create gradient from skyBlue to deepBlue
      final Paint gradientPaint = Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            AppColors.skyBlue,
            AppColors.primary,
            AppColors.skyBlue,
          ],
          stops: <double>[
            0.0,
            0.5,
            1.0,
          ],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = height
        ..strokeCap = StrokeCap.round;

      // Create smooth animated wave pattern with multiple waves
      final double waveLength = width / 3.0;
      final double waveSpeed = animationValue * 2 * math.pi;
      final Path path = Path();
      final int segments = (width / 1.5).round(); // More segments for smoother curve

      for (int i = 0; i <= segments; i++) {
        final double x = (width / segments) * i;
        // Multiple sine waves for more interesting pattern
        final double wave1 = math.sin((x / waveLength) + waveSpeed) * (height / 2 - 0.5);
        final double wave2 = math.sin((x / waveLength * 1.5) + waveSpeed * 1.3) * (height / 4 - 0.25);
        final double y = height / 2 + wave1 + wave2;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, gradientPaint);
      
      // Add subtle glow effect
      final Paint glowPaint = Paint()
        ..color = AppColors.skyBlue.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = height * 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, glowPaint);
    } else {
      // Beautiful gradient progress bar when pulling
      final double progressWidth = width * progress;
      
      if (progressWidth > 0) {
        // Subtle background line with gradient
        final Rect bgRect = Rect.fromLTWH(0, 0, width, height);
        final Paint backgroundPaint = Paint()
          ..shader = LinearGradient(
            colors: <Color>[
              AppColors.skyBlue.withOpacity(0.1),
              AppColors.primary.withOpacity(0.1),
            ],
          ).createShader(bgRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = height
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(0, height / 2),
          Offset(width, height / 2),
          backgroundPaint,
        );

        // Gradient progress line
        final Rect progressRect = Rect.fromLTWH(0, 0, progressWidth, height);
        final Paint progressPaint = Paint()
          ..shader = LinearGradient(
            colors: <Color>[
              AppColors.skyBlue,
              AppColors.primary,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(progressRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = height
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(0, height / 2),
          Offset(progressWidth, height / 2),
          progressPaint,
        );

        // Animated glowing dot at the end with gradient
        if (progressWidth > 8) {
          final double dotX = progressWidth - 6;
          final double pulse = 0.5 + 0.5 * math.sin(animationValue * 2 * math.pi * 2); // Pulse animation
          
          // Outer glow with gradient colors
          final Paint glowPaint = Paint()
            ..shader = RadialGradient(
              colors: <Color>[
                AppColors.skyBlue.withOpacity(0.4 * pulse),
                AppColors.primary.withOpacity(0.2 * pulse),
                Colors.transparent,
              ],
            ).createShader(Rect.fromCircle(
              center: Offset(dotX, height / 2),
              radius: 8,
            ))
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(dotX, height / 2), 8, glowPaint);
          
          // Inner dot with gradient
          final Paint dotPaint = Paint()
            ..shader = RadialGradient(
              colors: <Color>[
                AppColors.skyBlue,
                AppColors.primary,
              ],
            ).createShader(Rect.fromCircle(
              center: Offset(dotX, height / 2),
              radius: 4,
            ))
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(dotX, height / 2), 4, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_RefreshLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRefreshing != isRefreshing ||
        oldDelegate.animationValue != animationValue;
  }
}
