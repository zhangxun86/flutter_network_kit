/// A robust, feature-rich, and dynamically configurable network framework for Flutter applications.
library flutter_network_kit;

import 'package:dio/dio.dart';
import 'package:flutter_network_kit/config/app_config.dart';
import 'package:flutter_network_kit/di/service_locator.dart';
import 'package:flutter_network_kit/network/interfaces/token_provider.dart';

// --- Public API of the library ---
export 'package:flutter_network_kit/config/app_environment_service.dart';
export 'package:dio/dio.dart';
export 'package:flutter_network_kit/network/exception/api_exception.dart';
export 'package:flutter_network_kit/network/interfaces/token_provider.dart';
export 'package:flutter_network_kit/utils/result.dart';
export 'package:flutter_network_kit/widgets/api_future_builder.dart';

/// Main class to initialize the network framework.
class FlutterNetworkKit {
  /// Initializes the network framework.
  ///
  /// [tokenProvider] is required to handle authentication logic (get/refresh token).
  /// [extraInterceptors] allows the host application to inject its own interceptors,
  /// such as a network inspector like Alice.
  static Future<void> initialize({
    required TokenProvider tokenProvider,
    List<Interceptor>? extraInterceptors,
  }) async {
    await AppConfig.load();
    setupNetworkLocator(
      tokenProvider: tokenProvider,
      extraInterceptors: extraInterceptors,
    );
  }
}