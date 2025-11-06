import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles the loading of initial compile-time environment variables from .env files.
/// These values serve as the default configuration before any runtime changes.
class AppConfig {
  /// Loads the appropriate .env file based on the `ENV` dart-define flag.
  /// Defaults to 'dev' if no flag is provided.
  static Future<void> load() async {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    await dotenv.load(fileName: ".env.$env");
  }

  /// Gets the initial base URL from the loaded .env file.
  /// This is used to bootstrap the `AppEnvironmentService`.
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://jsonplaceholder.typicode.com';
}