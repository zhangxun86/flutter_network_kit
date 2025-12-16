import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../config/app_environment_service.dart';
import '../network/dio_client.dart';
import '../network/interfaces/token_provider.dart';

final getIt = GetIt.instance;

/// Sets up the core services provided by the network library.
///
/// [tokenProvider] must be implemented by the host app to handle token storage and refresh logic.
/// [extraInterceptors] are passed down to the [DioClient].
void setupNetworkLocator({
  required TokenProvider tokenProvider,
  List<Interceptor>? extraInterceptors,
}) {
  getIt.registerLazySingleton(() => AppEnvironmentService(AppConfig.baseUrl));

  getIt.registerLazySingleton(() => DioClient(
    getIt<AppEnvironmentService>(),
    tokenProvider,
    extraInterceptors: extraInterceptors,
  ));

  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);
}