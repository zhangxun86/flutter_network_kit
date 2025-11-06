import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_environment_service.dart';
import 'interceptors/api_interceptor.dart';
import 'interceptors/token_interceptor.dart';

/// Manages the central Dio instance, including its configuration,
/// interceptors, and dynamic properties like the base URL.
///
/// This client is designed to be decoupled from specific debugging tools.
/// It allows for the injection of a custom `HttpClientAdapter` to integrate
/// tools like Alice without the library having a direct dependency on them.
class DioClient {
  final AppEnvironmentService _envService;
  late final Dio _dio;

  /// The constructor accepts an optional `HttpClientAdapter`.
  /// This is the designated extension point for integrating network inspectors like Alice.
  DioClient(this._envService, {HttpClientAdapter? httpClientAdapter}) {
    final options = BaseOptions(
      baseUrl: _envService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    );
    _dio = Dio(options);

    // If a custom HttpClientAdapter is provided (e.g., from Alice),
    // it's attached to the Dio instance. This replaces Dio's default
    // HTTP client and allows the adapter to intercept all network traffic.
    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
    }

    // Add a listener to react to runtime base URL changes.
    _envService.baseUrlNotifier.addListener(_onBaseUrlChanged);

    // Add interceptors in a specific order.
    // Interceptors work alongside the HttpClientAdapter.
    _dio.interceptors.addAll([
      ApiInterceptor(),
      TokenInterceptor(_dio),
      
      // The console logger remains a default debug-only tool.
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