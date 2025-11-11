import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/expressive_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/plan_item.dart';
import '../widgets/tag_chip.dart';

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
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {});
  }

  Widget _heroCard(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: const ProgressRing(progress: 0.68, size: 120, stroke: 12),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Ahoj!', style: text.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Pokračuj v cestě za klidem. Krátká pauza tě čeká kdykoliv.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: cs.primary.withOpacity(0.06),
                      foregroundColor: cs.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => context.push('/pause'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Začít pauzu'),
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
            leading: const Hero(tag: 'app-logo', child: Icon(Icons.self_improvement)),
            title: const Text('Domů'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.more_horiz_rounded),
                onPressed: () {},
              )
            ],
          ),
          bottomBar: const AppBottomNav(),
          body: RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              children: <Widget>[
                // Top action chip row
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: <BoxShadow>[
                            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(Icons.psychology_alt, size: 18),
                            const SizedBox(width: 8),
                            Text('Chat s Parťákem', style: text.labelLarge),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_rounded),
                      tooltip: 'Nastavení',
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
                      child: Text(
                        'Dnešní plán  ·  7 min',
                        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Upravit'),
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
                Text('Doporučení', style: text.titleMedium),
                const SizedBox(height: AppSpacing.md),
                // Feature cards (plain playful white/black style)
                ExpressiveCard(
                  title: 'Pauza',
                  subtitle: 'Zastav se a nadechni',
                  icon: Icons.self_improvement,
                  colors: <Color>[Colors.white, Colors.white],
                  onTap: () => context.push('/pause'),
                  showWatermark: true,
                  plain: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                ExpressiveCard(
                  title: 'Nálada',
                  subtitle: 'Zaznamenej, jak se máš',
                  icon: Icons.mood,
                  colors: <Color>[Colors.white, Colors.white],
                  onTap: () => context.push('/mood'),
                  showWatermark: true,
                  plain: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                ExpressiveCard(
                  title: 'Tipy',
                  subtitle: 'Rychlá zklidnění',
                  icon: Icons.tips_and_updates,
                  colors: <Color>[Colors.white, Colors.white],
                  onTap: () => context.push('/tips'),
                  showWatermark: true,
                  plain: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                ExpressiveCard(
                  title: 'Parťák',
                  subtitle: 'Ptej se, povídej',
                  icon: Icons.chat_bubble,
                  colors: <Color>[cs.surfaceVariant, cs.primary],
                  onTap: () => context.push('/partner'),
                  showWatermark: true,
                  plain: true,
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
                  onPressed: () => context.push('/list'),
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

