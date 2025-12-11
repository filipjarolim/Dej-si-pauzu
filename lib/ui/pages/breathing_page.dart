import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/statistics_service.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';

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

class BreathingPage extends StatefulWidget {
  const BreathingPage({super.key});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> with TickerProviderStateMixin {
  BreathingType _selectedType = BreathingType.deep;
  bool _isActive = false;
  bool _isPaused = false;
  bool _showCountdown = false;
  int _countdownValue = 3;
  int _currentPhase = 0; // 0: inhale, 1: hold, 2: exhale
  double _progress = 0.0;
  int _cyclesCompleted = 0;
  int _totalCycles = 5;
  final bool _showHints = true;
  DateTime? _sessionStartTime;
  Duration _elapsedTime = Duration.zero;
  Timer? _elapsedTimer;

  late AnimationController _breathController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _countdownController;
  late AnimationController _particleController;
  late AnimationController _entranceController;
  Timer? _breathTimer;
  Timer? _countdownTimer;
  
  final StatisticsService _statsService = StatisticsService();
  final List<_Particle> _particles = <_Particle>[];

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
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    
    // Initialize particles
    _initializeParticles();
  }
  
  void _initializeParticles() {
    _particles.clear();
    // Reduced particle count for cleaner look
    for (int i = 0; i < 5; i++) {
      _particles.add(_Particle());
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _countdownController.dispose();
    _particleController.dispose();
    _breathTimer?.cancel();
    _countdownTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _showCountdown = true;
      _countdownValue = 3;
      _isPaused = false;
      _elapsedTime = Duration.zero;
    });
    HapticFeedback.mediumImpact();
    _startCountdown();
  }
  
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownController.reset();
    _countdownController.forward();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _countdownValue--;
        _countdownController.reset();
        _countdownController.forward();
      });
      
      HapticFeedback.mediumImpact();
      
      if (_countdownValue <= 0) {
        timer.cancel();
        setState(() {
          _showCountdown = false;
          _isActive = true;
          _currentPhase = 0;
          _progress = 0.0;
          _cyclesCompleted = 0;
          _sessionStartTime = DateTime.now();
        });
        HapticFeedback.heavyImpact();
        _fadeController.forward();
        _scaleController.forward();
        _startElapsedTimer();
        _startBreathingCycle();
      }
    });
  }
  
  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted || !_isActive || _isPaused) {
        return;
      }
      setState(() {
        _elapsedTime = _elapsedTime + const Duration(seconds: 1);
      });
    });
  }
  
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    HapticFeedback.mediumImpact();
    
    if (_isPaused) {
      _breathController.stop();
      _breathTimer?.cancel();
      _elapsedTimer?.cancel();
    } else {
      _breathController.forward(from: _breathController.value);
      _startElapsedTimer();
      _startBreathingCycle();
    }
  }

  void _stopSession() {
    setState(() {
      _isActive = false;
      _isPaused = false;
      _showCountdown = false;
      _currentPhase = 0;
      _progress = 0.0;
      _elapsedTime = Duration.zero;
    });
    _breathTimer?.cancel();
    _countdownTimer?.cancel();
    _elapsedTimer?.cancel();
    _breathController.stop();
    _breathController.reset();
    _fadeController.reverse();
    _scaleController.reverse();
    HapticFeedback.lightImpact();
  }

  void _startBreathingCycle() {
    if (!_isActive || _isPaused) return;

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
      if (!_isActive || _isPaused) {
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
    final int minutes = _elapsedTime.inMinutes;
    final int seconds = _elapsedTime.inSeconds % 60;
    final String timeText = minutes > 0 
        ? '$minutes ${minutes == 1 ? 'minuta' : minutes < 5 ? 'minuty' : 'minut'}'
        : '$seconds ${seconds == 1 ? 'sekunda' : seconds < 5 ? 'sekundy' : 'sekund'}';
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: TickerMode(
            enabled: true,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2 + _pulseController.value * 0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Animated success icon
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (BuildContext context, double value, Widget? child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 100,
                              height: 100,
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
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.white,
                                size: 60,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Výborně!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Dokončil jsi $_totalCycles cyklů dýchání',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.skyBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Čas: $timeText',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Zavřít',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    // Show countdown overlay
    if (_showCountdown) {
      return Scaffold(
        backgroundColor: AppColors.skyBlue.withOpacity(0.3),
        body: _buildCountdownScreen(context, text, cs),
      );
    }

    // Use different scaffold for active session (full-screen, no padding)
    if (_isActive) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildActiveSession(context, text, cs),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.skyBlue.withOpacity(0.2),
      body: Stack(
        children: <Widget>[
          Container(
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
          // Floating back button
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.md,
            child: _FloatingActionButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () {
                HapticFeedback.lightImpact();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.pause);
                }
              },
            ),
          ),
          // Floating menu button
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            right: AppSpacing.md,
            child: _MenuButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showMenu(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionScreen(BuildContext context, TextTheme text, ColorScheme cs) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (BuildContext context, Widget? child) {
        final double heroOpacity = Curves.easeOut.transform(_entranceController.value);
        final double heroOffset = (1.0 - _entranceController.value) * 30;
        
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).padding.top + AppSpacing.xl + 60),
              // Hero section with entrance animation
              Opacity(
                opacity: heroOpacity,
                child: Transform.translate(
                  offset: Offset(0, heroOffset),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Icon(
                            Icons.self_improvement_rounded,
                            size: 56,
                            color: AppColors.white,
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
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Cycle count selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
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
                    // Improved selection with better visibility
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          ...BreathingType.values.asMap().entries.map((MapEntry<int, BreathingType> entry) {
                            final int index = entry.key;
                            final BreathingType type = entry.value;
                            final bool isSelected = _selectedType == type;
                            final bool isLast = index == BreathingType.values.length - 1;
                            final double delay = index * 0.1;
                            final double itemAnimation = (_entranceController.value - delay).clamp(0.0, 1.0);
                            final double itemOpacity = Curves.easeOut.transform(itemAnimation);
                            final double itemOffset = (1.0 - itemAnimation) * 20;
                            
                            return Opacity(
                              opacity: itemOpacity,
                              child: Transform.translate(
                                offset: Offset(0, itemOffset),
                                child: Column(
                                  children: <Widget>[
                                    _AnimatedSelectionItem(
                                      type: type,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() => _selectedType = type);
                                        HapticFeedback.selectionClick();
                                      },
                                    ),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppColors.gray200,
                                        indent: AppSpacing.md + 40,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Start button with entrance animation
                    Opacity(
                      opacity: Curves.easeOut.transform((_entranceController.value - 0.4).clamp(0.0, 1.0)),
                      child: Transform.translate(
                        offset: Offset(0, (1.0 - (_entranceController.value - 0.4).clamp(0.0, 1.0)) * 20),
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
      },
    );
  }

  Widget _buildCountdownScreen(BuildContext context, TextTheme text, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.skyBlue.withOpacity(0.4),
            AppColors.skyBlue.withOpacity(0.2),
            AppColors.white,
          ],
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _countdownController,
          builder: (BuildContext context, Widget? child) {
            final double scale = _countdownValue > 0 
                ? 1.0 + (_countdownController.value * 0.3)
                : 1.0;
            final double opacity = _countdownValue > 0 
                ? 1.0 - (_countdownController.value * 0.3)
                : 1.0;
            
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
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
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _countdownValue > 0 ? '$_countdownValue' : 'Začínáme!',
                      style: text.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        fontSize: _countdownValue > 0 ? 72 : 32,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveSession(BuildContext context, TextTheme text, ColorScheme cs) {
    final String timeText = _formatDuration(_elapsedTime);
    
    return Stack(
      children: <Widget>[
        // Unified gradient background (same as countdown)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.skyBlue.withOpacity(0.4),
                AppColors.skyBlue.withOpacity(0.2),
                AppColors.white,
              ],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: <Widget>[
              // Top bar with back and menu buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _FloatingActionButton(
                      icon: Icons.close_rounded,
                      onPressed: _stopSession,
                    ),
                    _FloatingActionButton(
                      icon: Icons.more_vert_rounded,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _showMenu(context);
                      },
                    ),
                  ],
                ),
              ),
              // Title and progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: <Widget>[
                    Text(
                      _selectedType.name,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${_cyclesCompleted + 1} / $_totalCycles cyklů',
                          style: text.bodyMedium?.copyWith(
                            color: AppColors.gray700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gray400,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: AppColors.gray700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeText,
                              style: text.bodyMedium?.copyWith(
                                color: AppColors.gray700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _cyclesCompleted / _totalCycles,
                        backgroundColor: AppColors.gray200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
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
                      animation: Listenable.merge(<Listenable>[
                        _breathController, 
                        _pulseController,
                        _particleController,
                      ]),
                      builder: (BuildContext context, Widget? child) {
                        final double scale = _isPaused 
                            ? 0.85
                            : 0.7 + (_breathController.value * 0.3);
                        final double pulseScale = 1.0 + (_pulseController.value * 0.15);
                        final Color circleColor = _currentPhase == 0
                            ? AppColors.primary
                            : _currentPhase == 1
                                ? AppColors.skyBlue
                                : AppColors.mintGreen;

                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            // Single subtle ring for depth
                            TweenAnimationBuilder<Color?>(
                              tween: ColorTween(
                                begin: AppColors.primary,
                                end: circleColor,
                              ),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeInOut,
                              builder: (BuildContext context, Color? color, Widget? child) {
                                final Color effectiveColor = color ?? AppColors.primary;
                                return Transform.scale(
                                  scale: scale * 1.15 * pulseScale,
                                  child: Container(
                                    width: 240,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: effectiveColor.withOpacity(0.1),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Main breathing circle - solid color, no gradient
                            Transform.scale(
                              scale: scale,
                              child: TweenAnimationBuilder<Color?>(
                                tween: ColorTween(
                                  begin: AppColors.primary,
                                  end: circleColor,
                                ),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                builder: (BuildContext context, Color? color, Widget? child) {
                                  final Color effectiveColor = color ?? AppColors.primary;
                                  return Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: effectiveColor,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        // Progress ring
                                        CustomPaint(
                                          size: const Size(220, 220),
                                          painter: _CircularProgressPainter(
                                            progress: _progress,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        // Phase content
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            if (_isPaused)
                                              Icon(
                                                Icons.pause_rounded,
                                                color: AppColors.white,
                                                size: 48,
                                              )
                                            else
                                              Text(
                                                _currentPhaseText,
                                                style: text.headlineMedium?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.white,
                                                  fontSize: 28,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            if (!_isPaused) ...[
                                              const SizedBox(height: AppSpacing.xs),
                                              Text(
                                                '${_currentPhaseDuration}s',
                                                style: text.titleLarge?.copyWith(
                                                  color: AppColors.white.withOpacity(0.95),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Bottom section with hints and controls
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (_showHints && _currentHint.isNotEmpty && !_isPaused)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.lightbulb_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(
                              child: Text(
                                _currentHint,
                                style: text.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_showHints && _currentHint.isNotEmpty && !_isPaused)
                      const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _togglePause,
                            icon: Icon(
                              _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              size: 20,
                            ),
                            label: Text(_isPaused ? 'Pokračovat' : 'Pozastavit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              side: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _stopSession,
                            icon: const Icon(Icons.stop_rounded, size: 20),
                            label: const Text('Ukončit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '0:${seconds.toString().padLeft(2, '0')}';
  }
}

class _BreathingTypeCard extends StatefulWidget {
  const _BreathingTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final BreathingType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_BreathingTypeCard> createState() => _BreathingTypeCardState();
}

class _BreathingTypeCardState extends State<_BreathingTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _previewController;

  @override
  void initState() {
    super.initState();
    final int totalDuration = widget.type.inhale + 
        (widget.type.hold > 0 ? widget.type.hold : 0) + 
        widget.type.exhale;
    _previewController = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalDuration),
    )..repeat();
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            border: Border.all(
              color: widget.isSelected 
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              width: widget.isSelected ? 2.5 : 1.5,
            ),
            boxShadow: widget.isSelected
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
                  gradient: widget.isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[AppColors.primary, AppColors.skyBlue],
                        )
                      : null,
                  color: widget.isSelected ? null : AppColors.gray100,
                ),
                child: Icon(
                  _getIconForType(widget.type),
                  color: widget.isSelected ? AppColors.white : AppColors.gray600,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.type.name,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isSelected ? AppColors.primary : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.type.description,
                      style: text.bodySmall?.copyWith(
                        color: widget.isSelected 
                            ? AppColors.primary.withOpacity(0.8) 
                            : AppColors.gray600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Breathing pattern preview
                    AnimatedBuilder(
                      animation: _previewController,
                      builder: (BuildContext context, Widget? child) {
                        return _buildPatternPreview();
                      },
                    ),
                  ],
                ),
              ),
              if (widget.isSelected)
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

  Widget _buildPatternPreview() {
    final double progress = _previewController.value;
    final int totalDuration = widget.type.inhale + 
        (widget.type.hold > 0 ? widget.type.hold : 0) + 
        widget.type.exhale;
    final double inhaleEnd = widget.type.inhale / totalDuration;
    final double holdEnd = widget.type.hold > 0
        ? (widget.type.inhale + widget.type.hold) / totalDuration
        : inhaleEnd;
    
    double currentScale;
    Color currentColor;
    
    if (progress < inhaleEnd) {
      // Inhale phase
      final double phaseProgress = progress / inhaleEnd;
      currentScale = 0.6 + (phaseProgress * 0.4);
      currentColor = AppColors.primary;
    } else if (progress < holdEnd) {
      // Hold phase
      currentScale = 1.0;
      currentColor = AppColors.skyBlue;
    } else {
      // Exhale phase
      final double phaseProgress = (progress - holdEnd) / (1.0 - holdEnd);
      currentScale = 1.0 - (phaseProgress * 0.4);
      currentColor = AppColors.mintGreen;
    }

    return SizedBox(
      height: 4,
      child: Row(
        children: <Widget>[
          Container(
            width: 40 * currentScale,
            height: 4,
            decoration: BoxDecoration(
              color: currentColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
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

class _StartButton extends StatefulWidget {
  const _StartButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _shakeAnimation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: -6.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 1.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -6.0, end: 6.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 6.0, end: -3.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -3.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 1.0,
        ),
      ],
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    HapticFeedback.mediumImpact();
    
    // Quick press animation
    await _pressController.forward();
    
    // Small delay then execute
    await Future<void>.delayed(const Duration(milliseconds: 80));
    
    if (mounted) {
      widget.onPressed();
    }
    
    // Reset animation
    _pressController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    
    return AnimatedBuilder(
      animation: _pressController,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
                onPressed: _handleTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
                  elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.play_arrow_rounded, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(
                      widget.label,
              style: text.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                        color: AppColors.white,
                fontSize: 16,
              ),
            ),
          ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedSelectionItem extends StatefulWidget {
  const _AnimatedSelectionItem({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final BreathingType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AnimatedSelectionItem> createState() => _AnimatedSelectionItemState();
}

class _AnimatedSelectionItemState extends State<_AnimatedSelectionItem> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    _pressController.forward().then((_) {
      _pressController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    
    return AnimatedBuilder(
      animation: _pressController,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: widget.isSelected 
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: widget.isSelected
                      ? Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSelected
                            ? AppColors.primary
                            : AppColors.gray200,
                      ),
                      child: Icon(
                        _getIconForType(widget.type),
                        color: widget.isSelected ? AppColors.white : AppColors.gray600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.type.name,
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: widget.isSelected ? AppColors.primary : AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.type.description,
                            style: text.bodySmall?.copyWith(
                              color: widget.isSelected ? AppColors.primary.withOpacity(0.8) : AppColors.gray700,
                              fontSize: 11,
                              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isSelected)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

class _Particle {
  _Particle() {
    final math.Random random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = 2 + random.nextDouble() * 4;
    speed = 0.3 + random.nextDouble() * 0.5;
    opacity = 0.2 + random.nextDouble() * 0.4;
    angle = random.nextDouble() * 2 * math.pi;
  }

  late final double x;
  late final double y;
  late final double size;
  late final double speed;
  late final double opacity;
  late final double angle;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.breathProgress,
    required this.isInhaling,
  });

  final List<_Particle> particles;
  final double progress;
  final double breathProgress;
  final bool isInhaling;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill;

    for (final _Particle particle in particles) {
      // Update particle position based on breathing
      final double breathInfluence = isInhaling 
          ? breathProgress * 0.5
          : (1.0 - breathProgress) * 0.5;
      
      final double currentX = (particle.x + progress * particle.speed * 0.1) % 1.0;
      final double currentY = (particle.y + 
          math.sin(progress * 2 * math.pi + particle.angle) * 0.02 +
          breathInfluence * 0.1) % 1.0;

      final double xPos = currentX * size.width;
      final double yPos = currentY * size.height;
      
      // Adjust opacity based on breathing
      final double currentOpacity = particle.opacity * 
          (0.5 + breathProgress * 0.5);

      paint.color = AppColors.primary.withOpacity(currentOpacity * 0.6);
      
      canvas.drawCircle(
        Offset(xPos, yPos),
        particle.size * (1.0 + breathInfluence),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.breathProgress != breathProgress ||
        oldDelegate.isInhaling != isInhaling;
  }
}

class _FloatingActionButton extends StatelessWidget {
  const _FloatingActionButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.more_vert_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

void _showMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.radiusXl),
            topRight: Radius.circular(DesignTokens.radiusXl),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _MenuTile(
                icon: Icons.info_outline_rounded,
                title: 'O cvičení',
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                title: 'Nastavení',
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                  context.push(AppRoutes.settings);
                },
              ),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Nápověda',
                onTap: () {
                  Navigator.pop(context);
                  _showHelpDialog(context);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      );
    },
  );
}

void _showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: const Text('O dýchacích cvičeních'),
        content: const Text(
          'Dýchací cvičení pomáhají uklidnit mysl a tělo. '
          'Pravidelné cvičení může zlepšit koncentraci, snížit stres a zlepšit celkovou pohodu.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Zavřít'),
          ),
        ],
      );
    },
  );
}

void _showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: const Text('Nápověda'),
        content: const Text(
          '• Vyber typ dýchání\n'
          '• Nastav počet cyklů\n'
          '• Klikni na "Začít"\n'
          '• Sleduj instrukce na obrazovce\n'
          '• Můžeš pozastavit nebo ukončit kdykoliv',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Zavřít'),
          ),
        ],
      );
    },
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}
