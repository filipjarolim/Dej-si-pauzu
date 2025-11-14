/// Base service class for application services
/// Provides common functionality for all services
abstract class AppService {
  /// Initialize service
  Future<void> initialize() async {}

  /// Dispose service resources
  void dispose() {}
}

/// Service registry for managing app services
class ServiceRegistry {
  ServiceRegistry._();

  static final Map<Type, AppService> _services = <Type, AppService>{};

  /// Register a service
  static void register<T extends AppService>(T service) {
    _services[T] = service;
  }

  /// Get a service
  static T? get<T extends AppService>() {
    return _services[T] as T?;
  }

  /// Check if service is registered
  static bool has<T extends AppService>() {
    return _services.containsKey(T);
  }

  /// Initialize all services
  static Future<void> initializeAll() async {
    for (final AppService service in _services.values) {
      await service.initialize();
    }
  }

  /// Dispose all services
  static void disposeAll() {
    for (final AppService service in _services.values) {
      service.dispose();
    }
    _services.clear();
  }
}

