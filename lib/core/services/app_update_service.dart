import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  /// Notifies listeners when an update is available or the debug simulation is active.
  static final ValueNotifier<bool> updateAvailable = ValueNotifier<bool>(false);

  /// Checks for app updates via Google Play Store.
  static Future<void> checkForUpdate() async {
    // 1. Android Only Check
    if (!Platform.isAndroid) return;

    try {
      // 2. Check availability
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Update the state so the UI can react
        updateAvailable.value = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print("InAppUpdate Check Error: $e");
      }
    }
  }

  /// Manually starts the update flow (called when user clicks the banner).
  static Future<void> triggerUpdateFlow() async {
    if (!Platform.isAndroid && !kDebugMode) return;

    try {
      if (kDebugMode && updateAvailable.value) {
        // Simulate successful start in debug
        debugPrint("DEBUG: Simulate update flow started.");
        return; 
      }

      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      if (kDebugMode) {
        print("InAppUpdate Flow Error: $e");
      }
    }
  }

  /// FOR DEBUGGING ONLY: Forces the update UI to appear.
  static void debugSimulateUpdate() {
    updateAvailable.value = true;
  }
}
