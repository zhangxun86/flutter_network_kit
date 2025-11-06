/// A robust, feature-rich, and dynamically configurable network framework for Flutter applications.
library flutter_network_kit;

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

// Debugging tools, primarily for use in development environments.
export 'package:flutter_network_kit/network/dio_client.dart' show alice;

/// Main class to initialize the network framework.
class FlutterNetworkKit {
  /// Initializes the network framework.
  ///
  /// This must be called once in the `main()` function of the host application
  /// before `runApp()` is called. It handles loading environment variables
  /// and setting up the core dependency injection services.
  static Future<void> initialize() async {
    // 1. Load initial environment variables from .env file.
    await AppConfig.load();
    
    // 2. Setup core dependencies in the service locator.
    setupNetworkLocator();
  }
}