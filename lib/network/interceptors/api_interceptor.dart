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
          if (data.containsKey('data')) {
            response.data = data['data'];
          }
          return super.onResponse(response, handler);
        } else {
          final String msg = data['msg'] ?? 'Unknown business error';
          final error = DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
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
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiException) {
      return handler.next(err);
    }

    final ApiException apiException = _createApiException(err);

    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
    );

    return handler.next(newError);
  }

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
      case DioExceptionType.connectionError:
        return ApiException(
          message: "Connection error. Please check your network.",
          requestOptions: err.requestOptions,
        );
      case DioExceptionType.cancel:
        // This is not a user-facing error. We can create a silent exception
        // or handle it differently if needed. For now, a generic message.
        return ApiException(
          message: "Request was cancelled.",
          requestOptions: err.requestOptions,
        );
      default:
        return ApiException(
          message: "An unknown network error occurred.",
          requestOptions: err.requestOptions,
          response: err.response,
        );
    }
  }
}