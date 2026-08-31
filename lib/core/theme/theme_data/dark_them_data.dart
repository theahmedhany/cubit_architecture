import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors/custom_app_colors.dart';
import '../app_texts/app_fonts.dart';

ThemeData darkThemeData(BuildContext context) {
  final colors = CustomAppColors.dark();

  final fontFamily = AppFonts.getFontFamily(context);

  return ThemeData(
    scaffoldBackgroundColor: colors.neutral950,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    fontFamilyFallback: AppFonts.fallbackFonts,
    extensions: <ThemeExtension<dynamic>>[colors],

    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.primary600,
      brightness: Brightness.dark,
    ),

    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: colors.neutral0,
      displayColor: colors.neutral0,
      fontFamily: fontFamily,
      fontFamilyFallback: AppFonts.fallbackFonts,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
  );
}
