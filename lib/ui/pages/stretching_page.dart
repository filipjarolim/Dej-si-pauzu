import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/statistics_service.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';

enum StretchType {
  neck('Krk', 'Uvolnění krčních svalů', 2),
  shoulders('Ramena', 'Protahování ramen a horní části zad', 3),
  back('Záda', 'Uvolnění zad a páteře', 4),
  fullBody('Celé tělo', 'Komplexní protažení', 5);

  const StretchType(this.name, this.description, this.duration);
  final String name;
  final String description;
  final int duration; // in minutes
}

class StretchingPage extends StatefulWidget {
  const StretchingPage({super.key});

  @override
  State<StretchingPage> createState() => _StretchingPageState();
}

class _StretchingPageState extends State<StretchingPage> with TickerProviderStateMixin {
  StretchType _selectedType = StretchType.neck;
  bool _isActive = false;
  bool _isPaused = false;
  bool _showCountdown = false;
  int _countdownValue = 3;
  int _currentMinute = 0;
  int _currentSecond = 0;
  DateTime? _sessionStartTime;
  Duration _elapsedTime = Duration.zero;
  Timer? _sessionTimer;
  Timer? _countdownTimer;

  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late AnimationController _entranceController;

  final StatisticsService _statsService = StatisticsService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    _entranceController.dispose();
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _showCountdown = true;
      _countdownValue = 3;
      _isPaused = false;
      _currentMinute = 0;
      _currentSecond = 0;
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
          _sessionStartTime = DateTime.now();
        });
        HapticFeedback.heavyImpact();
        _startStretchingTimer();
      }
    });
  }

  void _startStretchingTimer() {
    _sessionTimer?.cancel();
    final int totalSeconds = _selectedType.duration * 60;
    int elapsed = 0;

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted || !_isActive || _isPaused) {
        return;
      }

      elapsed++;
      setState(() {
        _elapsedTime = Duration(seconds: elapsed);
        _currentMinute = elapsed ~/ 60;
        _currentSecond = elapsed % 60;
      });

      if (elapsed >= totalSeconds) {
        timer.cancel();
        _completeSession();
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    HapticFeedback.mediumImpact();
  }

  void _stopSession() {
    setState(() {
      _isActive = false;
      _isPaused = false;
      _showCountdown = false;
      _currentMinute = 0;
      _currentSecond = 0;
      _elapsedTime = Duration.zero;
    });
    _sessionTimer?.cancel();
    _countdownTimer?.cancel();
    HapticFeedback.lightImpact();
  }

  void _completeSession() async {
    _stopSession();
    HapticFeedback.heavyImpact();

    if (_sessionStartTime != null) {
      final DateTime now = DateTime.now();
      final Duration sessionDuration = now.difference(_sessionStartTime!);
      final int minutes = sessionDuration.inMinutes;
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[AppColors.mintGreen, AppColors.lightGreen],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.white,
                    size: 60,
                  ),
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
                  'Dokončil jsi protahování',
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
                    color: AppColors.mintGreen.withOpacity(0.2),
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
                      backgroundColor: AppColors.mintGreen,
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
          ),
        );
      },
    );
  }

  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    if (_showCountdown) {
      return Scaffold(
        backgroundColor: AppColors.mintGreen.withOpacity(0.3),
        body: _buildCountdownScreen(context, text),
      );
    }

    if (_isActive) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildActiveSession(context, text),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mintGreen.withOpacity(0.2),
      body: Stack(
        children: <Widget>[
          Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              AppColors.mintGreen.withOpacity(0.4),
              AppColors.mintGreen.withOpacity(0.2),
              AppColors.white,
            ],
            stops: const <double>[0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: _buildSelectionScreen(context, text),
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

  Widget _buildCountdownScreen(BuildContext context, TextTheme text) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.mintGreen.withOpacity(0.4),
            AppColors.mintGreen.withOpacity(0.2),
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
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[AppColors.mintGreen, AppColors.lightGreen],
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.mintGreen.withOpacity(0.4),
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

  Widget _buildSelectionScreen(BuildContext context, TextTheme text) {
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
                            color: AppColors.mintGreen,
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            size: 56,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Protahování',
                          style: text.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Vyber typ protahování',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Typ protahování',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                        border: Border.all(
                          color: AppColors.mintGreen.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          ...StretchType.values.asMap().entries.map((MapEntry<int, StretchType> entry) {
                            final int index = entry.key;
                            final StretchType type = entry.value;
                            final bool isSelected = _selectedType == type;
                            final bool isLast = index == StretchType.values.length - 1;
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
                                    _AnimatedStretchItem(
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
                    Opacity(
                      opacity: Curves.easeOut.transform((_entranceController.value - 0.4).clamp(0.0, 1.0)),
                      child: Transform.translate(
                        offset: Offset(0, (1.0 - (_entranceController.value - 0.4).clamp(0.0, 1.0)) * 20),
                        child: _AnimatedStartButton(
                          label: 'Začít',
                          color: AppColors.mintGreen,
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

  Widget _buildActiveSession(BuildContext context, TextTheme text) {
    final int totalSeconds = _selectedType.duration * 60;
    final int remainingSeconds = totalSeconds - _elapsedTime.inSeconds;
    final int remainingMinutes = remainingSeconds ~/ 60;
    final int remainingSecs = remainingSeconds % 60;
    final double progress = _elapsedTime.inSeconds / totalSeconds;

    return Stack(
      children: <Widget>[
        // Unified gradient background (same as countdown)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AppColors.mintGreen.withOpacity(0.4),
                AppColors.mintGreen.withOpacity(0.2),
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
                              _formatTime(remainingMinutes, remainingSecs),
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
                        value: progress,
                        backgroundColor: AppColors.gray200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.mintGreen,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              // Main circle with timer
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (BuildContext context, Widget? child) {
                      final double pulseScale = 1.0 + (_pulseController.value * 0.1);

                      return Transform.scale(
                        scale: pulseScale,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mintGreen,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (_isPaused)
                                const Icon(
                                  Icons.pause_rounded,
                                  color: AppColors.white,
                                  size: 48,
                                )
                              else
                                const Icon(
                                  Icons.fitness_center_rounded,
                                  color: AppColors.white,
                                  size: 56,
                                ),
                              if (!_isPaused) ...[
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  _formatTime(remainingMinutes, remainingSecs),
                                  style: text.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                    fontSize: 32,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Bottom controls
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
                              side: const BorderSide(
                                color: AppColors.mintGreen,
                                width: 2,
                              ),
                              foregroundColor: AppColors.mintGreen,
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
                              backgroundColor: AppColors.mintGreen,
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
                title: 'O protahování',
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
        title: const Text('O protahování'),
        content: const Text(
          'Pravidelné protahování pomáhá uvolnit svaly, zlepšit flexibilitu a předcházet zraněním. '
          'Jemné protahovací cviky jsou ideální pro relaxaci během dne.',
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
          '• Vyber typ protahování\n'
          '• Klikni na "Začít"\n'
          '• Sleduj čas na obrazovce\n'
          '• Můžeš pozastavit nebo ukončit kdykoliv\n'
          '• Dýchej přirozeně během cvičení',
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

class _AnimatedStretchItem extends StatefulWidget {
  const _AnimatedStretchItem({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final StretchType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AnimatedStretchItem> createState() => _AnimatedStretchItemState();
}

class _AnimatedStretchItemState extends State<_AnimatedStretchItem> with SingleTickerProviderStateMixin {
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
                      ? AppColors.mintGreen.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: widget.isSelected
                      ? Border.all(
                          color: AppColors.mintGreen.withOpacity(0.3),
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
                            ? AppColors.mintGreen
                            : AppColors.gray200,
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
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
                              color: widget.isSelected ? AppColors.mintGreen : AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.type.description,
                            style: text.bodySmall?.copyWith(
                              color: widget.isSelected ? AppColors.mintGreen.withOpacity(0.8) : AppColors.gray700,
                              fontSize: 11,
                              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${widget.type.duration} min',
                      style: text.bodySmall?.copyWith(
                        color: AppColors.gray600,
                        fontSize: 11,
                      ),
                    ),
                    if (widget.isSelected) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.mintGreen,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 14,
                        ),
                      ),
                    ],
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

class _AnimatedStartButton extends StatefulWidget {
  const _AnimatedStartButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  State<_AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<_AnimatedStartButton> with SingleTickerProviderStateMixin {
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
    
    await _pressController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    
    if (mounted) {
      widget.onPressed();
    }
    
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
                  backgroundColor: widget.color,
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

