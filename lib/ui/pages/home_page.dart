import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/constants/app_routes.dart';
import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/expressive_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/plan_item.dart';
import '../widgets/tag_chip.dart';
import '../widgets/custom_refresh_indicator.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;

  Future<void> _simulateWork() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(AppConstants.refreshDelay);
    if (!mounted) return;
    setState(() {});
  }

  Widget _heroCard(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: AppColors.gray200,
          width: DesignTokens.borderMedium,
        ),
        boxShadow: DesignTokens.shadowMd,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: const ProgressRing(progress: 0.68, size: 100, stroke: 10),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ahoj!',
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pokračuj v cestě za klidem. Krátká pauza tě čeká kdykoliv.',
                  style: text.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                      ),
                    onPressed: () => context.navigateToPause(),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(
                      'Začít pauzu',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Stack(
      children: <Widget>[
        AppScaffold(
          appBar: AppBar(
            leading: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                onTap: () => context.navigateToProfile(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Hero(
                    tag: 'app-logo',
                    child: Icon(Icons.self_improvement, size: 24),
                  ),
                ),
              ),
            ),
            title: const Text('Domů'),
            actions: <Widget>[
              Material(
                color: Colors.transparent,
                child: InkWell(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                onTap: () => context.navigateToSettings(),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.more_horiz_rounded, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          bottomBar: const AppBottomNav(),
          body: CustomRefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              children: <Widget>[
                // Top action chip row
                Row(
                  children: <Widget>[
                    Expanded(
                    child: Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      onTap: () => context.navigateToPartner(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            border: Border.all(
                              color: AppColors.gray200,
                              width: DesignTokens.borderThin,
                            ),
                          ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.psychology_alt,
                                  size: DesignTokens.iconSm,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Chat s Parťákem',
                                  style: text.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        onTap: () => context.navigateToSettings(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                            border: Border.all(
                              color: AppColors.gray200,
                              width: DesignTokens.borderThin,
                            ),
                          ),
                          child: Icon(
                            Icons.settings_rounded,
                            size: DesignTokens.iconSm,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _heroCard(context),
                const SizedBox(height: AppSpacing.xl),
                // Today's plan
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Dnešní plán',
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '7 min',
                            style: text.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        'Upravit',
                        style: text.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const PlanItem(
                  title: 'Přečti si uklidňující afirmaci',
                  badge: 'AFIRMACE',
                  icon: Icons.self_improvement,
                ),
                const SizedBox(height: 10),
                const PlanItem(
                  title: 'Sleduj, jak se cítíš',
                  badge: 'NÁLADA',
                  icon: Icons.mood,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Doporučení',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Feature cards (plain playful white/black style)
                ExpressiveCard(
                  title: 'Pauza',
                  subtitle: 'Zastav se a nadechni',
                  icon: Icons.self_improvement,
                  colors: <Color>[AppColors.white, AppColors.white],
                  onTap: () => context.navigateToPause(),
                  showWatermark: true,
                  plain: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                ExpressiveCard(
                  title: 'Nálada',
                  subtitle: 'Zaznamenej, jak se máš',
                  icon: Icons.mood,
                  colors: <Color>[AppColors.white, AppColors.white],
                  onTap: () => context.navigateToMood(),
                  showWatermark: true,
                  plain: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                ExpressiveCard(
                  title: 'Tipy',
                  subtitle: 'Rychlá zklidnění',
                  icon: Icons.tips_and_updates,
                  colors: <Color>[AppColors.white, AppColors.white],
                  onTap: () => context.navigateToTips(),
                  showWatermark: true,
                  plain: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                ExpressiveCard(
                  title: 'Parťák',
                  subtitle: 'Ptej se, povídej',
                  icon: Icons.chat_bubble,
                  colors: AppColors.gradientPlayful,
                  onTap: () => context.navigateToPartner(),
                  showWatermark: true,
                  plain: false,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Utility / Dev',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(label: 'Run task', onPressed: _simulateWork),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Open list skeleton demo',
                  onPressed: () => context.navigateTo(AppRoutes.list),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        LoadingOverlay(show: _loading, message: 'Working...')
      ],
    );
  }
}

