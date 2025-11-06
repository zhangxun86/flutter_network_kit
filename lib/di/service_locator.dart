import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../config/app_environment_service.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

/// Sets up the core services provided by the network library.
///
/// [extraInterceptors] are passed down to the [DioClient].
void setupNetworkLocator({List<Interceptor>? extraInterceptors}) {
  getIt.registerLazySingleton(() => AppEnvironmentService(AppConfig.baseUrl));
  getIt.registerLazySingleton(() => DioClient(
        getIt<AppEnvironmentService>(),
        extraInterceptors: extraInterceptors,
      ));
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);
}