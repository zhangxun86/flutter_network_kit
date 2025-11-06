import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_environment_service.dart';
import 'interceptors/api_interceptor.dart';
import 'interceptors/token_interceptor.dart';

class DioClient {
  final AppEnvironmentService _envService;
  late final Dio _dio;

  /// The constructor now accepts an optional list of extra interceptors.
  /// This allows the host application to inject its own interceptors,
  /// such as a network inspector like Alice, without the library needing
  /// to know about them directly.
  DioClient(this._envService, {List<Interceptor>? extraInterceptors}) {
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
        // The console logger remains as a default debug tool.
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      ],
      
      // If the host application provides extra interceptors, add them here.
      if (extraInterceptors != null) ...extraInterceptors,
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