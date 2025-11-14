import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/motion.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final Widget? leading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context)
        .textTheme
        .labelLarge!
        .copyWith(color: AppColors.white);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.leading != null) ...<Widget>{
          widget.leading!,
          const SizedBox(width: AppSpacing.sm),
        },
        Text(
          widget.label,
          style: textStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    final BorderRadius radius = BorderRadius.circular(DesignTokens.radiusMd);

    final Widget button = Material(
      color: widget.onPressed == null
          ? AppColors.primary.withOpacity(0.4)
          : AppColors.primary,
      borderRadius: radius,
      elevation: widget.onPressed == null ? 0 : 2,
      shadowColor: AppColors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: radius,
        onTap: _handleTap,
        onHighlightChanged: (bool v) => setState(() => _pressed = v),
        splashColor: AppColors.white.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md + 2,
          ),
          child: content,
        ),
      ),
    );

    final Widget animated = RepaintBoundary(
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.smooth, // Smoother curve
        child: button,
      ),
    );

    if (widget.expanded) {
      return SizedBox(
        width: double.infinity,
        child: animated,
      );
    }
    return animated;
  }
}

