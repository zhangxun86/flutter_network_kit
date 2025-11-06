import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../config/app_environment_service.dart';
import '../network/dio_client.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Sets up the core services provided by the network library.
///
/// This function is called by `FlutterNetworkKit.initialize()`.
/// It now accepts an optional [httpClientAdapter] which is then passed down
/// to the [DioClient] during registration. This is the primary mechanism
/// for injecting external tools like network inspectors.
void setupNetworkLocator({HttpClientAdapter? httpClientAdapter}) {
  // 1. Register the runtime environment service as a singleton.
  // It's initialized with the base URL from the .env file.
  getIt.registerLazySingleton(() => AppEnvironmentService(AppConfig.baseUrl));

  // 2. Register the DioClient, passing the optional httpClientAdapter to it.
  // This ensures that if an adapter is provided, Dio will use it.
  getIt.registerLazySingleton(() => DioClient(
        getIt<AppEnvironmentService>(),
        httpClientAdapter: httpClientAdapter,
      ));
  
  // 3. Expose the fully configured Dio instance so that business-layer
  // datasources in the host application can easily access it.
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);
}