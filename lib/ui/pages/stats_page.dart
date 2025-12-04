import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/services/statistics_service.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/frosted_app_bar.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final StatisticsService _statsService = StatisticsService();
  Statistics? _statistics;
  bool _loading = true;
  String _streakText = '';
  String _totalTimeText = '';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _loading = true);
    try {
      final Statistics stats = await _statsService.getStatistics();
      final String streakText = await _statsService.getStreakText();
      final String totalTimeText = await _statsService.getTotalTimeText();
      if (mounted) {
        setState(() {
          _statistics = stats;
          _streakText = streakText;
          _totalTimeText = totalTimeText;
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

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar(
        title: const Text('Statistiky'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + AppSpacing.xl,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Header
                    Text(
                      'Tvůj pokrok',
                      style: text.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Sleduj svou cestu za klidem',
                      style: text.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Streak card
                    _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.error,
                      title: 'Streak',
                      value: _statistics?.streakDays.toString() ?? '0',
                      subtitle: _streakText,
                      gradient: LinearGradient(
                        colors: <Color>[
                          AppColors.error.withOpacity(0.1),
                          AppColors.error.withOpacity(0.05),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Total time card
                    _StatCard(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.primary,
                      title: 'Celkový čas',
                      value: _totalTimeText,
                      subtitle: 'Čas strávený dýcháním',
                      gradient: LinearGradient(
                        colors: <Color>[
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Activity days card
                    _StatCard(
                      icon: Icons.calendar_today_outlined,
                      iconColor: AppColors.success,
                      title: 'Aktivní dny',
                      value: _statistics?.activityDates.length.toString() ?? '0',
                      subtitle: 'Dní s aktivitou',
                      gradient: LinearGradient(
                        colors: <Color>[
                          AppColors.success.withOpacity(0.1),
                          AppColors.success.withOpacity(0.05),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Quick action button
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.go(AppRoutes.pause);
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 24),
                      label: Text(
                        'Začít novou pauzu',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: DesignTokens.borderMedium,
        ),
        boxShadow: DesignTokens.shadowSm,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: text.labelMedium?.copyWith(
                    color: iconColor.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: text.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: text.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

