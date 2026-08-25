import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app_language.dart';

class AppFonts {
  const AppFonts._();

  static const String arabicFont = 'Alexandria';
  static const String englishFont = 'Poppins';

  static const List<String> fallbackFonts = [arabicFont, englishFont];

  static final RegExp _arabicRegex = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );

  static final RegExp _englishRegex = RegExp(r'[a-zA-Z]');

  static bool hasArabic(String text) {
    return _arabicRegex.hasMatch(text);
  }

  static bool hasEnglish(String text) {
    return _englishRegex.hasMatch(text);
  }

  static StringLanguage detectLanguage(String text) {
    final cleaned = text.trim();

    if (cleaned.isEmpty) {
      return StringLanguage.empty;
    }

    final hasAr = _arabicRegex.hasMatch(cleaned);
    final hasEn = _englishRegex.hasMatch(cleaned);

    if (hasAr && hasEn) {
      return StringLanguage.mixed;
    }

    if (hasAr) {
      return StringLanguage.arabic;
    }

    if (hasEn) {
      return StringLanguage.english;
    }

    return StringLanguage.empty;
  }

  static String? detectFontFamily(String? text) {
    if (text == null) {
      return null;
    }

    final textLang = detectLanguage(text);

    if (textLang == StringLanguage.arabic || textLang == StringLanguage.mixed) {
      return arabicFont;
    }

    if (textLang == StringLanguage.english) {
      return englishFont;
    }

    return null;
  }

  static String getFontFamily(BuildContext context, [String? text]) {
    if (text != null && text.trim().isNotEmpty) {
      final detected = detectFontFamily(text);

      if (detected != null) {
        return detected;
      }
    }

    final localLanguageCode = context.locale.languageCode;

    switch (localLanguageCode) {
      case AppLanguage.arCode:
        return arabicFont;

      case AppLanguage.enCode:
        return englishFont;

      default:
        return englishFont;
    }
  }
}

enum StringLanguage { arabic, english, mixed, empty }
