import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/services/statistics_service.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

/// Quick Actions widget for home page
/// Shows quick access to common actions and statistics
class QuickActionsWidget extends StatefulWidget {
  const QuickActionsWidget({super.key});

  @override
  State<QuickActionsWidget> createState() => _QuickActionsWidgetState();
}

class _QuickActionsWidgetState extends State<QuickActionsWidget> {
  final StatisticsService _statsService = StatisticsService();
  String _streakText = '';
  String _totalTimeText = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final String streak = await _statsService.getStreakText();
      final String totalTime = await _statsService.getTotalTimeText();
      if (mounted) {
        setState(() {
          _streakText = streak;
          _totalTimeText = totalTime;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(
          color: AppColors.gray200,
          width: DesignTokens.borderMedium,
        ),
        boxShadow: DesignTokens.shadowMd,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.flash_on_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Rychlé akce',
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Statistics row
          Row(
            children: <Widget>[
              Expanded(
                child: _QuickStatItem(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.error,
                  label: _streakText,
                  subtitle: 'Streak',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.gray200,
              ),
              Expanded(
                child: _QuickStatItem(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.primary,
                  label: _totalTimeText,
                  subtitle: 'Celkový čas',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Action buttons
          Row(
            children: <Widget>[
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Pauza',
                  color: AppColors.primary,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.go(AppRoutes.pause);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistiky',
                  color: AppColors.success,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.go(AppRoutes.stats);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  const _QuickStatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs / 2),
        Text(
          subtitle,
          style: text.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: DesignTokens.borderThin,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

