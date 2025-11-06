/// A robust, feature-rich, and dynamically configurable network framework for Flutter applications.
library flutter_network_kit;

import 'package:dio/dio.dart'; // Exporting Dio for convenience
import 'package:flutter_network_kit/config/app_config.dart';
import 'package:flutter_network_kit/di/service_locator.dart';

// --- Public API of the library ---

export 'package:flutter_network_kit/config/app_environment_service.dart';
export 'package:dio/dio.dart';
export 'package:flutter_network_kit/network/exception/api_exception.dart';
export 'package:flutter_network_kit/utils/result.dart';
export 'package:flutter_network_kit/widgets/api_future_builder.dart';

// Note: Alice is no longer exported from here.

/// Main class to initialize the network framework.
class FlutterNetworkKit {
  /// Initializes the network framework.
  ///
  /// This must be called once in the `main()` function of the host application.
  /// [extraInterceptors] can be used to inject application-specific interceptors
  /// like network inspectors.
  static Future<void> initialize({List<Interceptor>? extraInterceptors}) async {
    await AppConfig.load();
    setupNetworkLocator(extraInterceptors: extraInterceptors);
  }
}