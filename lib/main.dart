import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/cache/app_cache_keys.dart';
import 'core/cache/secure_storage_helper.dart';
import 'core/cache/shared_pref_helper.dart';
import 'core/common/screens/not_found_screen.dart';
import 'core/di/setup_dependency_injection.dart';
import 'core/enums/auth_status.dart';
import 'core/enums/user_role.dart';
import 'core/helpers/app_constants.dart';
import 'core/helpers/app_logger.dart';
import 'core/helpers/app_scroll_behavior_helper.dart';
import 'core/helpers/bloc_observer_helper.dart';
import 'core/helpers/design_size_helper.dart';
import 'core/routing/route_manager.dart';
import 'core/theme/app_texts/app_language.dart';
import 'core/theme/theme_data/dark_them_data.dart';
import 'core/theme/theme_data/light_theme_data.dart';
import 'core/theme/theme_manager/theme_cubit.dart';
import 'core/theme/theme_manager/theme_extensions.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

part 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await ScreenUtil.ensureScreenSize();

  await SharedPrefHelper.init();
  await SecureStorageHelper.init();

  await setupDependencyInjection();

  await EasyLocalization.ensureInitialized();

  Bloc.observer = BlocObserverHelper();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // await Future.wait([
  //   PushNotificationsUtil.init(),
  //   LocalNotificationsUtil.init(),
  // ]);

  await _checkIfLoggedInUser();

  runApp(
    EasyLocalization(
      supportedLocales: AppLanguage.supportedLanguages,
      path: AppLanguage.langPath,
      startLocale: const Locale(AppLanguage.startLocale),
      fallbackLocale: const Locale(AppLanguage.fallbackLocale),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}
