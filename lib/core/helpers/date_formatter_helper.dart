import 'package:intl/intl.dart';

class DateFormatterHelper {
  DateFormatterHelper._();

  static final Map<String, DateFormat> _formatters = {};

  static String format(
    String? date, {
    DateFormatType type = DateFormatType.dateLong,
    String? locale,
    String fallback = '-',
    bool toLocal = true,
  }) {
    final parsedDate = parse(date, toLocal: toLocal);

    if (parsedDate == null) {
      return fallback;
    }

    final effectiveLocale = locale ?? Intl.getCurrentLocale();
    final formatter = _getFormatter(type: type, locale: effectiveLocale);

    return formatter.format(parsedDate);
  }

  static String formatCustom(
    String? date, {
    required String pattern,
    String? locale,
    String fallback = '-',
    bool toLocal = true,
  }) {
    final parsedDate = parse(date, toLocal: toLocal);

    if (parsedDate == null) {
      return fallback;
    }

    final effectiveLocale = locale ?? Intl.getCurrentLocale();

    return _getCustomFormatter(
      pattern: pattern,
      locale: effectiveLocale,
    ).format(parsedDate);
  }

  static DateTime? parse(String? date, {bool toLocal = true}) {
    final normalized = _normalize(date);

    if (normalized == null) {
      return null;
    }

    try {
      final parsed = DateTime.parse(normalized);

      return toLocal ? parsed.toLocal() : parsed;
    } catch (_) {
      return null;
    }
  }

  static DateFormat _getFormatter({
    required DateFormatType type,
    required String locale,
  }) {
    final pattern = type.pattern;

    return _getCustomFormatter(pattern: pattern, locale: locale);
  }

  static DateFormat _getCustomFormatter({
    required String pattern,
    required String locale,
  }) {
    final key = '$locale|$pattern';

    return _formatters.putIfAbsent(key, () => DateFormat(pattern, locale));
  }

  static String? _normalize(String? date) {
    if (date == null) {
      return null;
    }

    final normalized = date.trim();

    if (normalized.isEmpty || normalized.toLowerCase() == 'null') {
      return null;
    }

    return normalized;
  }

  static void clearCache() {
    _formatters.clear();
  }
}

enum DateFormatType {
  dateLong('d MMMM y'),
  dateMedium('d MMM y'),
  dateShort('dd/MM/yyyy'),
  dateDashed('dd-MM-yyyy'),
  dateIso('yyyy/MM/dd'),
  dateIsoDashed('yyyy-MM-dd'),
  monthYearLong('MMMM y'),
  monthYearShort('MMM y'),
  monthLong('MMMM'),
  monthShort('MMM'),
  year('y'),
  weekdayLong('EEEE'),
  weekdayShort('EEE'),
  weekdayDateMedium('EEE, d MMM y'),
  weekdayDateLong('EEEE, d MMMM y'),
  time12Hour('hh:mm a'),
  time12HourShort('h:mm a'),
  time24Hour('HH:mm'),
  time24HourWithSeconds('HH:mm:ss'),
  dateTimeLong('d MMMM y, hh:mm a'),
  dateTimeMedium('d MMM y, hh:mm a'),
  dateTimeShort('dd/MM/yyyy, hh:mm a'),
  dateTime24Hour('dd/MM/yyyy HH:mm'),
  dateTimeCompact('d MMM y • hh:mm a'),
  dayOfMonth('dd'),
  monthNumber('MM'),
  dayMonthShort('d MMM'),
  dayMonthLong('d MMMM');

  const DateFormatType(this.pattern);

  final String pattern;
}
