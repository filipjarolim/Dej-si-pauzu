import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_routes.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_bottom_nav.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _hapticFeedbackEnabled = true;
  String _selectedLanguage = 'Čeština';

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Nastavení'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomBar: const AppBottomNav(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Profile section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                child: InkWell(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  onTap: () => context.navigateToProfile(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                      border: Border.all(
                        color: AppColors.gray200,
                        width: DesignTokens.borderMedium,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.primary.withOpacity(0.12),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Profil',
                                style: text.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Zobrazit a upravit profil',
                                style: text.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Notifications
            _SettingsSection(
              title: 'Oznámení',
              children: <Widget>[
                _SwitchTile(
                  title: 'Push notifikace',
                  subtitle: 'Přijímat upozornění',
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    HapticFeedback.selectionClick();
                    setState(() => _notificationsEnabled = value);
                  },
                ),
              ],
            ),
            // Preferences
            _SettingsSection(
              title: 'Předvolby',
              children: <Widget>[
                _SwitchTile(
                  title: 'Tmavý režim',
                  subtitle: 'Přepnout na tmavý vzhled',
                  value: _darkModeEnabled,
                  onChanged: (bool value) {
                    HapticFeedback.selectionClick();
                    setState(() => _darkModeEnabled = value);
                  },
                ),
                _SwitchTile(
                  title: 'Haptická zpětná vazba',
                  subtitle: 'Vibrace při interakcích',
                  value: _hapticFeedbackEnabled,
                  onChanged: (bool value) {
                    HapticFeedback.selectionClick();
                    setState(() => _hapticFeedbackEnabled = value);
                  },
                ),
                _ListTile(
                  title: 'Jazyk',
                  subtitle: _selectedLanguage,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Vyberte jazyk'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <String>['Čeština', 'English', 'Deutsch']
                              .map(
                                (String lang) => ListTile(
                                  title: Text(lang),
                                  selected: lang == _selectedLanguage,
                                  onTap: () {
                                    setState(() => _selectedLanguage = lang);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            // About
            _SettingsSection(
              title: 'O aplikaci',
              children: <Widget>[
                _ListTile(
                  title: 'Verze',
                  subtitle: '1.0.0',
                ),
                _ListTile(
                  title: 'Kontakt',
                  subtitle: 'support@dejsipauzu.cz',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    // Email functionality will be implemented
                  },
                ),
                _ListTile(
                  title: 'Ochrana soukromí',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    // Privacy policy functionality will be implemented
                  },
                ),
                _ListTile(
                  title: 'Podmínky použití',
                  onTap: () {
                    HapticFeedback.selectionClick();
                    // Terms functionality will be implemented
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Text(
            title,
            style: text.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                border: Border.all(
                  color: AppColors.gray200,
                  width: DesignTokens.borderMedium,
                ),
              ),
              child: Column(children: children),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: DesignTokens.borderThin,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: text.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: text.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: cs.primary,
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: DesignTokens.borderThin,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: text.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: text.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              )
            : null,
        trailing: onTap != null
            ? Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withOpacity(0.4),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

