import 'package:intl/intl.dart';

class DateFormatterHelper {
  DateFormatterHelper._();

  static final Map<String, DateFormat> _cache = {};

  static String format(
    String? date, {
    DateFormatType type = DateFormatType.fullDate,
    String? locale,
    String fallback = '-',
    bool toLocal = true,
  }) {
    final normalized = _normalize(date);
    if (normalized == null) return fallback;

    final parsedDate = _tryParseDate(normalized, toLocal: toLocal);
    if (parsedDate == null) return fallback;

    final effectiveLocale = locale ?? Intl.getCurrentLocale();
    final pattern = _pattern(type);

    final formatter = _getCachedFormat(pattern, effectiveLocale);

    return formatter.format(parsedDate);
  }

  static DateTime? _tryParseDate(String value, {required bool toLocal}) {
    try {
      final date = DateTime.parse(value);
      return toLocal ? date.toLocal() : date;
    } catch (_) {
      return null;
    }
  }

  static String? _normalize(String? date) {
    if (date == null) return null;

    final trimmed = date.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.toLowerCase() == 'null') return null;

    return trimmed;
  }

  static DateFormat _getCachedFormat(String pattern, String locale) {
    final key = '$pattern|$locale';

    return _cache.putIfAbsent(key, () => DateFormat(pattern, locale));
  }

  static String _pattern(DateFormatType type) {
    switch (type) {
      case DateFormatType.fullDate:
        return 'd MMMM y';

      case DateFormatType.shortDate:
        return 'dd/MM/yyyy';

      case DateFormatType.monthYear:
        return 'MMMM y';

      case DateFormatType.time:
        return 'hh:mm a';

      case DateFormatType.fullDateTime:
        return 'd MMMM y, hh:mm a';
    }
  }
}

enum DateFormatType { fullDate, shortDate, monthYear, time, fullDateTime }
