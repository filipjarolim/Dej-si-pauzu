import 'package:flutter/material.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/personality_cards_widget.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> tips = <Map<String, dynamic>>[
      <String, dynamic>{
        'title': 'Hluboké dýchání',
        'subtitle': '4-7-8 technika',
        'icon': Icons.air,
        'description': 'Nadechni se na 4 doby, zadrž na 7, vydechni na 8.',
        'color': const Color(0xFF6366F1), // Indigo
      },
      <String, dynamic>{
        'title': 'Procházka',
        'subtitle': '5 minut venku',
        'icon': Icons.directions_walk,
        'description': 'I krátká procházka zvýší hladinu endorfinů.',
        'color': const Color(0xFF34D399), // Emerald
      },
      <String, dynamic>{
        'title': 'Meditace',
        'subtitle': 'Mindfulness',
        'icon': Icons.self_improvement,
        'description': 'Věnuj chvíli pozornosti svému dechu.',
        'color': const Color(0xFFEC4899), // Pink
      },
      <String, dynamic>{
        'title': 'Pití vody',
        'subtitle': 'Hydratace',
        'icon': Icons.water_drop,
        'description': 'Dehydratace zvyšuje úzkost.',
        'color': const Color(0xFF38BDF8), // Sky
      },
      <String, dynamic>{
        'title': 'Spánek',
        'subtitle': 'Regenerace',
        'icon': Icons.bedtime,
        'description': 'Kvalitní spánek je základ.',
        'color': const Color(0xFFF59E0B), // Amber
      },
      <String, dynamic>{
        'title': 'Čtení',
        'subtitle': 'Odpočinek',
        'icon': Icons.menu_book,
        'description': 'Ponoř se do jiného světa.',
        'color': const Color(0xFF8B5CF6), // Violet
      },
    ];

    // Split for masonry
    final leftColumn = <Map<String, dynamic>>[];
    final rightColumn = <Map<String, dynamic>>[];
    for (var i = 0; i < tips.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(tips[i]);
      } else {
        rightColumn.add(tips[i]);
      }
    }

    return AppScaffold(
      backgroundColor: AppColors.surfaceSubtle,
      appBar: AppBar(title: const Text('Tipy na zklidnění')),
      bottomBar: null,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Inspirace',
              style: text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Malé kroky k velké pohodě.',
              style: text.bodyLarge?.copyWith(
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 24),
            
            // AI Personality Section (Optional highlight)
            const PersonalityCardsWidget(),
            
            const SizedBox(height: 32),

            // Masonry Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: leftColumn.map((tip) => _buildTipCard(tip, text)).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                     children: rightColumn.map((tip) => _buildTipCard(tip, text)).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip, TextTheme text) {
    final Color color = tip['color'] as Color;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(tip['icon'] as IconData, color: color, size: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tip['title'] as String,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip['subtitle'] as String,
                    style: text.bodySmall?.copyWith(
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tip['description'] as String,
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.gray600,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
