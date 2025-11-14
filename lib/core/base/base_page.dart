import 'package:flutter/material.dart';
import '../../ui/widgets/app_scaffold.dart';
import '../../ui/widgets/app_bottom_nav.dart';
import '../../ui/foundations/spacing.dart';

/// Base page widget with common structure
/// Provides consistent layout for all pages
abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});

  /// Page title for app bar
  String? get title;

  /// Whether to show bottom navigation
  bool get showBottomNav => true;

  /// Whether to show app bar
  bool get showAppBar => true;

  /// Custom app bar
  PreferredSizeWidget? get appBar => null;

  /// Page content
  Widget buildContent(BuildContext context);

  /// Optional floating action button
  Widget? get floatingActionButton => null;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: showAppBar
          ? (appBar ??
              (title != null
                  ? AppBar(title: Text(title!))
                  : null))
          : null,
      bottomBar: showBottomNav ? const AppBottomNav() : null,
      body: buildContent(context),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Base stateful page with common state management
abstract class BaseStatefulPage<T extends StatefulWidget> extends State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Set loading state
  @protected
  void setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  /// Set error message
  @protected
  void setError(String? message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  /// Clear error
  @protected
  void clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  /// Handle refresh
  Future<void> onRefresh() async {
    // Override in subclasses
  }

  /// Build error widget
  Widget? buildErrorWidget(BuildContext context) {
    if (_errorMessage == null) return null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () {
                clearError();
                onRefresh();
              },
              child: const Text('Zkusit znovu'),
            ),
          ],
        ),
      ),
    );
  }
}

