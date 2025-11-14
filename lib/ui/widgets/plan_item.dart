import 'package:flutter/material.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import 'tag_chip.dart';

class PlanItem extends StatelessWidget {
  const PlanItem({
    super.key,
    required this.title,
    this.badge,
    this.icon = Icons.check_circle_outline,
    this.onTap,
  });

  final String title;
  final String? badge;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = ((Theme.of(context)).colorScheme);
    final TextTheme text = ((Theme.of(context)).textTheme);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      elevation: 0,
      shadowColor: AppColors.black.withOpacity(0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        onTap: onTap,
        splashColor: AppColors.primary.withOpacity(0.08),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: AppColors.gray200,
              width: DesignTokens.borderThin,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: DesignTokens.containerSm,
                height: DesignTokens.containerSm,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: DesignTokens.borderThin,
                  ),
                ),
                child: Icon(icon, size: DesignTokens.iconSm, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TagChip(
                          label: badge!,
                          background: AppColors.primary.withOpacity(0.1),
                          foreground: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


