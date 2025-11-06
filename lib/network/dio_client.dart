import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_environment_service.dart';
import 'interceptors/api_interceptor.dart';
import 'interceptors/token_interceptor.dart';

// --- UPDATED ALICE INITIALIZATION ---
/// Global Alice instance for in-app network inspection.
/// Exported so the host app can attach its navigatorKey.
final Alice alice = Alice(
  configuration: AliceConfiguration(
    showNotification: kDebugMode,
    showInspectorOnShake: kDebugMode,
    notificationIcon: '@mipmap/ic_launcher', // Default notification icon
  ),
);

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

    _envService.baseUrlNotifier.addListener(_onBaseUrlChanged);

    _dio.interceptors.addAll([
      ApiInterceptor(),
      TokenInterceptor(_dio),
      
      if (kDebugMode) ...[
        // --- UPDATED INTERCEPTOR USAGE ---
        alice.dioInterceptor, // Use the getter instead of the method
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

  Dio get dio => _dio;

  void _onBaseUrlChanged() {
    _dio.options.baseUrl = _envService.baseUrl;
    debugPrint('[DioClient] Dio baseUrl has been reconfigured to: ${_dio.options.baseUrl}');
  }

  void dispose() {
    _envService.baseUrlNotifier.removeListener(_onBaseUrlChanged);
  }
}