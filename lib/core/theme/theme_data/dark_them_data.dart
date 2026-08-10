import 'package:flutter/material.dart';

import '../app_colors/custom_app_colors.dart';
import '../app_texts/app_fonts.dart';

ThemeData darkThemeData(BuildContext context) {
  final colors = CustomAppColors.dark();

  final fontFamily = AppFonts.getFontFamily(context);

  return ThemeData(
    scaffoldBackgroundColor: colors.neutral950,
    brightness: Brightness.dark,
    fontFamily: fontFamily,
    extensions: <ThemeExtension<dynamic>>[colors],

    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.primary600,
      brightness: Brightness.dark,
    ),

    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: colors.neutral0,
      displayColor: colors.neutral0,
      fontFamily: fontFamily,
    ),
  );
}
