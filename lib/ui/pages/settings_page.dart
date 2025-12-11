import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _soundEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _notificationsEnabled = true;
  int _defaultBreathingCycles = 5;
  String _selectedLanguage = 'Čeština';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _hapticFeedbackEnabled = prefs.getBool('haptic_feedback_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _defaultBreathingCycles = prefs.getInt('default_breathing_cycles') ?? 5;
      _selectedLanguage = prefs.getString('selected_language') ?? 'Čeština';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Text(
          'Nastavení',
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.gray900,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          _buildSectionHeader('Zvuk a vibrace', text),
          _buildSwitchTile(
            'Zvuk',
            'Zapnout/zapnout zvukové efekty',
            _soundEnabled,
            (bool value) {
              setState(() => _soundEnabled = value);
              _saveSetting('sound_enabled', value);
              HapticFeedback.selectionClick();
            },
          ),
          _buildSwitchTile(
            'Haptická zpětná vazba',
            'Vibrace při interakcích',
            _hapticFeedbackEnabled,
            (bool value) {
              setState(() => _hapticFeedbackEnabled = value);
              _saveSetting('haptic_feedback_enabled', value);
              if (value) {
                HapticFeedback.mediumImpact();
              }
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('Cvičení', text),
          _buildSliderTile(
            'Výchozí počet cyklů',
            'Počet cyklů pro dýchací cvičení',
            _defaultBreathingCycles,
            3,
            10,
            (double value) {
              setState(() => _defaultBreathingCycles = value.toInt());
              _saveSetting('default_breathing_cycles', _defaultBreathingCycles);
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('Oznámení', text),
          _buildSwitchTile(
            'Připomínky',
            'Denní připomínky k cvičení',
            _notificationsEnabled,
            (bool value) {
              setState(() => _notificationsEnabled = value);
              _saveSetting('notifications_enabled', value);
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('Aplikace', text),
          _buildListTile(
            'Jazyk',
            _selectedLanguage,
            Icons.language_rounded,
            () {
              HapticFeedback.selectionClick();
              _showLanguageDialog(context, text);
            },
          ),
          _buildListTile(
            'O aplikaci',
            'Verze 1.0.0',
            Icons.info_outline_rounded,
            () {
              HapticFeedback.selectionClick();
              _showAboutDialog(context, text);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader('Data', text),
          _buildListTile(
            'Vymazat data',
            'Smazat všechna uložená data',
            Icons.delete_outline_rounded,
            () {
              HapticFeedback.mediumImpact();
              _showClearDataDialog(context, text);
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextTheme text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.lg),
      child: Text(
        title,
        style: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.gray700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: AppColors.gray200,
          width: 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: text.bodySmall?.copyWith(
            color: AppColors.gray600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    int value,
    int min,
    int max,
    ValueChanged<double> onChanged,
  ) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: AppColors.gray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Text(
                  '$value',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value',
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: AppColors.gray200,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDestructive ? AppColors.error : AppColors.primary).withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppColors.error : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.error : AppColors.gray900,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: text.bodySmall?.copyWith(
            color: AppColors.gray600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.gray400,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, TextTheme text) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Vyber jazyk',
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RadioListTile<String>(
              title: const Text('Čeština'),
              value: 'Čeština',
              groupValue: _selectedLanguage,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  _saveSetting('selected_language', value);
                  Navigator.of(context).pop();
                  HapticFeedback.selectionClick();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  _saveSetting('selected_language', value);
                  Navigator.of(context).pop();
                  HapticFeedback.selectionClick();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, TextTheme text) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'O aplikaci',
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Dej si pauzu',
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Verze 1.0.0',
              style: text.bodyMedium?.copyWith(
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aplikace pro relaxaci a wellness. Dýchací cvičení, meditace a protahování pro každodenní pohodu.',
              style: text.bodyMedium?.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Text('Zavřít'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, TextTheme text) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Vymazat data',
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Opravdu chcete smazat všechna uložená data? Tato akce je nevratná.',
          style: text.bodyMedium?.copyWith(
            color: AppColors.gray700,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data byla vymazána'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Vymazat'),
          ),
        ],
      ),
    );
  }
}
