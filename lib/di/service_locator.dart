import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../config/app_environment_service.dart';
import '../network/dio_client.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Sets up the core services provided by the network library.
///
/// [extraInterceptors] allows the host application to inject its own interceptors,
/// such as a network inspector like Alice, which are then passed to the DioClient.
void setupNetworkLocator({List<Interceptor>? extraInterceptors}) {
  // 1. Register the runtime environment service.
  getIt.registerLazySingleton(() => AppEnvironmentService(AppConfig.baseUrl));

  // 2. Register the DioClient, passing the extra interceptors to it.
  getIt.registerLazySingleton(() => DioClient(
        getIt<AppEnvironmentService>(),
        extraInterceptors: extraInterceptors,
      ));
  
  // 3. Expose the fully configured Dio instance.
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);
}