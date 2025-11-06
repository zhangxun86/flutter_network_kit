import 'package:dio/dio.dart';

/// A skeleton for an interceptor that handles automatic token refreshing.
///
/// The actual implementation of `AuthService.refreshToken()` and
/// `AuthService.getAccessToken()` depends on your specific authentication logic
/// and how tokens are stored (e.g., SharedPreferences, FlutterSecureStorage).
class TokenInterceptor extends QueuedInterceptorsWrapper {
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
      // Assuming a 401 indicates an expired token.
      try {
        // Lock subsequent requests until the token is refreshed.
        _dio.lock();
        
        // Perform the token refresh logic.
        // final bool success = await AuthService.refreshToken();
        final bool success = true; // Placeholder
        
        if (success) {
          // If refresh is successful, unlock and retry the original request.
          _dio.unlock();
          
          // Fetch the new token.
          // final String newAccessToken = await AuthService.getAccessToken();
          final String newAccessToken = "new_dummy_token"; // Placeholder

          // Update the header of the failed request.
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Retry the request with the new token.
          final response = await _dio.fetch(requestOptions);
          return handler.resolve(response);
        } else {
          // If refresh fails, unlock and propagate the error.
          _dio.unlock();
          // You might want to trigger a global logout here.
          return super.onError(err, handler);
        }
      } catch (e) {
        _dio.unlock();
        return super.onError(err, handler);
      }
    }
    super.onError(err, handler);
  }
}