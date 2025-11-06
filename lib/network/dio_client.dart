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
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true, requestBody: true, responseBody: true,
          responseHeader: false, error: true, compact: true, maxWidth: 90,
        ),
      if (extraInterceptors != null) ...extraInterceptors,
    ]);
  }

  Dio get dio => _dio;

  void _onBaseUrlChanged() {
    _dio.options.baseUrl = _envService.baseUrl;
  }

  void dispose() {
    _envService.baseUrlNotifier.removeListener(_onBaseUrlChanged);
  }
}