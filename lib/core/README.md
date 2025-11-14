# Core Architecture

This directory contains the core architecture and infrastructure of the application.

## Structure

```
core/
├── constants/          # Application constants
│   ├── app_routes.dart      # Route definitions
│   └── app_constants.dart   # App-wide constants
├── navigation/        # Navigation utilities
│   └── app_navigator.dart   # Centralized navigation helper
├── utils/             # Utility functions
│   ├── debouncer.dart       # Debounce utility
│   └── async_helper.dart    # Async operation helpers
├── extensions/        # Extension methods
│   └── build_context_extensions.dart  # BuildContext extensions
├── base/              # Base classes
│   └── base_page.dart       # Base page widgets
├── services/          # Service layer
│   └── app_service.dart     # Service base and registry
└── widgets/          # Core widgets
    ├── error_widget.dart    # Standardized error widget
    └── empty_state_widget.dart  # Empty state widget
```

## Usage Examples

### Navigation

```dart
import '../../core/navigation/app_navigator.dart';
import '../../core/constants/app_routes.dart';

// Type-safe navigation
AppNavigator.toHome(context);
AppNavigator.go(context, AppRoutes.settings);

// Or use extensions
context.navigateToHome();
context.navigateToSettings();
```

### Constants

```dart
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';

// Use constants
await Future.delayed(AppConstants.refreshDelay);
AppNavigator.go(context, AppRoutes.home);
```

### Base Pages

```dart
import '../../core/base/base_page.dart';

class MyPage extends BasePage {
  @override
  String get title => 'My Page';

  @override
  Widget buildContent(BuildContext context) {
    return Center(child: Text('Content'));
  }
}
```

### Error Handling

```dart
import '../../core/widgets/error_widget.dart';

AppErrorWidget(
  message: 'Something went wrong',
  onRetry: () => _loadData(),
)
```

### Async Operations

```dart
import '../../core/utils/async_helper.dart';

await AsyncHelper.executeWithLoading(
  context: context,
  operation: () => _fetchData(),
  setLoading: (value) => setState(() => _loading = value),
);
```

### Debouncing

```dart
import '../../core/utils/debouncer.dart';

final _debouncer = Debouncer(duration: Duration(milliseconds: 300));

_debouncer.call(() {
  // This will only execute after 300ms of no calls
  _search();
});
```

## Best Practices

1. **Always use route constants** - Never hardcode route strings
2. **Use navigation helpers** - Prefer `AppNavigator` or extensions over direct `context.go()`
3. **Extend base classes** - Use `BasePage` for consistent page structure
4. **Handle errors consistently** - Use `AppErrorWidget` for error states
5. **Debounce user input** - Use `Debouncer` for search, filters, etc.
6. **Use async helpers** - Use `AsyncHelper` for consistent async operation handling

