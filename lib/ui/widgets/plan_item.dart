import 'package:flutter/material.dart';
import '../foundations/spacing.dart';
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: cs.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TagChip(
                          label: badge!,
                          background: cs.secondaryContainer.withOpacity(0.6),
                          foreground: cs.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}


