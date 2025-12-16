import 'package:dio/dio.dart';
import '../interfaces/token_provider.dart';

class TokenInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final TokenProvider _tokenProvider;

  TokenInterceptor(this._dio, this._tokenProvider);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. 获取配置：默认为 true (需要 Token)
    final bool requiresToken = options.extra['requiresToken'] ?? true;

    // 2. 如果明确标记不需要 Token，直接跳过
    if (!requiresToken) {
      return super.onRequest(options, handler);
    }

    // 3. 正常逻辑：尝试获取 Token
    final String? accessToken = await _tokenProvider.getAccessToken();

    // 4. "可选 Token" 逻辑：
    // 如果拿到 Token 就加 Header，拿不到就不加（此时请求是不带 Token 发出的）
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 1. 获取配置
    final bool requiresToken = err.requestOptions.extra['requiresToken'] ?? true;

    // 2. 如果该请求本身不需要 Token (例如登录接口报了 401 密码错误)，
    // 我们不应该触发刷新 Token 逻辑，而是直接把错误抛给业务层
    if (!requiresToken) {
      return super.onError(err, handler);
    }

    // 3. 原有的刷新逻辑
    if (err.response?.statusCode == 401) {
      try {
        final bool success = await _tokenProvider.refreshToken();

        if (success) {
          final String? newAccessToken = await _tokenProvider.getAccessToken();
          if (newAccessToken != null) {
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