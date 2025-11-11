import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../foundations/spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/expressive_card.dart';

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
          ),
          bottomBar: const AppBottomNav(),
          body: RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                const SizedBox(height: AppSpacing.xl),
                Text('Dej si pauzu', style: text.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                const Text('Krátká pauza, tipy a Parťák – vše na jednom místě.'),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.local_fire_department, size: 16, color: cs.onPrimaryContainer),
                        const SizedBox(width: 6),
                        Text('Dnes', style: text.labelMedium!.copyWith(color: cs.onPrimaryContainer)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
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
                colors: <Color>[Colors.white, Colors.white],
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

