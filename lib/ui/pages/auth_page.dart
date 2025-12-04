import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isLoginMode = true; // true = login, false = register
  bool _isLoading = false;
  String? _errorMessage;
  
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Form keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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

  Future<void> _handleEmailPasswordAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();

    try {
      // TODO: Implement email/password authentication
      // For now, just show a message that it's not implemented yet
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Email/heslo přihlášení bude brzy dostupné. Použij prosím Google přihlášení.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _confirmPasswordController.clear();
    });
    HapticFeedback.selectionClick();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Zadejte email';
    }
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Zadejte platný email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Zadejte heslo';
    }
    if (value.length < 6) {
      return 'Heslo musí mít alespoň 6 znaků';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Potvrďte heslo';
    }
    if (value != _passwordController.text) {
      return 'Hesla se neshodují';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (!_isLoginMode && (value == null || value.isEmpty)) {
      return 'Zadejte jméno';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(
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
        title: Text(_isLoginMode ? 'Přihlášení' : 'Registrace'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.xxl),
              // Welcome text
              Text(
                _isLoginMode ? 'Vítej zpět!' : 'Vytvoř si účet',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _isLoginMode
                    ? 'Přihlas se a pokračuj v cestě za klidem.'
                    : 'Zaregistruj se a začni používat aplikaci.',
                style: text.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl + 8),
              
              // Name field (only for registration)
              if (!_isLoginMode) ...<Widget>[
                Text(
                  'Jméno',
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  validator: _validateName,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Zadejte jméno',
                    prefixIcon: const Icon(Icons.person_outline),
                    errorMaxLines: 2,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              // Email field
              Text(
                'Email',
                style: text.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Zadejte email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  errorMaxLines: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Password field
              Text(
                'Heslo',
                style: text.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: _obscurePassword,
                textInputAction: _isLoginMode ? TextInputAction.done : TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Zadejte heslo',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  errorMaxLines: 2,
                ),
                onFieldSubmitted: (_) {
                  if (_isLoginMode) {
                    _handleEmailPasswordAuth();
                  }
                },
              ),
              
              // Confirm password field (only for registration)
              if (!_isLoginMode) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Potvrzení hesla',
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Zadejte heslo znovu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    errorMaxLines: 2,
                  ),
                  onFieldSubmitted: (_) => _handleEmailPasswordAuth(),
                ),
              ],
              
              const SizedBox(height: AppSpacing.xl),
              
              // Email/Password submit button
              AppButton(
                label: _isLoginMode ? 'Přihlásit se' : 'Zaregistrovat se',
                onPressed: _isLoading ? null : _handleEmailPasswordAuth,
                leading: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Icon(
                        _isLoginMode ? Icons.login : Icons.person_add,
                        size: 20,
                        color: AppColors.white,
                      ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Divider
              Row(
                children: <Widget>[
                  Expanded(child: Divider(color: cs.onSurfaceVariant.withOpacity(0.2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'nebo',
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: cs.onSurfaceVariant.withOpacity(0.2))),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
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
                    : const Icon(
                        Icons.g_mobiledata,
                        size: 24,
                        color: AppColors.white,
                      ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Toggle between login/register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _isLoginMode ? 'Ještě nemáš účet? ' : 'Už máš účet? ',
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: _toggleMode,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _isLoginMode ? 'Zaregistruj se' : 'Přihlas se',
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}
