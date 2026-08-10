import 'package:flutter/material.dart';

import '../app_colors/custom_app_colors.dart';

extension ThemeExtensions on ThemeData {
  CustomAppColors get customAppColors {
    final customColors = extension<CustomAppColors>();

    if (customColors != null) {
      return customColors;
    }

    if (brightness == Brightness.dark) {
      return CustomAppColors.dark();
    } else {
      return CustomAppColors.light();
    }
  }
}

extension ContextExtensions on BuildContext {
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }

  bool get isLightMode {
    return Theme.of(this).brightness == Brightness.light;
  }

  CustomAppColors get customAppColors {
    return Theme.of(this).customAppColors;
  }
}
