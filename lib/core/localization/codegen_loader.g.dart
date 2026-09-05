// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _en = {
  "locale": "English",
  "localization": {
    "english_language": "English",
    "arabic_language": "Arabic",
    "english": "English",
    "english_short": "En",
    "arabic": "العربية",
    "arabic_short": "ع"
  },
  "themes": {
    "light_theme": "Light Theme",
    "dark_theme": "Dark Theme",
    "system_theme": "System Theme"
  },
  "validation": {
    "this_field_is_required": "This field is required",
    "email_is_required": "Email is required",
    "invalid_email_address": "Invalid email address",
    "password_is_required": "Password is required",
    "invalid_password": "Invalid password",
    "password_must_contain_a_lowercase_letter": "Password must contain a lowercase letter",
    "password_must_contain_an_uppercase_letter": "Password must contain an uppercase letter",
    "password_must_contain_a_number": "Password must contain a number",
    "password_must_contain_a_special_character": "Password must contain a special character (@ # % & *)",
    "password_must_be_at_least_8_characters": "Password must be at least 8 characters long",
    "confirm_password_is_required": "Confirm password is required",
    "password_does_not_match": "Password does not match",
    "phone_number_is_required": "Phone number is required",
    "invalid_phone_number": "Invalid phone number",
    "invalid_email_or_phone_number": "Invalid email or phone number",
    "must_be_at_least_characters": "Must be at least {min} characters",
    "must_be_at_most_characters": "Must be at most {max} characters",
    "username_is_required": "Username is required",
    "invalid_username": "Invalid username",
    "url_is_required": "URL is required",
    "invalid_url": "Invalid URL",
    "must_be_numeric": "Must be a numeric value",
    "must_be_integer": "Must be an integer",
    "must_be_decimal_number": "Must be a decimal number",
    "must_contain_alphabets_only": "Must contain alphabets only",
    "must_be_arabic_text": "Must be Arabic text",
    "must_be_english_text": "Must be English text",
    "invalid_hex_color": "Invalid hex color code"
  },
  "api_error_handling": {
    "no_internet_connection": "No internet connection, please check your network settings and try again.",
    "connection_to_server_failed": "Unable to connect to the server due to an internet issue",
    "request_to_server_was_cancelled": "The request to the server was cancelled",
    "connection_timeout_with_server": "Connection to the server timed out",
    "connection_to_server_failed_due_to_internet_connection": "Failed to connect to the server due to a weak or interrupted internet connection",
    "receive_timeout_in_connection_with_server": "Receiving data from the server timed out",
    "send_timeout_in_connection_with_server": "Sending data to the server timed out",
    "something_went_wrong": "Something went wrong, please try again later",
    "unknown_error_occurred": "An unexpected error occurred, please try again",
    "unauthorized_access": "Unauthorized access denied. Please log in again.",
    "server_error_occurred": "A server error occurred. Please try again later.",
    "request_timeout": "The request timed out. Please check your internet connection and try again."
  },
  "image_view": {
    "fit_width": "Fit Width",
    "fit_height": "Fit Height",
    "contain": "Contain",
    "cover": "Cover",
    "fill": "Fill",
    "reset": "Reset"
  },
  "base_state": {
    "try_again": "Try Again"
  },
  "app_drop_down": {
    "there_is_something_went_wrong": "Something went wrong.",
    "no_data_available": "No data available.",
    "no_results_found": "No results found.",
    "loading": "Loading..."
  },
  "custom_time_picker": {
    "am": "AM",
    "am_short": "AM",
    "pm": "PM",
    "pm_short": "PM",
    "select_time": "Select Time",
    "done": "Done",
    "cancel": "Cancel"
  },
  "custom_date_picker": {
    "select_date": "Select Date",
    "done": "Done",
    "cancel": "Cancel"
  },
  "days_of_week": {
    "saturday": "Saturday",
    "saturday_short": "Sat",
    "sunday": "Sunday",
    "sunday_short": "Sun",
    "monday": "Monday",
    "monday_short": "Mon",
    "tuesday": "Tuesday",
    "tuesday_short": "Tue",
    "wednesday": "Wednesday",
    "wednesday_short": "Wed",
    "thursday": "Thursday",
    "thursday_short": "Thu",
    "friday": "Friday",
    "friday_short": "Fri"
  },
  "not_found_screen": {
    "route_not_found": "Page not found",
    "route_not_found_message": "No route matched\nthis path.",
    "page_moved_or_not_exist": "The page you're looking for has been moved or doesn't exist.",
    "route_unmatched": "Route Unmatched",
    "go_to_login": "Go to Login",
    "go_back": "Go Back"
  },
  "app_slide_button": {
    "done": "Done"
  },
  "app_version_util": {
    "update_required_title": "Update Required",
    "update_required_message": "A new version of the app is available. Please update to continue using the app.",
    "update_now": "Update Now"
  },
  "device_security_util": {
    "emulator_detected_title": "Emulator Detected",
    "emulator_detected_message": "An emulator has been detected. Please use a real device for the best experience.",
    "rooted_device_title": "Rooted Device Detected",
    "rooted_device_message": "A rooted device has been detected. Please use a non-rooted device for the best experience.",
    "developer_mode_detected_title": "Developer Mode Detected",
    "developer_mode_detected_message": "Developer mode is enabled. Please disable it for the best experience.",
    "open_settings": "Open Settings",
    "okay": "Okay"
  },
  "url_launcher_util": {
    "url_not_available": "URL not available",
    "cannot_open_url": "Cannot open URL",
    "error_opening_url": "Error opening URL",
    "whatsapp_number_not_available": "WhatsApp number not available",
    "cannot_open_whatsapp": "Cannot open WhatsApp",
    "error_opening_whatsapp": "Error opening WhatsApp",
    "email_not_available": "Email not available",
    "cannot_open_email": "Cannot open Email",
    "error_opening_email": "Error opening Email",
    "phone_number_not_available": "Phone number not available",
    "cannot_open_phone": "Cannot open Phone",
    "error_opening_phone": "Error opening Phone",
    "cannot_open_sms": "Cannot open SMS",
    "error_opening_sms": "Error opening SMS",
    "location_not_available": "Location not available",
    "cannot_open_maps": "Cannot open Maps",
    "error_opening_maps": "Error opening Maps"
  }
};
static const Map<String,dynamic> _ar = {
  "locale": "العربية",
  "localization": {
    "english_language": "الإنجليزية",
    "arabic_language": "العربية",
    "english": "English",
    "english_short": "En",
    "arabic": "العربية",
    "arabic_short": "ع"
  },
  "themes": {
    "light_theme": "الوضع الفاتح",
    "dark_theme": "الوضع الداكن",
    "system_theme": "وضع النظام"
  },
  "validation": {
    "this_field_is_required": "هذا الحقل مطلوب",
    "email_is_required": "البريد الإلكتروني مطلوب",
    "invalid_email_address": "عنوان البريد الإلكتروني غير صالح",
    "password_is_required": "كلمة المرور مطلوبة",
    "invalid_password": "كلمة المرور غير صالحة",
    "password_must_contain_a_lowercase_letter": "يجب أن تحتوي كلمة المرور على حرف صغير",
    "password_must_contain_an_uppercase_letter": "يجب أن تحتوي كلمة المرور على حرف كبير",
    "password_must_contain_a_number": "يجب أن تحتوي كلمة المرور على رقم",
    "password_must_contain_a_special_character": "يجب أن تحتوي كلمة المرور على رمز خاص (@ # % & *)",
    "password_must_be_at_least_8_characters": "يجب أن تتكون كلمة المرور من 8 أحرف على الأقل",
    "confirm_password_is_required": "تأكيد كلمة المرور مطلوب",
    "password_does_not_match": "كلمة المرور غير متطابقة",
    "phone_number_is_required": "رقم الهاتف مطلوب",
    "invalid_phone_number": "رقم الهاتف غير صالح",
    "invalid_email_or_phone_number": "البريد الإلكتروني أو رقم الهاتف غير صالح",
    "must_be_at_least_characters": "يجب ألا يقل عن {min} أحرف",
    "must_be_at_most_characters": "يجب ألا يزيد عن {max} أحرف",
    "username_is_required": "اسم المستخدم مطلوب",
    "invalid_username": "اسم المستخدم غير صالح",
    "url_is_required": "الرابط مطلوب",
    "invalid_url": "الرابط غير صالح",
    "must_be_numeric": "يجب أن تكون القيمة رقمية",
    "must_be_integer": "يجب أن يكون عددًا صحيحًا",
    "must_be_decimal_number": "يجب أن يكون رقمًا عشريًا",
    "must_contain_alphabets_only": "يجب أن يحتوي على أحرف فقط",
    "must_be_arabic_text": "يجب أن يكون النص باللغة العربية",
    "must_be_english_text": "يجب أن يكون النص باللغة الإنجليزية",
    "invalid_hex_color": "رمز لون Hex غير صالح"
  },
  "api_error_handling": {
    "no_internet_connection": "لا يوجد اتصال بالإنترنت، يرجى التحقق من إعدادات الشبكة والمحاولة مرة أخرى.",
    "connection_to_server_failed": "تعذر الاتصال بالخادم بسبب مشكلة في الإنترنت",
    "request_to_server_was_cancelled": "تم إلغاء الطلب إلى الخادم",
    "connection_timeout_with_server": "انتهت مهلة الاتصال بالخادم",
    "connection_to_server_failed_due_to_internet_connection": "فشل الاتصال بالخادم بسبب ضعف أو انقطاع اتصال الإنترنت",
    "receive_timeout_in_connection_with_server": "انتهت مهلة استلام البيانات من الخادم",
    "send_timeout_in_connection_with_server": "انتهت مهلة إرسال البيانات إلى الخادم",
    "something_went_wrong": "حدث خطأ ما، يرجى المحاولة مرة أخرى لاحقًا",
    "unknown_error_occurred": "حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى",
    "unauthorized_access": "تم رفض الوصول غير المصرح به. يرجى تسجيل الدخول مرة أخرى.",
    "server_error_occurred": "حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقًا.",
    "request_timeout": "انتهت مهلة الطلب. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى."
  },
  "image_view": {
    "fit_width": "ملاءمة للعرض",
    "fit_height": "ملاءمة للارتفاع",
    "contain": "احتواء",
    "cover": "تغطية",
    "fill": "ملء",
    "reset": "إعادة تعيين"
  },
  "base_state": {
    "try_again": "حاول مرة أخرى"
  },
  "app_drop_down": {
    "there_is_something_went_wrong": "حدث خطأ ما.",
    "no_data_available": "لا توجد بيانات متاحة.",
    "no_results_found": "لم يتم العثور على نتائج.",
    "loading": "جارٍ التحميل..."
  },
  "custom_time_picker": {
    "am": "صباحًا",
    "am_short": "ص",
    "pm": "مساءً",
    "pm_short": "م",
    "select_time": "اختر الوقت",
    "done": "تم",
    "cancel": "إلغاء"
  },
  "custom_date_picker": {
    "select_date": "اختر التاريخ",
    "done": "تم",
    "cancel": "إلغاء"
  },
  "days_of_week": {
    "saturday": "السبت",
    "saturday_short": "سبت",
    "sunday": "الأحد",
    "sunday_short": "أحد",
    "monday": "الإثنين",
    "monday_short": "اثن",
    "tuesday": "الثلاثاء",
    "tuesday_short": "ثلا",
    "wednesday": "الأربعاء",
    "wednesday_short": "ارب",
    "thursday": "الخميس",
    "thursday_short": "خمي",
    "friday": "الجمعة",
    "friday_short": "جمع"
  },
  "not_found_screen": {
    "route_not_found": "الصفحة غير موجودة",
    "route_not_found_message": "لم يتم العثور على مسار مطابق\nلهذا المسار.",
    "page_moved_or_not_exist": "الصفحة التي تبحث عنها تم نقلها أو لم تعد موجودة.",
    "route_unmatched": "المسار غير مطابق",
    "go_to_login": "الانتقال إلى تسجيل الدخول",
    "go_back": "العودة"
  },
  "app_slide_button": {
    "done": "تم"
  },
  "app_version_util": {
    "update_required_title": "التحديث مطلوب",
    "update_required_message": "يتوفر إصدار جديد من التطبيق. يُرجى التحديث للمتابعة في استخدام التطبيق.",
    "update_now": "التحديث الآن"
  },
  "device_security_util": {
    "emulator_detected_title": "تم اكتشاف محاكي",
    "emulator_detected_message": "تم اكتشاف استخدام محاكي. يُرجى استخدام جهاز حقيقي للحصول على أفضل تجربة.",
    "rooted_device_title": "تم اكتشاف جهاز مروّت",
    "rooted_device_message": "تم اكتشاف أن الجهاز مروّت. يُرجى استخدام جهاز غير مروّت للحصول على أفضل تجربة.",
    "developer_mode_detected_title": "تم اكتشاف وضع المطوّر",
    "developer_mode_detected_message": "وضع المطوّر مفعّل. يُرجى تعطيله للحصول على أفضل تجربة.",
    "open_settings": "فتح الإعدادات",
    "okay": "حسنًا"
  },
  "url_launcher_util": {
    "url_not_available": "الرابط غير متاح",
    "cannot_open_url": "تعذر فتح الرابط",
    "error_opening_url": "حدث خطأ أثناء فتح الرابط",
    "whatsapp_number_not_available": "رقم واتساب غير متاح",
    "cannot_open_whatsapp": "تعذر فتح واتساب",
    "error_opening_whatsapp": "حدث خطأ أثناء فتح واتساب",
    "email_not_available": "البريد الإلكتروني غير متاح",
    "cannot_open_email": "تعذر فتح البريد الإلكتروني",
    "error_opening_email": "حدث خطأ أثناء فتح البريد الإلكتروني",
    "phone_number_not_available": "رقم الهاتف غير متاح",
    "cannot_open_phone": "تعذر فتح الهاتف",
    "error_opening_phone": "حدث خطأ أثناء فتح الهاتف",
    "cannot_open_sms": "تعذر فتح الرسائل النصية",
    "error_opening_sms": "حدث خطأ أثناء فتح الرسائل النصية",
    "location_not_available": "الموقع غير متاح",
    "cannot_open_maps": "تعذر فتح الخرائط",
    "error_opening_maps": "حدث خطأ أثناء فتح الخرائط"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": _en, "ar": _ar};
}
