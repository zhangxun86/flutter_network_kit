import 'package:dio/dio.dart';

/// Interceptor that handles automatic token refreshing using the queueing mechanism.
class TokenInterceptor extends QueuedInterceptor {
  final Dio _dio;

  TokenInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // final String? accessToken = await AuthService.getAccessToken();
    // if (accessToken != null) {
    //   options.headers['Authorization'] = 'Bearer $accessToken';
    // }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        // No need to call dio.lock() anymore.
        // The handler will queue subsequent requests automatically.
        
        // Perform the token refresh logic.
        // final bool success = await AuthService.refreshToken();
        final bool success = true; // Placeholder for success

        if (success) {
          // Fetch the new token.
          // final String newAccessToken = await AuthService.getAccessToken();
          const String newAccessToken = "new_dummy_token"; // Placeholder

          // Update the header of the failed request.
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Retry the request with the new token.
          final response = await _dio.fetch(requestOptions);

          // When the request is resolved, the handler will unlock the queue
          // and process the pending requests.
          return handler.resolve(response);
        }
      } catch (e) {
        // If refresh fails, reject the error and the queue will be unlocked with an error.
        return handler.reject(err);
      }
    }
    // For other errors, just pass them along.
    super.onError(err, handler);
  }
}