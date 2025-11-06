/// A robust, feature-rich, and dynamically configurable network framework for Flutter applications.
library flutter_network_kit;

import 'package:dio/dio.dart';
import 'package:flutter_network_kit/config/app_config.dart';
import 'package:flutter_network_kit/di/service_locator.dart';

// --- Public API of the library ---

// Core Services for configuration and direct use.
export 'package:flutter_network_kit/config/app_environment_service.dart';
export 'package:dio/dio.dart';

// Exceptions for structured error handling.
export 'package:flutter_network_kit/network/exception/api_exception.dart';

// Utilities for handling API call results.
export 'package:flutter_network_kit/utils/result.dart';

// UI Helper Widgets to simplify UI code.
export 'package:flutter_network_kit/widgets/api_future_builder.dart';

// Note: Alice is no longer part of this library's public or private API.

/// Main class to initialize the network framework.
class FlutterNetworkKit {
  /// Initializes the network framework.
  ///
  /// This must be called once in the `main()` function of the host application.
  ///
  /// The optional [httpClientAdapter] parameter allows the host application to inject
  /// a custom `HttpClientAdapter`, which is the correct way to integrate network
  /// inspectors like Alice v1.0.0+.
  static Future<void> initialize({HttpClientAdapter? httpClientAdapter}) async {
    // Load initial environment variables from the .env file.
    await AppConfig.load();
    
    // Set up the dependency injection container, passing the adapter along.
    setupNetworkLocator(httpClientAdapter: httpClientAdapter);
  }
}