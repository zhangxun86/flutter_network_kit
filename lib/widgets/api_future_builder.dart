import 'package:flutter/material.dart';
import '../network/exception/api_exception.dart';

/// A wrapper around `FutureBuilder` that simplifies handling of common states
/// (loading, error, success) for API calls.
class ApiFutureBuilder<T> extends StatelessWidget {
  /// The future that this builder is observing. Typically a method call from a repository.
  final Future<T> future;
  
  /// A builder function for the success state, providing the received data.
  final Widget Function(BuildContext context, T data) successBuilder;
  
  /// A custom widget to display while the future is loading.
  /// Defaults to a centered `CircularProgressIndicator`.
  final Widget? loadingWidget;
  
  /// A custom builder function for the error state, providing the error message.
  /// Defaults to a centered red text widget displaying the message.
  final Widget Function(BuildContext- context, String errorMessage)? errorBuilder;

  const ApiFutureBuilder({
    super.key,
    required this.future,
    required this.successBuilder,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        // Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }

        // Error State
        if (snapshot.hasError) {
          final error = snapshot.error;
          final String errorMessage;

          if (error is ApiException) {
            errorMessage = error.message;
          } else {
            errorMessage = "An unexpected error occurred. Please try again.";
            debugPrint("ApiFutureBuilder caught a non-ApiException: $error");
          }
          
          if (errorBuilder != null) {
            return errorBuilder!(context, errorMessage);
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        // Success State
        if (snapshot.hasData) {
          return successBuilder(context, snapshot.data as T);
        }
        
        // Empty State (Future completed with null data and no error)
        return const SizedBox.shrink();
      },
    );
  }
}