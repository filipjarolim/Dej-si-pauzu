import 'package:flutter/material.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color? foreground;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelMedium;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
        border: Border.all(
          color: (foreground ?? AppColors.primary).withOpacity(0.15),
          width: DesignTokens.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>{
            Icon(icon, size: 13, color: foreground ?? cs.primary),
            const SizedBox(width: 5),
          },
          Text(
            label,
            style: (labelStyle ?? const TextStyle()).copyWith(
              color: foreground ?? AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


