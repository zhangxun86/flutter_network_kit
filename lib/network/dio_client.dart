import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_environment_service.dart';
import 'interceptors/api_interceptor.dart';
import 'interceptors/token_interceptor.dart';

/// Global Alice instance for in-app network inspection.
/// Exported so the host app can attach its navigatorKey.
final Alice alice = Alice(showNotification: kDebugMode, showInspectorOnShake: kDebugMode);

/// Manages the central Dio instance, including its configuration,
/// interceptors, and dynamic properties like the base URL.
class DioClient {
  final AppEnvironmentService _envService;
  late final Dio _dio;

  DioClient(this._envService) {
    final options = BaseOptions(
      baseUrl: _envService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    );
    _dio = Dio(options);

    // Add a listener to react to runtime base URL changes.
    _envService.baseUrlNotifier.addListener(_onBaseUrlChanged);

    // Add interceptors in a specific order.
    _dio.interceptors.addAll([
      // A custom interceptor to handle unified error transformation and headers.
      ApiInterceptor(),
      // An interceptor to handle automatic token refresh logic.
      TokenInterceptor(_dio), // Assumes TokenInterceptor needs Dio for retries.
      
      // Debug-only interceptors.
      if (kDebugMode) ...[
        alice.getDioInterceptor(),
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      ]
    ]);
  }

  /// The fully configured Dio instance.
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

  /// Cleans up resources, like removing the listener.
  void dispose() {
    _envService.baseUrlNotifier.removeListener(_onBaseUrlChanged);
  }
}