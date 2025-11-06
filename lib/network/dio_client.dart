import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_environment_service.dart';
import 'interceptors/api_interceptor.dart';
import 'interceptors/token_interceptor.dart';

// --- CORRECT ALICE v1.0.0 INITIALIZATION ---
/// Global Alice instance for in-app network inspection.
final Alice alice = Alice();

/// Manages the central Dio instance.
class DioClient {
  final AppEnvironmentService _envService;
  late final Dio _dio;

  DioClient(this._envService) {
    // --- CONFIGURE ALICE INSTANCE AFTER CREATION ---
    alice.showNotification = kDebugMode;
    alice.showInspectorOnShake = kDebugMode;
    
    final options = BaseOptions(
      baseUrl: _envService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    );
    _dio = Dio(options);

    _envService.baseUrlNotifier.addListener(_onBaseUrlChanged);

    _dio.interceptors.addAll([
      ApiInterceptor(),
      TokenInterceptor(_dio),
      
      if (kDebugMode) ...[
        // --- CORRECT INTERCEPTOR USAGE ---
        alice.getDioInterceptor(), // It IS a method, not a getter.
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