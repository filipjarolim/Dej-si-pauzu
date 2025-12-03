import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/app_service.dart';
import '../foundations/spacing.dart';
import '../foundations/colors.dart';
import '../foundations/design_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_button.dart';
import '../../core/constants/app_routes.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AuthService authService = ServiceRegistry.get<AuthService>()!;
      await authService.signInWithGoogle();

      if (!mounted) return;

      // Navigate to home after successful sign in
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(title: const Text('Přihlášení')),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: AppSpacing.xxl),
            // Welcome text
            Text(
              'Vítej zpět!',
              style: text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Přihlas se pomocí svého Google účtu a začni používat aplikaci.',
              style: text.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl + 8),
            // Google Sign In Button
            AppButton(
              label: 'Přihlásit se pomocí Google',
              onPressed: _isLoading ? null : _signInWithGoogle,
              leading: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : Image.asset(
                      'icon512.png', // You can replace this with Google logo asset
                      width: 20,
                      height: 20,
                    ),
            ),
            // Error message
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: DesignTokens.borderThin,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: text.bodyMedium?.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
