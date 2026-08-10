class AppRegex {
  // Email Regex (standard email format)
  static final RegExp _emailRegex = RegExp(
    r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
  );

  static bool isEmailValid(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  // Password Regex (At least 8 characters, one uppercase, one lowercase, one number, one special character)
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  static bool isPasswordValid(String password) {
    return _passwordRegex.hasMatch(password.trim());
  }

  static bool hasLowerCase(String password) =>
      RegExp(r'(?=.*[a-z])').hasMatch(password.trim());

  static bool hasUpperCase(String password) =>
      RegExp(r'(?=.*[A-Z])').hasMatch(password.trim());

  static bool hasNumber(String password) =>
      RegExp(r'(?=.*?[0-9])').hasMatch(password.trim());

  static bool hasSpecialCharacter(String password) =>
      RegExp(r'(?=.*?[#?!@$%^&*-])').hasMatch(password.trim());

  static bool hasMinLength(String password) =>
      RegExp(r'(?=.{8,})').hasMatch(password.trim());

  // Egypt Phone Numbers (010XXXXXXXX, 011XXXXXXXX, 012XXXXXXXX, 015XXXXXXXX)
  static final RegExp _egyptPhoneRegex = RegExp(r'^(010|011|012|015)[0-9]{8}$');

  static bool isEGPhoneValid(String phone) {
    return _egyptPhoneRegex.hasMatch(phone.trim());
  }

  // Saudi Arabia Phone Numbers (05XXXXXXXX, 5XXXXXXXX, +9665XXXXXXXX)
  static final RegExp _saudiPhoneRegex = RegExp(r'^(?:\+9665|05|5)\d{8}$');

  static bool isSAPhoneValid(String phone) {
    return _saudiPhoneRegex.hasMatch(phone.trim());
  }

  // United Arab Emirates Phone Numbers (05XXXXXXXX, +9715XXXXXXXX)
  static final RegExp _uaePhoneRegex = RegExp(r'^(?:05\d{8}|\+9715\d{8})$');

  static bool isUAEPhoneValid(String phone) {
    return _uaePhoneRegex.hasMatch(phone.trim());
  }

  // Username (letters, numbers, underscore, 3-20 chars)
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  static bool isUsernameValid(String username) {
    return _usernameRegex.hasMatch(username.trim());
  }

  // URL Regex (basic URL validation)
  static final RegExp _urlRegex = RegExp(
    r'^(https?:\/\/)?([\w\-])+\.{1}[a-zA-Z]{2,}(\/\S*)?$',
  );

  static bool isUrlValid(String url) {
    return _urlRegex.hasMatch(url.trim());
  }

  static bool isNumeric(String value) {
    return RegExp(r'^[0-9]+([.,][0-9]+)?$').hasMatch(value.trim());
  }

  // Integer Only (digits only)
  static bool isInteger(String value) {
    return RegExp(r'^\d+$').hasMatch(value.trim());
  }

  // Decimal Number (positive numbers with optional decimal point)
  static bool isDecimal(String value) {
    return RegExp(r'^\d+(\.\d+)?$').hasMatch(value.trim());
  }

  // Format Enum Text (e.g., "ENUM_VALUE" -> "Enum Value")
  static String formatEnumText(String text) {
    return text
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Alphabet Only (letters only)
  static bool isAlphabetOnly(String value) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(value.trim());
  }

  // Arabic Text (Arabic letters and spaces)
  static bool isArabicText(String value) {
    return RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(value.trim());
  }

  // English Text (English letters and spaces)
  static bool isEnglishText(String value) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim());
  }

  // Hex Color Code (#RRGGBB or #RGB)
  static bool isHexColor(String value) {
    return RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$').hasMatch(value.trim());
  }
}
