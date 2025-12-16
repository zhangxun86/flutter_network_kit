import 'package:dio/dio.dart';
import '../interfaces/token_provider.dart'; // 确保路径正确

class TokenInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenProvider _tokenProvider; // 新增

  TokenInterceptor(this._dio, this._tokenProvider);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 动态获取 Token
    final String? accessToken = await _tokenProvider.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        // 调用外部传入的刷新逻辑
        final bool success = await _tokenProvider.refreshToken();

        if (success) {
          // 刷新成功，获取新 Token
          final String? newAccessToken = await _tokenProvider.getAccessToken();

          if (newAccessToken != null) {
            // 更新 header 并重试
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final response = await _dio.fetch(requestOptions);
            return handler.resolve(response);
          }
        }
      } catch (e) {
        return handler.reject(err);
      }
    }
    super.onError(err, handler);
  }
}