import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 180, this.stroke = 14});

  final double progress; // 0..1
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
      builder: (BuildContext context, double value, Widget? _) {
        return CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(
            value: value,
            stroke: stroke,
            trackColor: Colors.black.withOpacity(0.08),
            gradient: const SweepGradient(
              startAngle: -math.pi / 2,
              endAngle: 3 * math.pi / 2,
              colors: <Color>[
                Color(0xFF34D399), // mint
                Color(0xFF60A5FA), // soft blue
                Color(0xFFFB7185), // soft coral
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.value, required this.stroke, required this.trackColor, required this.gradient});

  final double value;
  final double stroke;
  final Color trackColor;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.shortestSide - stroke) / 2;
    final Offset c = Offset(size.width / 2, size.height / 2);

    final Rect rect = Rect.fromCircle(center: c, radius: radius);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final Paint progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Rect.fromCircle(center: c, radius: radius));

    // Draw track (full circle)
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, track);

    // Draw progress arc
    final double sweep = (2 * math.pi) * value;
    if (sweep > 0) {
      canvas.drawArc(rect, -math.pi / 2, sweep, false, progress);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.stroke != stroke;
  }
}
