import 'package:flutter/material.dart';

import 'dark_app_colors.dart';
import 'light_app_colors.dart';

class CustomAppColors extends ThemeExtension<CustomAppColors> {
  const CustomAppColors._({
    // Primary Colors
    required this.primary950,
    required this.primary900,
    required this.primary800,
    required this.primary700,
    required this.primary600,
    required this.primary500,
    required this.primary400,
    required this.primary300,
    required this.primary200,
    required this.primary100,
    required this.primary50,
    required this.primary0,

    // Secondary Colors
    required this.secondary950,
    required this.secondary900,
    required this.secondary800,
    required this.secondary700,
    required this.secondary600,
    required this.secondary500,
    required this.secondary400,
    required this.secondary300,
    required this.secondary200,
    required this.secondary100,
    required this.secondary50,
    required this.secondary0,

    // Neutral Colors
    required this.neutral950,
    required this.neutral900,
    required this.neutral800,
    required this.neutral700,
    required this.neutral600,
    required this.neutral500,
    required this.neutral400,
    required this.neutral300,
    required this.neutral200,
    required this.neutral100,
    required this.neutral50,
    required this.neutral0,

    // Base Colors
    required this.white,
    required this.black,

    // Warning Colors
    required this.warning950,
    required this.warning900,
    required this.warning800,
    required this.warning700,
    required this.warning600,
    required this.warning500,
    required this.warning400,
    required this.warning300,
    required this.warning200,
    required this.warning100,
    required this.warning50,
    required this.warning0,

    // Success Colors
    required this.success950,
    required this.success900,
    required this.success800,
    required this.success700,
    required this.success600,
    required this.success500,
    required this.success400,
    required this.success300,
    required this.success200,
    required this.success100,
    required this.success50,
    required this.success0,

    // Danger Colors
    required this.danger950,
    required this.danger900,
    required this.danger800,
    required this.danger700,
    required this.danger600,
    required this.danger500,
    required this.danger400,
    required this.danger300,
    required this.danger200,
    required this.danger100,
    required this.danger50,
    required this.danger0,

    // Info Colors
    required this.info950,
    required this.info900,
    required this.info800,
    required this.info700,
    required this.info600,
    required this.info500,
    required this.info400,
    required this.info300,
    required this.info200,
    required this.info100,
    required this.info50,
    required this.info0,

    // Tag Colors
    required this.tagPurple,
    required this.tagRose,
    required this.tagLime,
    required this.tagOrange,
    required this.tagTeal,
    required this.tagMagenta,
    required this.tagAmber,
    required this.tagBurgundy,
    required this.tagBrown,
  });

  // Primary Colors
  final Color primary950;
  final Color primary900;
  final Color primary800;
  final Color primary700;
  final Color primary600;
  final Color primary500;
  final Color primary400;
  final Color primary300;
  final Color primary200;
  final Color primary100;
  final Color primary50;
  final Color primary0;

  // Secondary Colors
  final Color secondary950;
  final Color secondary900;
  final Color secondary800;
  final Color secondary700;
  final Color secondary600;
  final Color secondary500;
  final Color secondary400;
  final Color secondary300;
  final Color secondary200;
  final Color secondary100;
  final Color secondary50;
  final Color secondary0;

  // Neutral Colors
  final Color neutral950;
  final Color neutral900;
  final Color neutral800;
  final Color neutral700;
  final Color neutral600;
  final Color neutral500;
  final Color neutral400;
  final Color neutral300;
  final Color neutral200;
  final Color neutral100;
  final Color neutral50;
  final Color neutral0;

  // Base Colors
  final Color white;
  final Color black;

  // Warning Colors
  final Color warning950;
  final Color warning900;
  final Color warning800;
  final Color warning700;
  final Color warning600;
  final Color warning500;
  final Color warning400;
  final Color warning300;
  final Color warning200;
  final Color warning100;
  final Color warning50;
  final Color warning0;

  // Success Colors
  final Color success950;
  final Color success900;
  final Color success800;
  final Color success700;
  final Color success600;
  final Color success500;
  final Color success400;
  final Color success300;
  final Color success200;
  final Color success100;
  final Color success50;
  final Color success0;

  // Danger Colors
  final Color danger950;
  final Color danger900;
  final Color danger800;
  final Color danger700;
  final Color danger600;
  final Color danger500;
  final Color danger400;
  final Color danger300;
  final Color danger200;
  final Color danger100;
  final Color danger50;
  final Color danger0;

  // Info Colors
  final Color info950;
  final Color info900;
  final Color info800;
  final Color info700;
  final Color info600;
  final Color info500;
  final Color info400;
  final Color info300;
  final Color info200;
  final Color info100;
  final Color info50;
  final Color info0;

  // Tag Colors
  final Color tagPurple;
  final Color tagRose;
  final Color tagLime;
  final Color tagOrange;
  final Color tagTeal;
  final Color tagMagenta;
  final Color tagAmber;
  final Color tagBurgundy;
  final Color tagBrown;

  // Light Theme Factory
  factory CustomAppColors.light() {
    return const CustomAppColors._(
      // Primary Colors
      primary950: LightAppColors.primary950,
      primary900: LightAppColors.primary900,
      primary800: LightAppColors.primary800,
      primary700: LightAppColors.primary700,
      primary600: LightAppColors.primary600,
      primary500: LightAppColors.primary500,
      primary400: LightAppColors.primary400,
      primary300: LightAppColors.primary300,
      primary200: LightAppColors.primary200,
      primary100: LightAppColors.primary100,
      primary50: LightAppColors.primary50,
      primary0: LightAppColors.primary0,

      // Secondary Colors
      secondary950: LightAppColors.secondary950,
      secondary900: LightAppColors.secondary900,
      secondary800: LightAppColors.secondary800,
      secondary700: LightAppColors.secondary700,
      secondary600: LightAppColors.secondary600,
      secondary500: LightAppColors.secondary500,
      secondary400: LightAppColors.secondary400,
      secondary300: LightAppColors.secondary300,
      secondary200: LightAppColors.secondary200,
      secondary100: LightAppColors.secondary100,
      secondary50: LightAppColors.secondary50,
      secondary0: LightAppColors.secondary0,

      // Neutral Colors
      neutral950: LightAppColors.neutral950,
      neutral900: LightAppColors.neutral900,
      neutral800: LightAppColors.neutral800,
      neutral700: LightAppColors.neutral700,
      neutral600: LightAppColors.neutral600,
      neutral500: LightAppColors.neutral500,
      neutral400: LightAppColors.neutral400,
      neutral300: LightAppColors.neutral300,
      neutral200: LightAppColors.neutral200,
      neutral100: LightAppColors.neutral100,
      neutral50: LightAppColors.neutral50,
      neutral0: LightAppColors.neutral0,

      // Base Colors
      white: LightAppColors.white,
      black: LightAppColors.black,

      // Warning Colors
      warning950: LightAppColors.warning950,
      warning900: LightAppColors.warning900,
      warning800: LightAppColors.warning800,
      warning700: LightAppColors.warning700,
      warning600: LightAppColors.warning600,
      warning500: LightAppColors.warning500,
      warning400: LightAppColors.warning400,
      warning300: LightAppColors.warning300,
      warning200: LightAppColors.warning200,
      warning100: LightAppColors.warning100,
      warning50: LightAppColors.warning50,
      warning0: LightAppColors.warning0,

      // Success Colors
      success950: LightAppColors.success950,
      success900: LightAppColors.success900,
      success800: LightAppColors.success800,
      success700: LightAppColors.success700,
      success600: LightAppColors.success600,
      success500: LightAppColors.success500,
      success400: LightAppColors.success400,
      success300: LightAppColors.success300,
      success200: LightAppColors.success200,
      success100: LightAppColors.success100,
      success50: LightAppColors.success50,
      success0: LightAppColors.success0,

      // Danger Colors
      danger950: LightAppColors.danger950,
      danger900: LightAppColors.danger900,
      danger800: LightAppColors.danger800,
      danger700: LightAppColors.danger700,
      danger600: LightAppColors.danger600,
      danger500: LightAppColors.danger500,
      danger400: LightAppColors.danger400,
      danger300: LightAppColors.danger300,
      danger200: LightAppColors.danger200,
      danger100: LightAppColors.danger100,
      danger50: LightAppColors.danger50,
      danger0: LightAppColors.danger0,

      // Info Colors
      info950: LightAppColors.info950,
      info900: LightAppColors.info900,
      info800: LightAppColors.info800,
      info700: LightAppColors.info700,
      info600: LightAppColors.info600,
      info500: LightAppColors.info500,
      info400: LightAppColors.info400,
      info300: LightAppColors.info300,
      info200: LightAppColors.info200,
      info100: LightAppColors.info100,
      info50: LightAppColors.info50,
      info0: LightAppColors.info0,

      // Tag Colors
      tagPurple: LightAppColors.tagPurple,
      tagRose: LightAppColors.tagRose,
      tagLime: LightAppColors.tagLime,
      tagOrange: LightAppColors.tagOrange,
      tagTeal: LightAppColors.tagTeal,
      tagMagenta: LightAppColors.tagMagenta,
      tagAmber: LightAppColors.tagAmber,
      tagBurgundy: LightAppColors.tagBurgundy,
      tagBrown: LightAppColors.tagBrown,
    );
  }

  // Dark Theme Factory
  factory CustomAppColors.dark() {
    return const CustomAppColors._(
      // Primary Colors
      primary950: DarkAppColors.primary950,
      primary900: DarkAppColors.primary900,
      primary800: DarkAppColors.primary800,
      primary700: DarkAppColors.primary700,
      primary600: DarkAppColors.primary600,
      primary500: DarkAppColors.primary500,
      primary400: DarkAppColors.primary400,
      primary300: DarkAppColors.primary300,
      primary200: DarkAppColors.primary200,
      primary100: DarkAppColors.primary100,
      primary50: DarkAppColors.primary50,
      primary0: DarkAppColors.primary0,

      // Secondary Colors
      secondary950: DarkAppColors.secondary950,
      secondary900: DarkAppColors.secondary900,
      secondary800: DarkAppColors.secondary800,
      secondary700: DarkAppColors.secondary700,
      secondary600: DarkAppColors.secondary600,
      secondary500: DarkAppColors.secondary500,
      secondary400: DarkAppColors.secondary400,
      secondary300: DarkAppColors.secondary300,
      secondary200: DarkAppColors.secondary200,
      secondary100: DarkAppColors.secondary100,
      secondary50: DarkAppColors.secondary50,
      secondary0: DarkAppColors.secondary0,

      // Neutral Colors
      neutral950: DarkAppColors.neutral950,
      neutral900: DarkAppColors.neutral900,
      neutral800: DarkAppColors.neutral800,
      neutral700: DarkAppColors.neutral700,
      neutral600: DarkAppColors.neutral600,
      neutral500: DarkAppColors.neutral500,
      neutral400: DarkAppColors.neutral400,
      neutral300: DarkAppColors.neutral300,
      neutral200: DarkAppColors.neutral200,
      neutral100: DarkAppColors.neutral100,
      neutral50: DarkAppColors.neutral50,
      neutral0: DarkAppColors.neutral0,

      // Base Colors
      white: DarkAppColors.white,
      black: DarkAppColors.black,

      // Warning Colors
      warning950: DarkAppColors.warning950,
      warning900: DarkAppColors.warning900,
      warning800: DarkAppColors.warning800,
      warning700: DarkAppColors.warning700,
      warning600: DarkAppColors.warning600,
      warning500: DarkAppColors.warning500,
      warning400: DarkAppColors.warning400,
      warning300: DarkAppColors.warning300,
      warning200: DarkAppColors.warning200,
      warning100: DarkAppColors.warning100,
      warning50: DarkAppColors.warning50,
      warning0: DarkAppColors.warning0,

      // Success Colors
      success950: DarkAppColors.success950,
      success900: DarkAppColors.success900,
      success800: DarkAppColors.success800,
      success700: DarkAppColors.success700,
      success600: DarkAppColors.success600,
      success500: DarkAppColors.success500,
      success400: DarkAppColors.success400,
      success300: DarkAppColors.success300,
      success200: DarkAppColors.success200,
      success100: DarkAppColors.success100,
      success50: DarkAppColors.success50,
      success0: DarkAppColors.success0,

      // Danger Colors
      danger950: DarkAppColors.danger950,
      danger900: DarkAppColors.danger900,
      danger800: DarkAppColors.danger800,
      danger700: DarkAppColors.danger700,
      danger600: DarkAppColors.danger600,
      danger500: DarkAppColors.danger500,
      danger400: DarkAppColors.danger400,
      danger300: DarkAppColors.danger300,
      danger200: DarkAppColors.danger200,
      danger100: DarkAppColors.danger100,
      danger50: DarkAppColors.danger50,
      danger0: DarkAppColors.danger0,

      // Info Colors
      info950: DarkAppColors.info950,
      info900: DarkAppColors.info900,
      info800: DarkAppColors.info800,
      info700: DarkAppColors.info700,
      info600: DarkAppColors.info600,
      info500: DarkAppColors.info500,
      info400: DarkAppColors.info400,
      info300: DarkAppColors.info300,
      info200: DarkAppColors.info200,
      info100: DarkAppColors.info100,
      info50: DarkAppColors.info50,
      info0: DarkAppColors.info0,

      // Tag Colors
      tagPurple: DarkAppColors.tagPurple,
      tagRose: DarkAppColors.tagRose,
      tagLime: DarkAppColors.tagLime,
      tagOrange: DarkAppColors.tagOrange,
      tagTeal: DarkAppColors.tagTeal,
      tagMagenta: DarkAppColors.tagMagenta,
      tagAmber: DarkAppColors.tagAmber,
      tagBurgundy: DarkAppColors.tagBurgundy,
      tagBrown: DarkAppColors.tagBrown,
    );
  }

  @override
  CustomAppColors copyWith() => this;

  @override
  CustomAppColors lerp(ThemeExtension<CustomAppColors>? other, double t) {
    if (other is! CustomAppColors) return this;

    return CustomAppColors._(
      // Primary Colors
      primary950: _lerpColor(primary950, other.primary950, t),
      primary900: _lerpColor(primary900, other.primary900, t),
      primary800: _lerpColor(primary800, other.primary800, t),
      primary700: _lerpColor(primary700, other.primary700, t),
      primary600: _lerpColor(primary600, other.primary600, t),
      primary500: _lerpColor(primary500, other.primary500, t),
      primary400: _lerpColor(primary400, other.primary400, t),
      primary300: _lerpColor(primary300, other.primary300, t),
      primary200: _lerpColor(primary200, other.primary200, t),
      primary100: _lerpColor(primary100, other.primary100, t),
      primary50: _lerpColor(primary50, other.primary50, t),
      primary0: _lerpColor(primary0, other.primary0, t),

      // Secondary Colors
      secondary950: _lerpColor(secondary950, other.secondary950, t),
      secondary900: _lerpColor(secondary900, other.secondary900, t),
      secondary800: _lerpColor(secondary800, other.secondary800, t),
      secondary700: _lerpColor(secondary700, other.secondary700, t),
      secondary600: _lerpColor(secondary600, other.secondary600, t),
      secondary500: _lerpColor(secondary500, other.secondary500, t),
      secondary400: _lerpColor(secondary400, other.secondary400, t),
      secondary300: _lerpColor(secondary300, other.secondary300, t),
      secondary200: _lerpColor(secondary200, other.secondary200, t),
      secondary100: _lerpColor(secondary100, other.secondary100, t),
      secondary50: _lerpColor(secondary50, other.secondary50, t),
      secondary0: _lerpColor(secondary0, other.secondary0, t),

      // Neutral Colors
      neutral950: _lerpColor(neutral950, other.neutral950, t),
      neutral900: _lerpColor(neutral900, other.neutral900, t),
      neutral800: _lerpColor(neutral800, other.neutral800, t),
      neutral700: _lerpColor(neutral700, other.neutral700, t),
      neutral600: _lerpColor(neutral600, other.neutral600, t),
      neutral500: _lerpColor(neutral500, other.neutral500, t),
      neutral400: _lerpColor(neutral400, other.neutral400, t),
      neutral300: _lerpColor(neutral300, other.neutral300, t),
      neutral200: _lerpColor(neutral200, other.neutral200, t),
      neutral100: _lerpColor(neutral100, other.neutral100, t),
      neutral50: _lerpColor(neutral50, other.neutral50, t),
      neutral0: _lerpColor(neutral0, other.neutral0, t),

      // Base Colors
      white: _lerpColor(white, other.white, t),
      black: _lerpColor(black, other.black, t),

      // Warning Colors
      warning950: _lerpColor(warning950, other.warning950, t),
      warning900: _lerpColor(warning900, other.warning900, t),
      warning800: _lerpColor(warning800, other.warning800, t),
      warning700: _lerpColor(warning700, other.warning700, t),
      warning600: _lerpColor(warning600, other.warning600, t),
      warning500: _lerpColor(warning500, other.warning500, t),
      warning400: _lerpColor(warning400, other.warning400, t),
      warning300: _lerpColor(warning300, other.warning300, t),
      warning200: _lerpColor(warning200, other.warning200, t),
      warning100: _lerpColor(warning100, other.warning100, t),
      warning50: _lerpColor(warning50, other.warning50, t),
      warning0: _lerpColor(warning0, other.warning0, t),

      // Success Colors
      success950: _lerpColor(success950, other.success950, t),
      success900: _lerpColor(success900, other.success900, t),
      success800: _lerpColor(success800, other.success800, t),
      success700: _lerpColor(success700, other.success700, t),
      success600: _lerpColor(success600, other.success600, t),
      success500: _lerpColor(success500, other.success500, t),
      success400: _lerpColor(success400, other.success400, t),
      success300: _lerpColor(success300, other.success300, t),
      success200: _lerpColor(success200, other.success200, t),
      success100: _lerpColor(success100, other.success100, t),
      success50: _lerpColor(success50, other.success50, t),
      success0: _lerpColor(success0, other.success0, t),

      // Danger Colors
      danger950: _lerpColor(danger950, other.danger950, t),
      danger900: _lerpColor(danger900, other.danger900, t),
      danger800: _lerpColor(danger800, other.danger800, t),
      danger700: _lerpColor(danger700, other.danger700, t),
      danger600: _lerpColor(danger600, other.danger600, t),
      danger500: _lerpColor(danger500, other.danger500, t),
      danger400: _lerpColor(danger400, other.danger400, t),
      danger300: _lerpColor(danger300, other.danger300, t),
      danger200: _lerpColor(danger200, other.danger200, t),
      danger100: _lerpColor(danger100, other.danger100, t),
      danger50: _lerpColor(danger50, other.danger50, t),
      danger0: _lerpColor(danger0, other.danger0, t),

      // Info Colors
      info950: _lerpColor(info950, other.info950, t),
      info900: _lerpColor(info900, other.info900, t),
      info800: _lerpColor(info800, other.info800, t),
      info700: _lerpColor(info700, other.info700, t),
      info600: _lerpColor(info600, other.info600, t),
      info500: _lerpColor(info500, other.info500, t),
      info400: _lerpColor(info400, other.info400, t),
      info300: _lerpColor(info300, other.info300, t),
      info200: _lerpColor(info200, other.info200, t),
      info100: _lerpColor(info100, other.info100, t),
      info50: _lerpColor(info50, other.info50, t),
      info0: _lerpColor(info0, other.info0, t),

      // Tag Colors
      tagPurple: _lerpColor(tagPurple, other.tagPurple, t),
      tagRose: _lerpColor(tagRose, other.tagRose, t),
      tagLime: _lerpColor(tagLime, other.tagLime, t),
      tagOrange: _lerpColor(tagOrange, other.tagOrange, t),
      tagTeal: _lerpColor(tagTeal, other.tagTeal, t),
      tagMagenta: _lerpColor(tagMagenta, other.tagMagenta, t),
      tagAmber: _lerpColor(tagAmber, other.tagAmber, t),
      tagBurgundy: _lerpColor(tagBurgundy, other.tagBurgundy, t),
      tagBrown: _lerpColor(tagBrown, other.tagBrown, t),
    );
  }

  static Color _lerpColor(Color begin, Color end, double t) {
    return Color.lerp(begin, end, t)!;
  }

  // Theme Resolver
  static CustomAppColors of(BuildContext context) {
    final theme = Theme.of(context);

    final customColors = theme.extension<CustomAppColors>();

    if (customColors != null) {
      return customColors;
    }

    if (theme.brightness == Brightness.dark) {
      return CustomAppColors.dark();
    } else {
      return CustomAppColors.light();
    }
  }
}
