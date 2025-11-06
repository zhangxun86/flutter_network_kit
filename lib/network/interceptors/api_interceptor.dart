import 'package:dio/dio.dart';
import '../exception/api_exception.dart';

/// An interceptor that handles standard API request/response processing
/// and transforms Dio errors into custom `ApiException`s.
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Here you can add default headers, like Content-Type or a static API key.
    // Dynamic headers like auth tokens are better handled in a separate interceptor.
    options.headers['Content-Type'] = 'application/json; charset=UTF-8';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
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
          case 404:
            apiException = ApiException(
              message: "Resource not found.",
              code: statusCode,
              requestOptions: err.requestOptions,
              response: err.response,
            );
            break;
          // Add more cases for other common status codes (400, 403, 500, etc.)
          default:
            apiException = ApiException(
              message: err.response?.data?['message'] ?? 'An unexpected server error occurred.',
              code: statusCode,
              requestOptions: err.requestOptions,
              response: err.response, 
            );
            break;
        }
        break;
      case DioExceptionType.cancel:
        // This is not typically treated as an error by the UI.
        // We can just pass it along without creating an ApiException.
        return super.onError(err, handler);
      case DioExceptionType.connectionError:
         apiException = ApiException(
            message: "Connection error. Please check your internet connection.",
            requestOptions: err.requestOptions
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
    
    // Replace the original DioException with our custom ApiException
    final newError = err.copyWith(error: apiException);
    super.onError(newError, handler);
  }
}