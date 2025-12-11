import 'package:flutter/material.dart';

class StaggeredEntry extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final double verticalOffset;
  final Curve curve;

  const StaggeredEntry({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 500),
    this.verticalOffset = 30.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 1.0, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.verticalOffset / 100), // Approximate relative offset
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start delay
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
