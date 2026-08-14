import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../api/dio_factory.dart';
import '../api/network_status_info.dart';
import 'setup_dependency_injection.dart';

class GeneralDependencyInjection {
  GeneralDependencyInjection._();

  static Future<void> init() async {
    // Dio + Dio Factory
    Dio dio = await DioFactory.getDio();
    getIt.registerLazySingleton<Dio>(() => dio);

    // Connectivity + NetworkStatus
    getIt.registerLazySingleton<Connectivity>(() => Connectivity());
    getIt.registerLazySingleton<NetworkStatusInfo>(
      () => NetworkStatusInfoImpl(getIt(), getIt<Dio>()),
    );
  }
}
