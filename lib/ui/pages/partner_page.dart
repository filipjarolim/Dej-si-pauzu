import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class PartnerPage extends StatelessWidget {
  const PartnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: AppBar(title: const Text('Parťák pro pauzu')),
      bottomBar: null, // Navbar provided by ShellRoute
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Hero illustration
            Container(
              width: 180,
              height: 180,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.primary.withOpacity(0.12),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.psychology_alt,
                size: 90,
                color: cs.primary,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Jsem tu pro tebe',
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md + 4),
                  Text(
                    'Krátká konverzace, která ti pomůže zorientovat se v emocích a najít klid. Můžeš se ptát na cokoliv nebo jen povídat.',
                    style: text.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl + 8),
                  AppButton(
                    label: 'Začít konverzaci',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // Start chat functionality will be implemented
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl + 8),
                  // Example prompts
                  Text(
                    'Příklady otázek',
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...<String>[
                    'Jak se dnes cítím?',
                    'Co mi pomůže se uklidnit?',
                    'Proč se cítím takto?',
                  ].map(
                    (String prompt) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Material(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            // Use prompt functionality will be implemented
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              border: Border.all(
                                color: AppColors.gray200,
                                width: DesignTokens.borderThin,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    prompt,
                                    style: text.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: cs.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
