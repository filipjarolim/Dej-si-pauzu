import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import '../services/update_service.dart';

/// Widget that wraps the app and checks for updates from Google Play Store
class UpdateChecker extends StatefulWidget {
  const UpdateChecker({
    super.key,
    required this.child,
    this.checkOnStartup = true,
    this.forceUpdate = false,
  });

  final Widget child;
  final bool checkOnStartup;
  final bool forceUpdate;

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  @override
  Widget build(BuildContext context) {
    // UpgradeAlert automatically checks Google Play Store for updates
    // and shows a dialog when a newer version is available
    return UpgradeAlert(
      upgrader: Upgrader(
        // Duration before showing the alert again (1 day)
        durationUntilAlertAgain: const Duration(days: 1),
        
        // Country code for Google Play Store (Czech Republic)
        countryCode: 'cz',
        
        // Custom Czech messages
        messages: CzechUpgraderMessages(),
      ),
      // Whether the barrier can be dismissed (only if not force update)
      barrierDismissible: !widget.forceUpdate,
      child: widget.child,
    );
  }
}
