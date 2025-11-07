import 'package:dio/dio.dart';
import '../exception/api_exception.dart';

/// An interceptor that handles:
/// 1. Adding default headers to requests.
/// 2. Processing a standardized API response structure (`{"code": ..., "data": ...}`).
/// 3. Transforming Dio errors and business errors into custom `ApiException`s.
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add default headers for every request.
    options.headers['Content-Type'] = 'application/json; charset=UTF-8';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if the response data is in the expected map format.
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = response.data;
      
      // Check for the presence of 'code' and 'data' keys, which define our standard response structure.
      if (data.containsKey('code') && data.containsKey('data')) {
        final int code = data['code'];
        final dynamic responseData = data['data'];
        
        if (code == 0) {
          // --- SUCCESS CASE (SMART UNBOXING) ---
          // If the business logic was successful (code == 0),
          // we replace the entire response body with just the content of the 'data' field.
          // This way, Retrofit or manual parsers only need to care about the actual business model.
          response.data = responseData;
          return super.onResponse(response, handler);
        } else {
          // --- BUSINESS ERROR CASE ---
          // If the backend returns a non-zero code, it's a specific business error.
          // We create a DioException and reject the request. This will trigger the `onError` handler.
          final String msg = data['msg'] ?? 'Unknown business error';
          final error = DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse, // Treat it as a bad response
            error: ApiException(
              message: msg,
              code: code,
              requestOptions: response.requestOptions,
              response: response,
            ),
          );
          return handler.reject(error);
        }
      }
    }
    
    // If the response format is not our standard structure, pass it through without modification.
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If the error is already a custom ApiException (e.g., from our onResponse logic),
    // we don't need to wrap it again. We just create a new DioException with the correct error object.
    if (err.error is ApiException) {
      final newError = err.copyWith(error: err.error);
      return super.onError(newError, handler);
    }

    // Handle standard network and HTTP errors from Dio.
    final ApiException apiException;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = ApiException(
          message: "Connection timed out. Please check your internet connection.",
          requestOptions: err.requestOptions,
        );
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 401:
            apiException = UnauthorizedException(
              requestOptions: err.requestOptions,
              response: err.response,
            );
            break;
          // Add more cases for other common status codes (403, 404, 500, etc.)
          default:
            apiException = ApiException(
              message: err.response?.data?['message'] ?? 'A server error occurred.',
              code: statusCode,
              requestOptions: err.requestOptions,
              response: err.response,
            );
            break;
        }
        break;
      case DioExceptionType.cancel:
        // Not treated as a user-facing error.
        return super.onError(err, handler);
      case DioExceptionType.connectionError:
        apiException = ApiException(
          message: "Connection error. Please check your network.",
          requestOptions: err.requestOptions,
        );
        break;
      case DioExceptionType.unknown:
      default:
        apiException = ApiException(
          message: "An unknown error occurred.",
          requestOptions: err.requestOptions,
          response: err.response,
        );
        break;
    }
    
    // Replace the original DioException error with our custom ApiException.
    final newError = err.copyWith(error: apiException);
    super.onError(newError, handler);
  }
}