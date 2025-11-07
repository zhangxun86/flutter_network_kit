import 'package:dio/dio.dart';
import '../exception/api_exception.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Content-Type'] = 'application/json; charset=UTF-8';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = response.data;
      
      if (data.containsKey('code')) {
        final int code = data['code'];
        
        if (code == 0) {
          // --- SUCCESS CASE ---
          // Only proceed if 'data' field also exists for successful responses.
          if (data.containsKey('data')) {
            response.data = data['data'];
          }
          // If 'data' field is null or absent, it will pass through as is, 
          // which might be null. This is acceptable.
          return super.onResponse(response, handler);
        } else {
          // --- BUSINESS ERROR CASE ---
          final String msg = data['msg'] ?? 'Unknown business error';
          // Create a DioException to be caught by the onError handler.
          final error = DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: ApiException( // Pre-populate the error with our custom exception
              message: msg,
              code: code,
              requestOptions: response.requestOptions,
              response: response,
            ),
          );
          // Reject the response, which will trigger the onError callback.
          return handler.reject(error);
        }
      }
    }
    // If the response format is not our standard, pass it through.
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If the error is already an ApiException (from our onResponse logic),
    // we just need to ensure it's properly wrapped in a DioException.
    if (err.error is! ApiException) {
      // If not, we create one. This handles network errors, timeouts, etc.
      final ApiException apiException = _createApiException(err);
      // Replace the original error with our custom ApiException.
      err.error = apiException;
    }
    
    super.onError(err, handler);
  }

  // Helper method to create ApiException from DioException
  ApiException _createApiException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: "Connection timed out.",
          requestOptions: err.requestOptions,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          message: "Server error: ${err.response?.statusCode}",
          code: err.response?.statusCode,
          requestOptions: err.requestOptions,
          response: err.response,
        );
      // ... handle other cases
      default:
        return ApiException(
          message: "An unknown network error occurred.",
          requestOptions: err.requestOptions,
          response: err.response,
        );
    }
  }
}