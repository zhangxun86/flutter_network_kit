import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../config/app_environment_service.dart';
import '../network/dio_client.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Sets up the core services provided by the network library.
/// This function is called by `FlutterNetworkKit.initialize()`.
void setupNetworkLocator() {
  // 1. Register the runtime environment service as a singleton.
  // It's initialized with the base URL from the .env file.
  getIt.registerLazySingleton(() => AppEnvironmentService(AppConfig.baseUrl));

  // 2. Register the DioClient, which depends on the environment service.
  getIt.registerLazySingleton(() => DioClient(getIt<AppEnvironmentService>()));
  
  // 3. Expose the fully configured Dio instance so that business-layer
  // datasources can easily access it.
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);
}