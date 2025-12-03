import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> _tips = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': 'Hluboké dýchání',
        'subtitle': '4-7-8 technika',
        'icon': Icons.air,
        'description': 'Nadechni se na 4 doby, zadrž na 7, vydechni na 8.',
      },
      <String, dynamic>{
        'title': 'Procházka',
        'subtitle': '5 minut venku',
        'icon': Icons.directions_walk,
        'description': 'I krátká procházka může změnit tvou náladu.',
      },
      <String, dynamic>{
        'title': 'Meditace',
        'subtitle': 'Mindfulness',
        'icon': Icons.self_improvement,
        'description': 'Věnuj chvíli pozornosti svému dechu a přítomnosti.',
      },
      <String, dynamic>{
        'title': 'Pití vody',
        'subtitle': 'Hydratace',
        'icon': Icons.water_drop,
        'description': 'Dehydratace může zhoršit úzkost a stres.',
      },
    ];

    return AppScaffold(
      appBar: AppBar(title: const Text('Tipy na zklidnění')),
      bottomBar: null, // Navbar provided by ShellRoute
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Rychlá zklidnění',
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md + 4),
                  Text(
                    'Krátké rady a nápady, jak se uvolnit a pečovat o sebe v každodenním životě.',
                    style: text.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl + 4),
            ...List<Widget>.generate(
              _tips.length,
              (int index) {
                final Map<String, dynamic> tip = _tips[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                  ),
                  child: Material(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                      onTap: () {
                        // Show tip detail functionality will be implemented
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                          border: Border.all(
                            color: AppColors.gray200,
                            width: DesignTokens.borderMedium,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                                border: Border.all(
                                  color: cs.primary.withOpacity(0.12),
                                  width: DesignTokens.borderThin,
                                ),
                              ),
                              child: Icon(
                                tip['icon'] as IconData,
                                size: 28,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    tip['title'] as String,
                                    style: text.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tip['subtitle'] as String,
                                    style: text.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tip['description'] as String,
                                    style: text.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
