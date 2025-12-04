import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/statistics_service.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/frosted_app_bar.dart';

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
  bool _showHints = true;
  DateTime? _sessionStartTime;

  late AnimationController _breathController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  Timer? _breathTimer;
  
  final StatisticsService _statsService = StatisticsService();

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
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.8,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _breathTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isActive = true;
      _currentPhase = 0;
      _progress = 0.0;
      _cyclesCompleted = 0;
      _sessionStartTime = DateTime.now();
    });
    HapticFeedback.mediumImpact();
    _fadeController.forward();
    _scaleController.forward();
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
    _fadeController.reverse();
    _scaleController.reverse();
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

  void _completeSession() async {
    _stopSession();
    HapticFeedback.heavyImpact();
    
    // Calculate session duration and record statistics
    if (_sessionStartTime != null) {
      final Duration sessionDuration = DateTime.now().difference(_sessionStartTime!);
      final int minutes = sessionDuration.inMinutes;
      // Record at least 1 minute if session was less than a minute
      await _statsService.recordBreathingSession(minutes > 0 ? minutes : 1);
    }
    
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.skyBlue.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 50,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Výborně!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Dokončil jsi $_totalCycles cyklů dýchání',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                      ),
                    ),
                    child: const Text('Zavřít'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeCycleCount(int delta) {
    setState(() {
      _totalCycles = (_totalCycles + delta).clamp(1, 20);
    });
    HapticFeedback.selectionClick();
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

  String get _currentHint {
    if (!_isActive) return '';
    if (_currentPhase == 0) return 'Pomalu se nadechni nosem';
    if (_currentPhase == 1) return 'Zadrž dech a uvolni se';
    return 'Pomalu vydechni ústy';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    // Use different scaffold for active session (full-screen, no padding)
    if (_isActive) {
      return Scaffold(
        backgroundColor: AppColors.skyBlue.withOpacity(0.3),
        body: _buildActiveSession(context, text, cs),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.skyBlue.withOpacity(0.2),
      extendBodyBehindAppBar: true,
      appBar: FrostedAppBar(
        title: const Text('Pauza'),
        backgroundColor: AppColors.skyBlue,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.skyBlue.withOpacity(0.4),
              AppColors.skyBlue.withOpacity(0.2),
              AppColors.white,
            ],
            stops: const <double>[0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: _buildSelectionScreen(context, text, cs),
        ),
      ),
    );
  }

  Widget _buildSelectionScreen(BuildContext context, TextTheme text, ColorScheme cs) {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          const SizedBox(height: AppSpacing.xl),
          // Enhanced hero section with animated background
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Stack(
              children: <Widget>[
                // Animated wave background
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (BuildContext context, Widget? child) {
                      return CustomPaint(
                        painter: _WavePainter(
                          progress: _waveController.value,
                          color: AppColors.primary.withOpacity(0.05),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  children: <Widget>[
            RepaintBoundary(
              child: AnimatedBuilder(
                        animation: _pulseController,
                builder: (BuildContext context, Widget? child) {
                          final double scale = 1.0 + (_pulseController.value * 0.05);
                          final double opacity = 0.15 + (_pulseController.value * 0.1);
                          return Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              // Outer pulse ring
                              Transform.scale(
                                scale: scale * 1.3,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withOpacity(opacity * 0.5),
                                  ),
                                ),
                              ),
                              // Middle pulse ring
                              Transform.scale(
                                scale: scale * 1.15,
                    child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withOpacity(opacity * 0.7),
                                  ),
                                ),
                              ),
                              // Main circle
                              Container(
                                width: 140,
                                height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: <Color>[
                                      AppColors.primary,
                                      AppColors.skyBlue,
                                    ],
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.self_improvement_rounded,
                                  size: 64,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Dýchací cvičení',
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Vyber typ a začni cvičení',
                      style: text.bodyLarge?.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Cycle count selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                        ),
                      ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Počet cyklů',
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _changeCycleCount(-1),
                        color: AppColors.primary,
                        iconSize: 24,
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_totalCycles',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                      ),
                    ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _changeCycleCount(1),
                        color: AppColors.primary,
                        iconSize: 24,
                      ),
                    ],
                  ),
                ],
              ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
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
                    color: AppColors.primary,
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
                // Enhanced Start button with light text
                FadeTransition(
                  opacity: _fadeController,
                  child: ScaleTransition(
                    scale: _scaleController,
                    child: _StartButton(
                      label: 'Začít',
                      onPressed: _startSession,
                    ),
                  ),
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
          // Enhanced header with gradient
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  AppColors.white.withOpacity(0.9),
                  AppColors.skyBlue.withOpacity(0.3),
                ],
              ),
            ),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _stopSession,
                  tooltip: 'Zavřít',
                  color: AppColors.primary,
                ),
                Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                        '${_cyclesCompleted + 1} / $_totalCycles cyklů',
                        style: text.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _cyclesCompleted / _totalCycles,
                          backgroundColor: AppColors.gray200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main breathing circle with enhanced animations
          Expanded(
            child: Center(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: Listenable.merge(<Listenable>[_breathController, _pulseController]),
                  builder: (BuildContext context, Widget? child) {
                    final double scale = 0.7 + (_breathController.value * 0.3);
                    final double pulseScale = 1.0 + (_pulseController.value * 0.15);

                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Multiple animated rings for depth
                        for (int i = 0; i < 3; i++)
                          Transform.scale(
                            scale: (scale * (1.2 + i * 0.15)) * pulseScale,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.1 / (i + 1)),
                                  width: 2 - (i * 0.3),
                                ),
                              ),
                            ),
                          ),
                        // Main breathing circle with gradient
                        Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  AppColors.primary,
                                  AppColors.skyBlue,
                                ],
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
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
                      fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${_currentPhaseDuration}s',
                                      style: text.titleSmall?.copyWith(
                                        color: AppColors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
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
          // Bottom section with hints
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.skyBlue.withOpacity(0.2),
                  AppColors.white.withOpacity(0.9),
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                if (_showHints && _currentHint.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _currentHint,
                          style: text.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_showHints && _currentHint.isNotEmpty)
                  const SizedBox(height: AppSpacing.md),
                  Text(
                  _selectedType.name,
                  style: text.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
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
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      foregroundColor: AppColors.primary,
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: isSelected 
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[AppColors.primary, AppColors.skyBlue],
                        )
                      : null,
                  color: isSelected ? null : AppColors.gray100,
                ),
                child: Icon(
                  _getIconForType(type),
                  color: isSelected ? AppColors.white : AppColors.gray600,
                  size: 24,
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
                        color: isSelected ? AppColors.primary : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.description,
                      style: text.bodySmall?.copyWith(
                        color: isSelected ? AppColors.primary.withOpacity(0.8) : AppColors.gray600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
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
          foregroundColor: AppColors.white, // Light text
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.play_arrow_rounded, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: text.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.white, // Explicitly set light text
                fontSize: 16,
              ),
            ),
          ],
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
    final double radius = size.width / 2 - 4;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Background circle - subtle
    final Paint backgroundPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc with gradient effect
    if (progress > 0) {
      final Paint progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
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

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double waveLength = size.width / 2;
    final double waveHeight = 20;
    final Path path = Path();

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final double y = size.height / 2 +
          waveHeight *
              math.sin((x / waveLength + progress * 2 * math.pi) * 2 * math.pi);
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
