import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import '../services/update_service.dart'; // For CzechUpgraderMessages

/// Widget that wraps the app and checks for updates
class UpdateChecker extends StatefulWidget {
  const UpdateChecker({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  @override
  Widget build(BuildContext context) {
    // UpgradeAlert automatically checks for updates and shows a dialog
    // when a newer version is available on the app store
    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
        countryCode: 'cz',
        messages: CzechUpgraderMessages(),
      ),
      barrierDismissible: false, // Force update - cannot dismiss
      showIgnore: false,
      showLater: false,
      dialogStyle: UpgradeDialogStyle.material,
      child: widget.child,
    );
  }
}



