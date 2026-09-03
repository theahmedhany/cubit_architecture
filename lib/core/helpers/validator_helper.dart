import 'package:easy_localization/easy_localization.dart';

import '../localization/locale_keys.g.dart';
import 'app_regex.dart';

class ValidatorHelper {
  // Core helper
  static String? _required(String? value, String messageKey) {
    if (value == null || value.trim().isEmpty) {
      return messageKey.tr();
    }
    return null;
  }

  // Required Field Validation
  static String? required(String? value) =>
      _required(value, LocaleKeys.validation_this_field_is_required);

  // Length Validation
  static String? validateLength(String? value, {int? min, int? max}) {
    final req = required(value);
    if (req != null) return req;

    final length = value!.trim().length;

    if (min != null && length < min) {
      return LocaleKeys.validation_must_be_at_least_characters.tr(
        namedArgs: {'min': min.toString()},
      );
    }

    if (max != null && length > max) {
      return LocaleKeys.validation_must_be_at_most_characters.tr(
        namedArgs: {'max': max.toString()},
      );
    }

    return null;
  }

  // Email Validation
  static String? validateEmail(String? value) {
    final req = _required(value, LocaleKeys.validation_email_is_required);
    if (req != null) return req;

    if (!AppRegex.isEmailValid(value!.trim())) {
      return LocaleKeys.validation_invalid_email_address.tr();
    }

    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    final req = _required(value, LocaleKeys.validation_password_is_required);
    if (req != null) return req;

    final v = value!.trim();

    if (!AppRegex.hasLowerCase(v)) {
      return LocaleKeys.validation_password_must_contain_a_lowercase_letter
          .tr();
    }
    if (!AppRegex.hasUpperCase(v)) {
      return LocaleKeys.validation_password_must_contain_an_uppercase_letter
          .tr();
    }
    if (!AppRegex.hasNumber(v)) {
      return LocaleKeys.validation_password_must_contain_a_number.tr();
    }
    if (!AppRegex.hasSpecialCharacter(v)) {
      return LocaleKeys.validation_password_must_contain_a_special_character
          .tr();
    }
    if (!AppRegex.hasMinLength(v)) {
      return LocaleKeys.validation_password_must_be_at_least_8_characters.tr();
    }

    return null;
  }

  // Password Confirmation Validation
  static String? validatePasswordConfirm(String? value, String? password) {
    final req = _required(
      value,
      LocaleKeys.validation_confirm_password_is_required,
    );
    if (req != null) return req;

    if (value != password) {
      return LocaleKeys.validation_password_does_not_match.tr();
    }

    return null;
  }

  // General Phone Validation
  static String? validateGeneralPhone(String? value) {
    final req = _required(
      value,
      LocaleKeys.validation_phone_number_is_required,
    );
    if (req != null) return req;

    final v = value!.trim();
    if (v.length < 4 || v.length > 15) {
      return LocaleKeys.validation_invalid_phone_number.tr();
    }

    return null;
  }

  // Egypt Phone Validation
  static String? validateEGPhone(String? value) {
    final req = _required(
      value,
      LocaleKeys.validation_phone_number_is_required,
    );
    if (req != null) return req;

    if (!AppRegex.isEGPhoneValid(value!.trim())) {
      return LocaleKeys.validation_invalid_phone_number.tr();
    }

    return null;
  }

  // Saudi Arabia Phone Validation
  static String? validateSAPhone(String? value) {
    final req = _required(
      value,
      LocaleKeys.validation_phone_number_is_required,
    );
    if (req != null) return req;

    if (!AppRegex.isSAPhoneValid(value!.trim())) {
      return LocaleKeys.validation_invalid_phone_number.tr();
    }

    return null;
  }

  // UAE Phone Validation
  static String? validateUAEPhone(String? value) {
    final req = _required(
      value,
      LocaleKeys.validation_phone_number_is_required,
    );
    if (req != null) return req;

    if (!AppRegex.isUAEPhoneValid(value!.trim())) {
      return LocaleKeys.validation_invalid_phone_number.tr();
    }

    return null;
  }

  // Email or Phone Validation
  static String? validateEmailOrPhone(String? value) {
    final req = _required(
      value,
      LocaleKeys.validation_invalid_email_or_phone_number,
    );
    if (req != null) return req;

    final input = value!.trim();

    final isValid =
        AppRegex.isEmailValid(input) ||
        AppRegex.isEGPhoneValid(input) ||
        AppRegex.isSAPhoneValid(input) ||
        AppRegex.isUAEPhoneValid(input);

    if (!isValid) {
      return LocaleKeys.validation_invalid_email_or_phone_number.tr();
    }

    return null;
  }

  // Username Validation
  static String? validateUsername(String? value) {
    final req = _required(value, LocaleKeys.validation_username_is_required);
    if (req != null) return req;

    if (!AppRegex.isUsernameValid(value!.trim())) {
      return LocaleKeys.validation_invalid_username.tr();
    }

    return null;
  }

  // URL Validation
  static String? validateUrl(String? value) {
    final req = _required(value, LocaleKeys.validation_url_is_required);
    if (req != null) return req;

    if (!AppRegex.isUrlValid(value!.trim())) {
      return LocaleKeys.validation_invalid_url.tr();
    }

    return null;
  }

  // Numeric Validation (int or decimal, supports dot/comma)
  static String? validateNumeric(String? value) {
    final req = _required(value, LocaleKeys.validation_this_field_is_required);
    if (req != null) return req;

    if (!AppRegex.isNumeric(value!.trim())) {
      return LocaleKeys.validation_must_be_numeric.tr();
    }

    return null;
  }

  // Integer Validation (int only)
  static String? validateInteger(String? value) {
    final req = _required(value, LocaleKeys.validation_this_field_is_required);
    if (req != null) return req;

    if (!AppRegex.isInteger(value!.trim())) {
      return LocaleKeys.validation_must_be_integer.tr();
    }

    return null;
  }

  // Decimal Validation (dot only)
  static String? validateDecimal(String? value) {
    final req = _required(value, LocaleKeys.validation_this_field_is_required);
    if (req != null) return req;

    if (!AppRegex.isDecimal(value!.trim())) {
      return LocaleKeys.validation_must_be_decimal_number.tr();
    }

    return null;
  }

  // Alphabet Validation
  static String? validateAlphabet(String? value) {
    final req = _required(value, LocaleKeys.validation_this_field_is_required);
    if (req != null) return req;

    if (!AppRegex.isAlphabetOnly(value!.trim())) {
      return LocaleKeys.validation_must_contain_alphabets_only.tr();
    }

    return null;
  }

  // Arabic Text Validation
  static String? validateArabicText(String? value) {
    final req = _required(value, LocaleKeys.validation_this_field_is_required);
    if (req != null) return req;

    if (!AppRegex.isArabicText(value!.trim())) {
      return LocaleKeys.validation_must_be_arabic_text.tr();
    }

    return null;
  }

  // English Text Validation
  static String? validateEnglishText(String? value) {
    final req = _required(value, LocaleKeys.validation_this_field_is_required);
    if (req != null) return req;

    if (!AppRegex.isEnglishText(value!.trim())) {
      return LocaleKeys.validation_must_be_english_text.tr();
    }

    return null;
  }

  // Hex Color Validation
  static String? validateHexColor(String? value) {
    final req = _required(value, LocaleKeys.validation_this_field_is_required);
    if (req != null) return req;

    if (!AppRegex.isHexColor(value!.trim())) {
      return LocaleKeys.validation_invalid_hex_color.tr();
    }

    return null;
  }
}
