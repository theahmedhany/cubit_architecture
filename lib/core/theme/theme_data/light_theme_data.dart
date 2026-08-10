import 'package:flutter/material.dart';

import '../app_colors/custom_app_colors.dart';
import '../app_texts/app_fonts.dart';

ThemeData lightThemeData(BuildContext context) {
  final colors = CustomAppColors.light();

  final fontFamily = AppFonts.getFontFamily(context);

  return ThemeData(
    scaffoldBackgroundColor: colors.neutral0,
    brightness: Brightness.light,
    fontFamily: fontFamily,
    extensions: <ThemeExtension<dynamic>>[colors],

    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.primary600,
      brightness: Brightness.light,
    ),

    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: colors.neutral900,
      displayColor: colors.neutral900,
      fontFamily: fontFamily,
    ),
  );
}
