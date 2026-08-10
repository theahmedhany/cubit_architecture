import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app_language.dart';

class AppFonts {
  const AppFonts._();

  static const instrumentSans = 'InstrumentSans';
  static const cairo = 'Cairo';

  // Get current font family based on the current language
  static String getFontFamily(BuildContext context) {
    final localLanguageCode = context.locale.languageCode;

    switch (localLanguageCode) {
      case AppLanguage.arCode:
        return cairo;

      case AppLanguage.enCode:
        return instrumentSans;

      default:
        return instrumentSans;
    }
  }
}
