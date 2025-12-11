import 'package:flutter/material.dart';


class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500), // Slower for smoother shimmer
    lowerBound: 0.0,
    upperBound: 1.0,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final double t = Curves.easeInOut.transform(_controller.value);
            final double width = bounds.width;
            final double start = -0.3 + t * 1.6; // sweep across
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                cs.surfaceContainerHighest,
                cs.surfaceContainerHighest.withOpacity(0.5),
                cs.surfaceContainerHighest,
              ],
              stops: <double>[
                (start - 0.25).clamp(0.0, 1.0),
                start.clamp(0.0, 1.0),
                (start + 0.25).clamp(0.0, 1.0),
              ],
            ).createShader(Rect.fromLTWH(0, 0, width, bounds.height));
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height, this.borderRadius = 12});

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

