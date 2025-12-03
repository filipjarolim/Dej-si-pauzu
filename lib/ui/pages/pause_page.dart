import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

enum BreathingType {
  deep('Hluboké dýchání', '4 sekundy nádech, 4 sekundy výdech', 4, 4, 0),
  box('Box dýchání', '4-4-4-4 sekundy', 4, 4, 4),
  fourSevenEight('4-7-8 technika', '4 nádech, 7 zadržení, 8 výdech', 4, 7, 8),
  calm('Klidné dýchání', '6 sekund nádech, 6 sekund výdech', 6, 6, 0);

  const BreathingType(this.name, this.description, this.inhale, this.hold, this.exhale);
  final String name;
  final String description;
  final int inhale;
  final int hold;
  final int exhale;
}

class PausePage extends StatefulWidget {
  const PausePage({super.key});

  @override
  State<PausePage> createState() => _PausePageState();
}

class _PausePageState extends State<PausePage> with TickerProviderStateMixin {
  BreathingType _selectedType = BreathingType.deep;
  bool _isActive = false;
  int _currentPhase = 0; // 0: inhale, 1: hold, 2: exhale
  double _progress = 0.0;
  int _cyclesCompleted = 0;
  int _totalCycles = 5;

  late AnimationController _breathController;
  late AnimationController _pulseController;
  Timer? _breathTimer;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    _breathTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isActive = true;
      _currentPhase = 0;
      _progress = 0.0;
      _cyclesCompleted = 0;
    });
    HapticFeedback.mediumImpact();
    _startBreathingCycle();
  }

  void _stopSession() {
    setState(() {
      _isActive = false;
      _currentPhase = 0;
      _progress = 0.0;
    });
    _breathTimer?.cancel();
    _breathController.stop();
    _breathController.reset();
    HapticFeedback.lightImpact();
  }

  void _startBreathingCycle() {
    if (!_isActive) return;

    final BreathingType type = _selectedType;
    int duration = type.inhale;
    String phaseName = 'Nadechni se';

    if (_currentPhase == 0) {
      // Inhale
      duration = type.inhale;
      phaseName = 'Nadechni se';
      _breathController.forward();
    } else if (_currentPhase == 1 && type.hold > 0) {
      // Hold
      duration = type.hold;
      phaseName = 'Zadrž dech';
    } else {
      // Exhale
      duration = type.exhale;
      phaseName = 'Vydechni';
      _breathController.reverse();
    }

    final int totalDuration = duration;
    int elapsed = 0;

    _breathTimer?.cancel();
    _breathTimer = Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
      if (!_isActive) {
        timer.cancel();
        return;
      }

      elapsed += 50;
      final double newProgress = elapsed / (totalDuration * 1000);

      setState(() {
        _progress = newProgress.clamp(0.0, 1.0);
      });

      if (elapsed >= totalDuration * 1000) {
        timer.cancel();
        HapticFeedback.selectionClick();

        // Move to next phase
        setState(() {
          _currentPhase++;
          _progress = 0.0;
        });

        final BreathingType currentType = _selectedType;
        if (_currentPhase == 1 && currentType.hold == 0) {
          _currentPhase = 2; // Skip hold if not needed
        }

        if (_currentPhase > 2 || (_currentPhase == 2 && currentType.hold == 0 && _currentPhase == 1)) {
          // Cycle complete
          setState(() {
            _cyclesCompleted++;
            _currentPhase = 0;
            _progress = 0.0;
          });

          if (_cyclesCompleted >= _totalCycles) {
            _completeSession();
            return;
          }
        }

        _startBreathingCycle();
      }
    });
  }

  void _completeSession() {
    _stopSession();
    HapticFeedback.heavyImpact();
    // Show completion dialog or animation
  }

  String get _currentPhaseText {
    if (!_isActive) return 'Připraven';
    final BreathingType type = _selectedType;
    if (_currentPhase == 0) return 'Nadechni se';
    if (_currentPhase == 1 && type.hold > 0) return 'Zadrž dech';
    return 'Vydechni';
  }

  int get _currentPhaseDuration {
    final BreathingType type = _selectedType;
    if (_currentPhase == 0) return type.inhale;
    if (_currentPhase == 1) return type.hold;
    return type.exhale;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    // Use different scaffold for active session (full-screen, no padding)
    if (_isActive) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: _buildActiveSession(context, text, cs),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Pauza'),
        elevation: 0,
      ),
      bottomBar: null, // Navbar provided by ShellRoute
      body: _buildSelectionScreen(context, text, cs),
    );
  }

  Widget _buildSelectionScreen(BuildContext context, TextTheme text, ColorScheme cs) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: AppSpacing.xl),
          // Clean hero section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: <Widget>[
                RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (BuildContext context, Widget? child) {
                      final double scale = 1.0 + (_pulseController.value * 0.02);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.08),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.15),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.self_improvement_rounded,
                            size: 64,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Dýchací cvičení',
                  style: text.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Vyber typ a začni cvičení',
                  style: text.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Breathing type selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Typ dýchání',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...BreathingType.values.map((BreathingType type) {
                  final bool isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _BreathingTypeCard(
                      type: type,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedType = type);
                        HapticFeedback.selectionClick();
                      },
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
                // Start button
                _StartButton(
                  label: 'Začít',
                  onPressed: _startSession,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession(BuildContext context, TextTheme text, ColorScheme cs) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          // Clean header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _stopSession,
                  tooltip: 'Zavřít',
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${_cyclesCompleted + 1} / $_totalCycles cyklů',
                        style: text.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _cyclesCompleted / _totalCycles,
                          backgroundColor: AppColors.gray200,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main breathing circle - cleaner design
          Expanded(
            child: Center(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _breathController,
                  builder: (BuildContext context, Widget? child) {
                    final double scale = 0.75 + (_breathController.value * 0.25);

                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Single subtle ring
                        Transform.scale(
                          scale: scale * 1.15,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        // Main circle
                        Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                // Progress ring
                                CustomPaint(
                                  size: const Size(200, 200),
                                  painter: _CircularProgressPainter(
                                    progress: _progress,
                                    color: AppColors.white,
                                  ),
                                ),
                                // Phase content
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      _currentPhaseText,
                                      style: text.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${_currentPhaseDuration}s',
                                      style: text.titleSmall?.copyWith(
                                        color: AppColors.white.withOpacity(0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // Bottom section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: <Widget>[
                Text(
                  _selectedType.name,
                  style: text.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _stopSession,
                    icon: const Icon(Icons.stop_rounded, size: 20),
                    label: const Text('Ukončit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      side: BorderSide(color: AppColors.gray300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
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
}

class _BreathingTypeCard extends StatelessWidget {
  const _BreathingTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final BreathingType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray300,
              width: isSelected ? 2 : DesignTokens.borderMedium,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : AppColors.gray100,
                ),
                child: Icon(
                  _getIconForType(type),
                  color: isSelected ? AppColors.white : AppColors.gray600,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      type.name,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.description,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.gray600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(BreathingType type) {
    switch (type) {
      case BreathingType.deep:
        return Icons.air_rounded;
      case BreathingType.box:
        return Icons.crop_square_rounded;
      case BreathingType.fourSevenEight:
        return Icons.waves_rounded;
      case BreathingType.calm:
        return Icons.spa_rounded;
    }
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}


class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2 - 3;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Background circle - subtle
    final Paint backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final Paint progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final Rect rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
