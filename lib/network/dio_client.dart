import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_environment_service.dart';
import 'interceptors/api_interceptor.dart';
import 'interceptors/token_interceptor.dart';

/// Manages the central Dio instance, including its configuration and interceptors.
///
/// This client is designed to be completely generic. It sets up core functionalities
/// like timeouts, base URL management, and foundational interceptors (API processing, token).
///
/// It provides a standardized extension point, `extraInterceptors`, allowing the
/// host application to inject any number of custom interceptors, such as
/// common parameter injectors, network inspectors (like Alice), or custom loggers.
class DioClient {
  final AppEnvironmentService _envService;
  late final Dio _dio;

  /// The constructor accepts an optional list of `extraInterceptors`.
  ///
  /// [Modification Note]:
  /// `extraInterceptors` are now added FIRST. This ensures that they are the "outermost"
  /// layer of the onion model. If `ApiInterceptor` (inner layer) detects a business error
  /// (like 8001) and rejects the request, the error bubbles up to these outer interceptors,
  /// allowing `TokenExpirationInterceptor` to catch it in its `onError` method.
  DioClient(this._envService, {List<Interceptor>? extraInterceptors}) {
    final options = BaseOptions(
      baseUrl: _envService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    );
    _dio = Dio(options);

    // Add a listener to react to runtime base URL changes.
    _envService.baseUrlNotifier.addListener(_onBaseUrlChanged);

    // Add interceptors in a specific, logical order for correct error handling.
    _dio.interceptors.addAll([
      // 1. Application-specific interceptors (e.g., TokenExpirationInterceptor).
      //    Added FIRST so they can catch errors thrown by interceptors added later.
      if (extraInterceptors != null) ...extraInterceptors,

      // 2. Core interceptor for standardized API response processing and error transformation.
      //    If this detects code 8001, it throws an exception, which bubbles up to #1.
      ApiInterceptor(),
      
      // 3. Core interceptor for handling authentication token logic (headers).
      TokenInterceptor(_dio),
      
      // 4. Debug-only logger.
      //    Added LAST to be closest to the network, logging the rawest form of data.
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
    ]);
  }

  /// The fully configured Dio instance, ready for use in data sources.
  Dio get dio => _dio;

  /// Callback function to update the Dio instance's base URL when the
  /// environment service notifies of a change.
  void _onBaseUrlChanged() {
    final newBaseUrl = _envService.baseUrl;
    if (_dio.options.baseUrl != newBaseUrl) {
      _dio.options.baseUrl = newBaseUrl;
      debugPrint('[DioClient] Dio baseUrl has been reconfigured to: $newBaseUrl');
    }
  }

  /// Cleans up resources, like removing the listener, to prevent memory leaks.
  void dispose() {
    _envService.baseUrlNotifier.removeListener(_onBaseUrlChanged);
  }
}