import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/build_context_extensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/app_service.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isSaving = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final AuthService authService = ServiceRegistry.get<AuthService>()!;
    _currentUser = authService.currentUser;
    
    if (_currentUser != null) {
      _nameController.text = _currentUser!.name ?? '';
      _emailController.text = _currentUser!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_isEditing) return;

    setState(() {
      _isSaving = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final AuthService authService = ServiceRegistry.get<AuthService>()!;
      await authService.updateProfile(
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      );
      
      // Reload user data
      _loadUserData();
      
      if (!mounted) return;
      
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      
      context.showSnackBar('Profil byl úspěšně aktualizován');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      context.showSnackBar('Chyba při ukládání: $e', isError: true);
    }
  }

  Future<void> _signOut() async {
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        title: const Text('Odhlásit se?'),
        content: const Text('Opravdu se chceš odhlásit?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(dialogContext).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Odhlásit se'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthService authService = ServiceRegistry.get<AuthService>()!;
      await authService.signOut();

      if (!mounted) return;

      // Navigate to auth page
      context.go(AppRoutes.auth);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      context.showSnackBar('Chyba při odhlašování: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isAuthenticated = _currentUser != null;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        actions: <Widget>[
          if (isAuthenticated && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      bottomBar: const AppBottomNav(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Profile picture section
            Center(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cs.primary.withOpacity(0.12),
                            width: 3,
                          ),
                        ),
                        child: _currentUser?.photoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _currentUser!.photoUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    size: 64,
                                    color: cs.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 64,
                                color: cs.primary,
                              ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!_isEditing)
                    Text(
                      'Změnit foto',
                      style: text.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            if (!isAuthenticated) ...<Widget>[
              // Not authenticated state
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Nejsi přihlášen',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Přihlas se, abys mohl používat všechny funkce aplikace.',
                      style: text.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Přihlásit se',
                      onPressed: () => context.go(AppRoutes.auth),
                    ),
                  ],
                ),
              ),
            ] else ...<Widget>[
              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Jméno',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        hintText: 'Zadejte jméno',
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Email',
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _emailController,
                      enabled: false, // Email shouldn't be editable
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Zadejte email',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    if (_currentUser?.provider != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Přihlášen přes ${_currentUser!.provider == 'google' ? 'Google' : _currentUser!.provider}',
                            style: text.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl + 8),
                    if (_isEditing) ...<Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _isEditing = false;
                                  _loadUserData(); // Reset to original values
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              ),
                              child: const Text('Zrušit'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: _isSaving ? 'Ukládám...' : 'Uložit',
                              onPressed: _isSaving ? null : _saveProfile,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      AppButton(
                        label: 'Upravit profil',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Stats section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                      border: Border.all(
                        color: AppColors.gray200,
                        width: DesignTokens.borderMedium,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Statistiky',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            _StatItem(
                              value: '7',
                              label: 'Dní v řadě',
                              icon: Icons.local_fire_department,
                              color: cs.primary,
                            ),
                            _StatItem(
                              value: '24',
                              label: 'Celkem pauz',
                              icon: Icons.self_improvement,
                              color: cs.primary,
                            ),
                            _StatItem(
                              value: '12h',
                              label: 'Celkem času',
                              icon: Icons.access_time,
                              color: cs.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Sign out button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _signOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    side: BorderSide(color: AppColors.error),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(Icons.logout, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Odhlásit se',
                              style: text.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: text.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
