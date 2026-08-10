import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(
    String message, {
    String name = 'APP_LOGGER',
    LogColor? color,
    LogBackground? background,
    LogStyle? style,
  }) {
    if (!kDebugMode) return;

    final codes = <String>[
      if (color != null) '${color.code}',
      if (background != null) '${background.code}',
      if (style != null) '${style.code}',
    ];

    final formattedMessage =
        '\x1B[${codes.join(';')}m'
        '[$name] $message'
        '\x1B[0m';

    developer.log(formattedMessage, name: ' 🎯 ');
  }
}

enum LogStyle {
  blink(6),
  italic(3),
  underline(4),
  strike(9);

  const LogStyle(this.code);

  final int code;
}

enum LogColor {
  yellow(33),
  gold(93),
  magenta(35),
  pink(95),
  red(31),
  lightRed(91),
  green(32),
  lightGreen(92),
  blue(34),
  lightBlue(94),
  cyan(36),
  lightCyan(96),
  grey(90),
  black(30),
  white(37);

  const LogColor(this.code);

  final int code;
}

enum LogBackground {
  yellow(43),
  gold(103),
  magenta(45),
  pink(105),
  red(41),
  brightRed(101),
  green(42),
  lightGreen(102),
  blue(44),
  lightBlue(104),
  cyan(46),
  lightCyan(106),
  gray(100),
  black(40),
  white(47);

  const LogBackground(this.code);

  final int code;
}
