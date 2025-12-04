import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../ui/foundations/colors.dart';
import '../../ui/foundations/design_tokens.dart';
import 'app_service.dart';

/// Custom Czech messages for upgrader
class CzechUpgraderMessages extends UpgraderMessages {
  CzechUpgraderMessages() : super(code: 'cs');

  @override
  String get body => 'Nová verze aplikace je k dispozici na Google Play. Prosím aktualizujte aplikaci pro nejlepší zážitek a nejnovější funkce.';

  @override
  String get buttonTitleIgnore => 'Později';

  @override
  String get buttonTitleLater => 'Později';

  @override
  String get buttonTitleUpdate => 'Aktualizovat na Google Play';

  @override
  String get prompt => 'Aktualizace dostupná';

  @override
  String get title => 'Aktualizace aplikace';

  @override
  String get releaseNotes => 'Nové funkce a vylepšení';
}

/// Service for checking and handling app updates
class UpdateService extends AppService {
  UpdateService._();
  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;

  PackageInfo? _packageInfo;
  bool _isUpdateAvailable = false;
  bool _isUpdateRequired = false;

  PackageInfo? get packageInfo => _packageInfo;
  bool get isUpdateAvailable => _isUpdateAvailable;
  bool get isUpdateRequired => _isUpdateRequired;

  @override
  Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// Check for updates and show dialog if update is required
  Future<void> checkForUpdates(BuildContext context, {bool forceUpdate = true}) async {
    if (_packageInfo == null) {
      await initialize();
    }

    final Upgrader upgrader = Upgrader(
      durationUntilAlertAgain: const Duration(days: 1),
      minAppVersion: _packageInfo?.version,
      countryCode: 'cz', // Czech Republic for Google Play
      messages: CzechUpgraderMessages(),
    );

    await upgrader.initialize();
    
    if (upgrader.isUpdateAvailable()) {
      _isUpdateAvailable = true;
      if (forceUpdate) {
        _isUpdateRequired = true;
        // Show blocking dialog
        await _showForceUpdateDialog(context, upgrader);
      } else {
        // Show optional update dialog using UpgradeAlert
        // Note: UpgradeAlert is typically used as a widget wrapper
        // For programmatic display, we'll use a custom dialog
        await _showOptionalUpdateDialog(context, upgrader);
      }
    }
  }

  /// Show optional update dialog
  Future<void> _showOptionalUpdateDialog(BuildContext context, Upgrader upgrader) async {
    final messages = CzechUpgraderMessages();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        ),
        backgroundColor: AppColors.white,
        title: Text(messages.title),
        content: Text(upgrader.body(messages)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(messages.buttonTitleLater),
          ),
          ElevatedButton(
            onPressed: () {
              upgrader.sendUserToAppStore();
              Navigator.of(context).pop();
            },
            child: Text(messages.buttonTitleUpdate),
          ),
        ],
      ),
    );
  }

  /// Show a custom force update dialog that blocks the app
  Future<void> _showForceUpdateDialog(BuildContext context, Upgrader upgrader) async {
    final messages = CzechUpgraderMessages();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.black.withOpacity(0.7),
      builder: (BuildContext context) => PopScope(
        canPop: false, // Prevent dismissing
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          ),
          backgroundColor: AppColors.white,
          title: Row(
            children: <Widget>[
              Icon(
                Icons.system_update_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  messages.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                upgrader.body(messages),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.gray700,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: DesignTokens.borderThin,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aktuální verze: ${_packageInfo?.version ?? 'Neznámá'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray700,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  upgrader.sendUserToAppStore();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.download_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      messages.buttonTitleUpdate,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if update is available (non-blocking)
  Future<bool> checkUpdateAvailable() async {
    if (_packageInfo == null) {
      await initialize();
    }

    final Upgrader upgrader = Upgrader(
      minAppVersion: _packageInfo?.version,
      countryCode: 'cz',
    );

    await upgrader.initialize();
    _isUpdateAvailable = upgrader.isUpdateAvailable();
    return _isUpdateAvailable;
  }
}



