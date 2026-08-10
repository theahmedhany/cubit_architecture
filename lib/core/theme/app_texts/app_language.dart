import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppLanguage {
  const AppLanguage._();

  // Language asset path
  static const String langPath = 'assets/lang';

  // Language codes
  static const String arCode = 'ar';
  static const String enCode = 'en';

  // Default language code
  static const String startLocale = enCode;
  static const String fallbackLocale = arCode;

  // Supported languages
  static const List<Locale> supportedLanguages = [
    Locale(enCode),
    Locale(arCode),
  ];

  // Get resolved locale based on current language code
  static Locale resolvedLocale() {
    switch (currentLanguageCode) {
      case AppLanguage.arCode:
        return Locale(AppLanguage.arCode);

      case AppLanguage.enCode:
        return Locale(AppLanguage.enCode);

      default:
        return Locale(AppLanguage.enCode);
    }
  }

  // Get current language code
  static String get currentLanguageCode {
    try {
      return WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    } catch (_) {
      return enCode;
    }
  }

  // Helper methods to check current languages
  static bool isAr(BuildContext context) {
    return context.locale.languageCode == arCode;
  }

  static bool isEn(BuildContext context) {
    return context.locale.languageCode == enCode;
  }

  // Static getters to check current languages
  static bool get isAR {
    try {
      return WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
          arCode;
    } catch (_) {
      return false;
    }
  }

  static bool get isEN {
    try {
      return WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
          enCode;
    } catch (_) {
      return true;
    }
  }
}
