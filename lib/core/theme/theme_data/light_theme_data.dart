import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors/custom_app_colors.dart';
import '../app_texts/app_fonts.dart';

ThemeData lightThemeData(BuildContext context) {
  final colors = CustomAppColors.light();

  final fontFamily = AppFonts.getFontFamily(context);

  return ThemeData(
    scaffoldBackgroundColor: colors.neutral0,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    fontFamilyFallback: AppFonts.fallbackFonts,
    extensions: <ThemeExtension<dynamic>>[colors],

    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.primary600,
      brightness: Brightness.light,
    ),

    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: colors.neutral900,
      displayColor: colors.neutral900,
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
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
