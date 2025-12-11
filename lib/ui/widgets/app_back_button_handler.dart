import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';

/// Widget that handles Android back button with confirmation dialog
/// Use this to wrap pages that should show exit confirmation
class AppBackButtonHandler extends StatelessWidget {
  const AppBackButtonHandler({
    super.key,
    required this.child,
    this.showConfirmationOnExit = true,
  });

  final Widget child;
  final bool showConfirmationOnExit;

  Future<bool> _handleBackButton(BuildContext context) async {
    // If we can pop normally, do it
    if (context.canPop()) {
      context.pop();
      return false; // Don't exit app
    }

    // If we're on a page that should show confirmation before exit
    if (showConfirmationOnExit) {
      final bool? shouldExit = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Opustit aplikaci?'),
          content: const Text('Opravdu chceš aplikaci opustit?'),
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
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Opustit'),
            ),
          ],
        ),
      );

      if (shouldExit == true) {
        return true; // Exit app
      }
      return false; // Don't exit app
    }

    // If no confirmation needed, navigate to home
    context.go(AppRoutes.home);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool shouldExit = await _handleBackButton(context);
        if (shouldExit && context.mounted) {
          // Exit the app
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}



