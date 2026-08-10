part of 'main.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final designSize = DesignSizeHelper.getDesignSize(context);

    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 0.8,
      maxScaleFactor: 1.1,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MultiBlocProvider(
              providers: [BlocProvider(create: (_) => ThemeCubit())],
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, newMode) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,

                    title: AppConstants.appName,

                    scrollBehavior: const AppScrollBehaviorHelper(),

                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,

                    theme: lightThemeData(context),
                    darkTheme: darkThemeData(context),
                    themeMode: newMode,

                    themeAnimationStyle: const AnimationStyle(
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubic,
                    ),

                    navigatorKey: RouteManager.navigatorKey,

                    builder: (context, child) {
                      final isDark = context.isDarkMode;

                      return AnnotatedRegion<SystemUiOverlayStyle>(
                        value: SystemUiOverlayStyle(
                          statusBarColor: Colors.transparent,
                          statusBarIconBrightness: isDark
                              ? Brightness.light
                              : Brightness.dark,
                          statusBarBrightness: isDark
                              ? Brightness.dark
                              : Brightness.light,
                          systemNavigationBarColor: Colors.transparent,
                          systemNavigationBarDividerColor: Colors.transparent,
                          systemNavigationBarIconBrightness: isDark
                              ? Brightness.light
                              : Brightness.dark,
                        ),
                        child: child!,
                      );
                    },

                    home: _getInitialScreen(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// Authentication Status Check
Future<void> _checkIfLoggedInUser() async {
  bool isFirstRun = SharedPrefHelper.getBool(
    key: AppCacheKeys.isFirstRun,
    defaultValue: true,
  );

  if (isFirstRun) {
    AppLogger.log(
      'First run detected. Clearing secure storage.',
      name: 'CHECK_IF_LOGGED_IN_USER',
    );

    await SecureStorageHelper.deleteAll();
    await SharedPrefHelper.setData(key: AppCacheKeys.isFirstRun, value: false);
  }

  String? userToken = await SecureStorageHelper.read(
    key: AppCacheKeys.userAccessToken,
  );

  AppLogger.log(
    'User token retrieved: $userToken',
    name: 'CHECK_IF_LOGGED_IN_USER',
  );

  if (userToken.isNotEmpty) {
    AppConstants.authStatus = AuthStatus.loggedIn;

    AppLogger.log(
      'User is logged in. Token exists. (AuthStatus.loggedIn)',
      name: 'CHECK_IF_LOGGED_IN_USER',
    );
  } else {
    AppConstants.authStatus = AuthStatus.guest;

    AppLogger.log(
      'User is not logged in. Token does not exist. (AuthStatus.guest)',
      name: 'CHECK_IF_LOGGED_IN_USER',
    );
  }
}

// Initial Screen Determination
Widget _getInitialScreen() {
  if (AppConstants.authStatus != AuthStatus.loggedIn) {
    return const OnboardingScreen();
  }

  switch (AppConstants.currentUserRole) {
    case UserRole.user:
      return const OnboardingScreen();

    case UserRole.admin:
      return const OnboardingScreen();

    default:
      return const NotFoundScreen();
  }
}
