import 'package:flutter/foundation.dart';

/// Manages the application's runtime environment configurations, such as the API base URL.
///
/// This service allows for dynamic updates to configurations after the app has started,
/// for scenarios like private deployments or multi-region support.
class AppEnvironmentService {
  late final ValueNotifier<String> _baseUrlNotifier;

  /// Gets the current, active base URL.
  String get baseUrl => _baseUrlNotifier.value;

  /// A notifier that emits the new base URL whenever it changes.
  /// The `DioClient` listens to this to automatically reconfigure itself.
  ValueNotifier<String> get baseUrlNotifier => _baseUrlNotifier;

  /// Initializes the service with a default/initial base URL.
  AppEnvironmentService(String initialBaseUrl) {
    _baseUrlNotifier = ValueNotifier<String>(initialBaseUrl);
  }

  /// Updates the base URL at runtime and notifies all listeners.
  ///
  /// A basic validation is performed to ensure the URL is a valid absolute URI.
  /// This is typically called from a settings page or after a login process
  /// that returns a custom server URL.
  void updateBaseUrl(String newBaseUrl) {
    if (newBaseUrl.isNotEmpty && newBaseUrl != _baseUrlNotifier.value) {
      if (Uri.tryParse(newBaseUrl)?.isAbsolute ?? false) {
        _baseUrlNotifier.value = newBaseUrl;
        debugPrint('[AppEnvironmentService] Base URL updated to: $newBaseUrl');
      } else {
        debugPrint('[AppEnvironmentService] Ignored invalid URL format: $newBaseUrl');
      }
    }
  }
}