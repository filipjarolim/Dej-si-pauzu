import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  int? _selectedMood;

  final List<Map<String, dynamic>> _moods = <Map<String, dynamic>>[
    <String, dynamic>{'icon': Icons.sentiment_very_dissatisfied, 'label': 'Špatně', 'color': const Color(0xFFEF4444)},
    <String, dynamic>{'icon': Icons.sentiment_dissatisfied, 'label': 'Špatně', 'color': const Color(0xFFF97316)},
    <String, dynamic>{'icon': Icons.sentiment_neutral, 'label': 'OK', 'color': const Color(0xFFFBBF24)},
    <String, dynamic>{'icon': Icons.sentiment_satisfied, 'label': 'Dobře', 'color': const Color(0xFF34D399)},
    <String, dynamic>{'icon': Icons.sentiment_very_satisfied, 'label': 'Skvěle', 'color': const Color(0xFF10B981)},
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return AppScaffold(
      appBar: AppBar(title: const Text('Nálada')),
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
                    'Jak se máš?',
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md + 4),
                  Text(
                    'Krátké zaznamenání nálady ti pomůže lépe porozumět sobě a sledovat své pocity v čase.',
                    style: text.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl + 8),
            // Mood selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(
                  _moods.length,
                  (int index) {
                    final Map<String, dynamic> mood = _moods[index];
                    final bool isSelected = _selectedMood == index;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedMood = index);
                      },
                      child: RepaintBoundary(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          width: 64,
                          height: 64,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (mood['color'] as Color).withOpacity(0.2)
                              : AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? mood['color'] as Color
                                : AppColors.gray200,
                            width: isSelected ? DesignTokens.borderThick : DesignTokens.borderMedium,
                          ),
                          boxShadow: isSelected
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: (mood['color'] as Color).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          mood['icon'] as IconData,
                          size: 32,
                          color: isSelected ? mood['color'] as Color : cs.onSurfaceVariant,
                        ),
                      ),
                        ),
                      );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl + 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: AppButton(
                label: 'Zaznamenat náladu',
                onPressed: _selectedMood != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        // Save mood functionality will be implemented
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
