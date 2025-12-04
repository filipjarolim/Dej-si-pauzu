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
├── extensions/        # Extension methods
│   └── build_context_extensions.dart  # BuildContext extensions
├── services/          # Service layer
│   ├── app_service.dart     # Service base and registry
│   ├── auth_service.dart    # Authentication service
│   ├── database_service.dart # Database service
│   └── update_service.dart  # App update service
└── widgets/          # Core widgets
    └── update_checker.dart  # Update checker widget
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

## Best Practices

1. **Always use route constants** - Never hardcode route strings
2. **Use navigation helpers** - Prefer `AppNavigator` or extensions over direct `context.go()`
3. **Use services** - Access services through `ServiceRegistry.get<ServiceType>()`
