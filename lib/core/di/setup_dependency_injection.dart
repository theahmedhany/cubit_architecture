import 'package:get_it/get_it.dart';

import 'general_dependency_injection.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  await Future.wait([
    GeneralDependencyInjection.init(),
    // LoginDependencyInjection.init(),
    // HomeDependencyInjection.init(),
  ]);
}
