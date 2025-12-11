import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../core/constants/app_routes.dart';

import '../navigation/transitions.dart';
import '../navigation/transitions.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/custom_refresh_indicator.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../foundations/spacing.dart';


import '../../core/services/app_update_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    super.initState();
    // Check for in-app updates after frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppUpdateService.checkForUpdate();
      }
    });
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(AppConstants.refreshDelay);
    if (!mounted) return;
    setState(() {});
  }


  Widget _heroCard(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withOpacity(0.25), // Softer Indigo shadow
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5C6BC0), // Indigo 400 - Calmer
            Color(0xFF3949AB), // Indigo 600
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.navigateToPause(),
          borderRadius: BorderRadius.circular(32.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded, color: AppColors.yellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Doporučeno',
                            style: text.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Dej si 5 minut pauzu',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800, // Slightly less heavy than w900
                    color: Colors.white,
                    height: 1.1,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Doplnit energii a zklidnit mysl.',
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                // Progress stats embedded in card
                Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 0.68),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOutCubic, // Less bouncy, more smooth
                        builder: (context, value, _) => Stack(
                          fit: StackFit.expand,
                          children: [
                             CircularProgressIndicator(
                              value: value,
                              strokeWidth: 6,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              color: AppColors.mintGreen, // Fresh Mint feels calmer than Yellow
                              strokeCap: StrokeCap.round,
                            ),
                            Center(
                              child: Text(
                                '${(value * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dnešní cíl',
                            style: text.labelSmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Skvělá práce!',
                            style: text.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return AppScaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Crisp clean white/grey
      body: CustomRefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64), // Top spacing
              
              // 1. Custom Greeting Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onLongPress: () {
                           // DEBUG ONLY
                           HapticFeedback.heavyImpact();
                           AppUpdateService.debugSimulateUpdate();
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('DEBUG: Update UI Simulated')),
                           );
                        },
                        child: Text(
                          'Ahoj,',
                          style: text.bodyLarge?.copyWith(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Filipe 👋',
                        style: text.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                          height: 1.1,
                          fontSize: 34,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => context.navigateToProfile(),
                      borderRadius: BorderRadius.circular(50),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.gray100, // Neutral background
                        child: const Icon(Icons.person_rounded, color: AppColors.gray700),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // UPDATE BANNER
              ValueListenableBuilder<bool>(
                valueListenable: AppUpdateService.updateAvailable,
                builder: (context, available, _) {
                  if (!available) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary, // Solid color is cleaner
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                           BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6)
                           )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => AppUpdateService.triggerUpdateFlow(),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.system_update_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nová verze k dispozici',
                                        style: text.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Stáhni si nejnovější funkce',
                                        style: text.bodySmall?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. Bento Grid Layout
              SizedBox(
                height: 340, 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LEFT COLUMN: HERO (60%)
                    Expanded(
                      flex: 6,
                      child: _heroCard(context),
                    ),
                    const SizedBox(width: 16),
                    // RIGHT COLUMN: STACK (40%)
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _bentoTile(
                              context,
                              title: 'Nálada',
                              icon: Icons.mood_rounded,
                              color: const Color(0xFF5C6BC0), // Indigo 400
                              onTap: () => context.navigateToMood(),
                              showArrow: false,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _bentoTile(
                              context,
                              title: 'Parťák',
                              subtitle: 'Chat',
                              icon: Icons.smart_toy_rounded,
                              color: const Color(0xFF26A69A), // Teal 400
                              onTap: () => context.go(AppRoutes.partner),
                              isDark: false, // Keep it light/clean
                              showArrow: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Wide Tile (Tips) - Calm Green
              SizedBox(
                height: 110,
                child: _bentoTile(
                  context,
                  title: 'Tipy pro zdraví',
                  subtitle: 'Inspirace pro každý den',
                  icon: Icons.lightbulb_outline_rounded,
                  color: const Color(0xFF66BB6A), // Soft Green
                  onTap: () => context.navigateToTips(),
                  isHorizontal: true,
                ),
              ),

              const SizedBox(height: 48),

              // 4. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rychlé akce',
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.gray900,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Horizontal List (Quick Actions)
              SizedBox(
                height: 140, 
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                     _actionCard(
                      context,
                      title: 'Zklidnění',
                      icon: Icons.wind_power_rounded,
                      color: const Color(0xFF5C6BC0), // Unified Indigo
                      onTap: () => context.navigateToPause(),
                    ),
                    const SizedBox(width: 16),
                    _actionCard(
                      context,
                      title: 'Afirmace',
                      icon: Icons.spa_rounded,
                      color: const Color(0xFFEC407A), // Muted Pink as accent
                      onTap: () {}, 
                    ),
                    const SizedBox(width: 16),
                    _actionCard(
                      context,
                      title: 'Statistiky',
                      icon: Icons.bar_chart_rounded,
                      color: const Color(0xFFFFA726), // Soft Orange
                      onTap: () => context.navigateToStats(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 64),

              // 6. Dev Tools
              Opacity(
                opacity: 0.4,
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => context.navigateTo(AppRoutes.database),
                    icon: const Icon(Icons.bug_report_rounded, size: 18),
                    label: const Text('Dev Tools'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.gray500,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Bento Tiles (Clean Style)
  Widget _bentoTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDark = false,
    bool isHorizontal = false,
    bool showArrow = true,
  }) {
    // Clean: White backgrounds, subtle colored tints for icons
    final bgColor = isDark ? color : Colors.white;
    final shadowColor = Colors.black.withOpacity(0.06); 

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28), // Rounded but clean
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: isHorizontal 
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1), // Tinted background
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17, // Slightly smaller
                              fontWeight: FontWeight.w800,
                              color: AppColors.gray900,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray500, // Softer gray
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (showArrow)
                         Icon(Icons.arrow_forward_rounded, color: AppColors.gray300, size: 22)
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon, 
                        color: isDark ? Colors.white : color, 
                        size: 26
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.gray900,
                          ),
                        ),
                        if (subtitle != null)
                           Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white.withOpacity(0.8) : AppColors.gray500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  // Helper for Action Cards (Clean Style)
  Widget _actionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Neutral shadow
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.gray800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _DatabaseButton extends StatelessWidget {
  const _DatabaseButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return SizedBox(
      width: 120,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, color: color, size: 24),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
