import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_logger.dart';

class BlocObserverHelper extends BlocObserver {
  // Bloc observer helper on create bloc.
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    AppLogger.log('➕ On Create ➡️ ${bloc.runtimeType}', name: 'BLOC_OBSERVER');
  }

  // Bloc observer helper on change bloc event.
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.log(
      '✏️ On Change ➡️ ${bloc.runtimeType}, $change',
      name: 'BLOC_OBSERVER',
    );
  }

  // Bloc observer helper on error in bloc.
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.log(
      '❌ On Error ➡️ ${bloc.runtimeType}, $error',
      name: 'BLOC_OBSERVER',
    );
    super.onError(bloc, error, stackTrace);
  }

  // Bloc observer helper on close bloc.
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    AppLogger.log('🔒 On Close ➡️ ${bloc.runtimeType}', name: 'BLOC_OBSERVER');
  }
}
