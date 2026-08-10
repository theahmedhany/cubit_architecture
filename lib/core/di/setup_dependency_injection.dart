import 'package:cubit_architecture/core/di/general_dependency_injection.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  await Future.wait([
    GeneralDependencyInjection.init(),
    // LoginDependencyInjection.init(),
    // HomeDependencyInjection.init(),
  ]);
}
