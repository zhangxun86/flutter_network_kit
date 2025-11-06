import 'package:flutter/foundation.dart';

/// A sealed class representing the result of an operation that can either
/// succeed with a value of type [S] or fail with an exception of type [E].
@immutable
sealed class Result<S, E extends Exception> {
  const Result();
}

/// Represents a successful result with a value.
final class Success<S, E extends Exception> extends Result<S, E> {
  const Success(this.value);
  final S value;
}

/// Represents a failure with an exception.
final class Failure<S, E extends Exception> extends Result<S, E> {
  const Failure(this.exception);
  final E exception;
}