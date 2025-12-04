import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../foundations/motion.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> with TickerProviderStateMixin {
  int? _selectedMood;
  late AnimationController _waveController;
  late AnimationController _rippleController;
  final List<AnimationController> _moodControllers = <AnimationController>[];
  final List<AnimationController> _bounceControllers = <AnimationController>[];

  final List<Map<String, dynamic>> _moods = <Map<String, dynamic>>[
    <String, dynamic>{
      'icon': Icons.sentiment_dissatisfied,
      'label': 'Nedobře',
      'subtitle': 'Mohlo by být líp',
      'color': const Color(0xFFF97316),
      'emoji': '😕',
      'description': 'Není to ideální',
    },
    <String, dynamic>{
      'icon': Icons.sentiment_neutral,
      'label': 'OK',
      'subtitle': 'V pohodě',
      'color': const Color(0xFFFBBF24),
      'emoji': '😐',
      'description': 'Nic zvláštního',
    },
    <String, dynamic>{
      'icon': Icons.sentiment_satisfied,
      'label': 'Dobře',
      'subtitle': 'Příjemný den',
      'color': const Color(0xFF34D399),
      'emoji': '🙂',
      'description': 'Cítím se dobře',
    },
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create animation controllers for each mood
    for (int i = 0; i < _moods.length; i++) {
      final AnimationController controller = AnimationController(
        vsync: this,
        duration: AppMotion.medium,
      );
      final AnimationController bounceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _moodControllers.add(controller);
      _bounceControllers.add(bounceController);
      // Stagger the initial animations
      Future<void>.delayed(Duration(milliseconds: 50 * i), () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _rippleController.dispose();
    for (final AnimationController controller in _moodControllers) {
      controller.dispose();
    }
    for (final AnimationController controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectMood(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedMood = index);
    _bounceControllers[index].forward(from: 0.0).then((_) {
      _bounceControllers[index].reverse();
    });
    _rippleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Size screenSize = MediaQuery.of(context).size;

    return AppScaffold(
      appBar: AppBar(title: const Text('Nálada')),
      body: Stack(
        children: <Widget>[
          // Animated background wave
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  painter: _WavePainter(
                    progress: _waveController.value,
                    color: _selectedMood != null
                        ? (_moods[_selectedMood!]['color'] as Color).withOpacity(0.03)
                        : AppColors.skyBlue.withOpacity(0.02),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
                const SizedBox(height: AppSpacing.xl),
                // Header section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                        'Jak se cítíš?',
                        style: text.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          fontSize: 32,
                    ),
                  ),
                      const SizedBox(height: AppSpacing.sm),
                  Text(
                        'Zaznamenej svou náladu a sleduj, jak se mění v čase.',
                    style: text.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl + 8),
                // Mood selector - centered row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  _moods.length,
                  (int index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < _moods.length - 1 ? AppSpacing.md : 0,
                          ),
                          child: _buildMoodCard(index, text, cs, screenSize),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Selected mood details
                if (_selectedMood != null) ...[
                  AnimatedSwitcher(
                    duration: AppMotion.medium,
                    child: _buildMoodDetails(_selectedMood!, text, cs),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                // Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: AnimatedOpacity(
                    opacity: _selectedMood != null ? 1.0 : 0.4,
                    duration: AppMotion.fast,
                    child: AppButton(
                      label: _selectedMood != null
                          ? 'Zaznamenat náladu'
                          : 'Vyber svou náladu',
                      onPressed: _selectedMood != null
                          ? () {
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nálada "${_moods[_selectedMood!]['label']}" byla zaznamenána'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: _moods[_selectedMood!]['color'] as Color,
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(int index, TextTheme text, ColorScheme cs, Size screenSize) {
    final Map<String, dynamic> mood = _moods[index];
    final bool isSelected = _selectedMood == index;
    final AnimationController controller = _moodControllers[index];
    final AnimationController bounceController = _bounceControllers[index];

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[controller, bounceController]),
      builder: (BuildContext context, Widget? child) {
        final double scale = (0.9 + (controller.value * 0.1)) * (1.0 + (bounceController.value * 0.1));
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: 0.6 + (controller.value * 0.4),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _selectMood(index),
        child: Container(
          width: 100,
                        decoration: BoxDecoration(
            color: isSelected ? mood['color'] as Color : AppColors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                          border: Border.all(
                            color: isSelected
                                ? mood['color'] as Color
                                : AppColors.gray200,
              width: isSelected ? 2.5 : DesignTokens.borderMedium,
                          ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Emoji
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withOpacity(0.2)
                      : AppColors.gray50,
                  shape: BoxShape.circle,
                                  ),
                child: Center(
                  child: Text(
                    mood['emoji'] as String,
                    style: const TextStyle(fontSize: 36),
                        ),
                      ),
                        ),
              const SizedBox(height: AppSpacing.sm),
              // Label
              Text(
                mood['label'] as String,
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.white : cs.onSurface,
              ),
                textAlign: TextAlign.center,
            ),
              const SizedBox(height: 2),
              // Subtitle
              Text(
                mood['subtitle'] as String,
                style: text.bodySmall?.copyWith(
                  color: isSelected
                      ? AppColors.white.withOpacity(0.9)
                      : cs.onSurfaceVariant,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodDetails(int index, TextTheme text, ColorScheme cs) {
    final Map<String, dynamic> mood = _moods[index];
    final Color moodColor = mood['color'] as Color;

    return Container(
      key: ValueKey<int>(index),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: moodColor.withOpacity(0.2),
          width: DesignTokens.borderMedium,
        ),
      ),
      child: Row(
        children: <Widget>[
          // Large emoji
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: moodColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                mood['emoji'] as String,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mood['label'] as String,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: moodColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mood['description'] as String,
                  style: text.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
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

class _WavePainter extends CustomPainter {
  _WavePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double waveHeight = 20;
    final double waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x++) {
      final double y = size.height * 0.7 +
          waveHeight *
              math.sin((x / waveLength + progress * 2 * math.pi) * math.pi);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
