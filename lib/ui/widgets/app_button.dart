import 'package:flutter/material.dart';

import '../foundations/motion.dart';
import '../foundations/spacing.dart';

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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextStyle textStyle = Theme.of(context)
        .textTheme
        .labelLarge!
        .copyWith(color: colorScheme.onPrimary);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.leading != null) ...<Widget>{
          widget.leading!,
          const SizedBox(width: AppSpacing.sm),
        },
        Text(widget.label, style: textStyle),
      ],
    );

    final BorderRadius radius = BorderRadius.circular(18);

    final Widget button = Material(
      color: widget.onPressed == null
          ? colorScheme.primary.withOpacity(0.5)
          : colorScheme.primary,
      borderRadius: radius,
      child: InkWell
        (
        borderRadius: radius,
        onTap: widget.onPressed,
        onHighlightChanged: (bool v) => setState(() => _pressed = v),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: content,
        ),
      ),
    );

    final Widget animated = AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      child: button,
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

