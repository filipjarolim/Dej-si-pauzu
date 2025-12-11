import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
/// Widget displaying 3 personality cards in a horizontal scrollable list
class PersonalityCardsWidget extends StatefulWidget {
  const PersonalityCardsWidget({super.key});

  @override
  State<PersonalityCardsWidget> createState() => _PersonalityCardsWidgetState();
}

class _PersonalityCardsWidgetState extends State<PersonalityCardsWidget> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _personalities = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'wise',
      'name': 'Moudrý',
      'description': 'Trpělivý a moudrý rádce, který ti pomůže najít odpovědi na tvé otázky',
      'image': 'assets/images/menubarchar.png',
      'color': AppColors.deepBlue,
    },
    <String, dynamic>{
      'id': 'cheerful',
      'name': 'Veselý',
      'description': 'Plný energie a optimismu, vždy připravený tě rozveselit a povzbudit',
      'image': 'assets/images/menubarchar2.png',
      'color': AppColors.yellow,
    },
    <String, dynamic>{
      'id': 'calm',
      'name': 'Klidný',
      'description': 'Uklidňující přítel, který ti pomůže najít vnitřní mír a rovnováhu',
      'image': 'assets/images/menubarchar3.png',
      'color': AppColors.mintGreen,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width - (AppSpacing.lg * 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Tvoji AI Parťáci',
            style: text.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md + 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Vyber si svého ideálního společníka pro konverzaci',
            style: text.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            physics: const BouncingScrollPhysics(),
            itemCount: _personalities.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> personality = _personalities[index];
              return _PersonalityCard(
                personality: personality,
                cardWidth: cardWidth * 0.75, // 75% of screen width for better scrolling
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _PersonalityCard extends StatelessWidget {
  const _PersonalityCard({
    required this.personality,
    required this.cardWidth,
  });

  final Map<String, dynamic> personality;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color cardColor = personality['color'] as Color;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        // Navigate to chat with this personality
        // TODO: Implement navigation to chat
      },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Mascot image
              Center(
                child: Image.asset(
                  personality['image'] as String,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Name
              Text(
                personality['name'] as String,
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // Description
              Text(
                personality['description'] as String,
                style: text.bodySmall?.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

