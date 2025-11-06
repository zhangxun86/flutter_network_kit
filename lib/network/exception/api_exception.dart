import 'package:dio/dio.dart';

/// A custom exception class to handle all API-related errors in a structured way.
class ApiException implements Exception {
  /// A user-friendly message describing the error.
  final String message;
  
  /// The HTTP status code, if available.
  final int? code;
  
  /// The original `RequestOptions` that triggered this error.
  final RequestOptions requestOptions;
   
  /// The original `Response` object, if one was received.
  final Response? response;

  ApiException({
    required this.message,
    this.code,
    required this.requestOptions,
    this.response,
  });

  @override
  String toString() {
    return 'ApiException: \n'
           '  Code: $code\n'
           '  Message: $message\n'
           '  Endpoint: ${requestOptions.method} ${requestOptions.uri}\n'
           '  Request Data: ${requestOptions.data}\n'
           '  Response Data: ${response?.data}';
  }
}

/// A specific type of ApiException for 401 Unauthorized errors.
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    required super.requestOptions, 
    super.response,
  }) : super(
          message: 'Unauthorized: Access is denied due to invalid credentials.',
          code: 401,
        );
}