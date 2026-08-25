import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/dimensions_helper.dart';
import '../theme_manager/theme_extensions.dart';
import 'app_fonts.dart';
import 'app_language.dart';
import 'font_weight_helper.dart';

class AppTextStyle {
  const AppTextStyle._();

  // Test Base Style
  static TextStyle _base(BuildContext context) {
    final isArabic = context.locale.languageCode == AppLanguage.arCode;

    return TextStyle(
      fontFamily: AppFonts.getFontFamily(context),
      fontFamilyFallback: AppFonts.fallbackFonts,
      letterSpacing: isArabic ? 0.0 : 0.5,
      height: isArabic ? 1.35 : null,
      leadingDistribution: TextLeadingDistribution.even,
      color: context.customAppColors.neutral950,
    );
  }

  // Test Style Factory
  static TextStyle _style(
    BuildContext context, {
    required double size,
    required FontWeight weight,
  }) {
    return _base(context).copyWith(fontSize: size.font, fontWeight: weight);
  }

  // Font 10
  static TextStyle f10Regular(BuildContext context) =>
      _style(context, size: 10, weight: FontWeightHelper.regular);

  static TextStyle f10Medium(BuildContext context) =>
      _style(context, size: 10, weight: FontWeightHelper.medium);

  static TextStyle f10SemiBold(BuildContext context) =>
      _style(context, size: 10, weight: FontWeightHelper.semiBold);

  static TextStyle f10Bold(BuildContext context) =>
      _style(context, size: 10, weight: FontWeightHelper.bold);

  // Font 12
  static TextStyle f12Regular(BuildContext context) =>
      _style(context, size: 12, weight: FontWeightHelper.regular);

  static TextStyle f12Medium(BuildContext context) =>
      _style(context, size: 12, weight: FontWeightHelper.medium);

  static TextStyle f12SemiBold(BuildContext context) =>
      _style(context, size: 12, weight: FontWeightHelper.semiBold);

  static TextStyle f12Bold(BuildContext context) =>
      _style(context, size: 12, weight: FontWeightHelper.bold);

  // Font 14
  static TextStyle f14Regular(BuildContext context) =>
      _style(context, size: 14, weight: FontWeightHelper.regular);

  static TextStyle f14Medium(BuildContext context) =>
      _style(context, size: 14, weight: FontWeightHelper.medium);

  static TextStyle f14SemiBold(BuildContext context) =>
      _style(context, size: 14, weight: FontWeightHelper.semiBold);

  static TextStyle f14Bold(BuildContext context) =>
      _style(context, size: 14, weight: FontWeightHelper.bold);

  // Font 16
  static TextStyle f16Regular(BuildContext context) =>
      _style(context, size: 16, weight: FontWeightHelper.regular);

  static TextStyle f16Medium(BuildContext context) =>
      _style(context, size: 16, weight: FontWeightHelper.medium);

  static TextStyle f16SemiBold(BuildContext context) =>
      _style(context, size: 16, weight: FontWeightHelper.semiBold);

  static TextStyle f16Bold(BuildContext context) =>
      _style(context, size: 16, weight: FontWeightHelper.bold);

  // Font 18
  static TextStyle f18Regular(BuildContext context) =>
      _style(context, size: 18, weight: FontWeightHelper.regular);

  static TextStyle f18Medium(BuildContext context) =>
      _style(context, size: 18, weight: FontWeightHelper.medium);

  static TextStyle f18SemiBold(BuildContext context) =>
      _style(context, size: 18, weight: FontWeightHelper.semiBold);

  static TextStyle f18Bold(BuildContext context) =>
      _style(context, size: 18, weight: FontWeightHelper.bold);

  // Font 20
  static TextStyle f20Regular(BuildContext context) =>
      _style(context, size: 20, weight: FontWeightHelper.regular);

  static TextStyle f20Medium(BuildContext context) =>
      _style(context, size: 20, weight: FontWeightHelper.medium);

  static TextStyle f20SemiBold(BuildContext context) =>
      _style(context, size: 20, weight: FontWeightHelper.semiBold);

  static TextStyle f20Bold(BuildContext context) =>
      _style(context, size: 20, weight: FontWeightHelper.bold);

  // Font 22
  static TextStyle f22Regular(BuildContext context) =>
      _style(context, size: 22, weight: FontWeightHelper.regular);

  static TextStyle f22Medium(BuildContext context) =>
      _style(context, size: 22, weight: FontWeightHelper.medium);

  static TextStyle f22SemiBold(BuildContext context) =>
      _style(context, size: 22, weight: FontWeightHelper.semiBold);

  static TextStyle f22Bold(BuildContext context) =>
      _style(context, size: 22, weight: FontWeightHelper.bold);

  // Font 24
  static TextStyle f24Regular(BuildContext context) =>
      _style(context, size: 24, weight: FontWeightHelper.regular);

  static TextStyle f24Medium(BuildContext context) =>
      _style(context, size: 24, weight: FontWeightHelper.medium);

  static TextStyle f24SemiBold(BuildContext context) =>
      _style(context, size: 24, weight: FontWeightHelper.semiBold);

  static TextStyle f24Bold(BuildContext context) =>
      _style(context, size: 24, weight: FontWeightHelper.bold);

  // Font 26
  static TextStyle f26Regular(BuildContext context) =>
      _style(context, size: 26, weight: FontWeightHelper.regular);

  static TextStyle f26Medium(BuildContext context) =>
      _style(context, size: 26, weight: FontWeightHelper.medium);

  static TextStyle f26SemiBold(BuildContext context) =>
      _style(context, size: 26, weight: FontWeightHelper.semiBold);

  static TextStyle f26Bold(BuildContext context) =>
      _style(context, size: 26, weight: FontWeightHelper.bold);

  // Font 28
  static TextStyle f28Regular(BuildContext context) =>
      _style(context, size: 28, weight: FontWeightHelper.regular);

  static TextStyle f28Medium(BuildContext context) =>
      _style(context, size: 28, weight: FontWeightHelper.medium);

  static TextStyle f28SemiBold(BuildContext context) =>
      _style(context, size: 28, weight: FontWeightHelper.semiBold);

  static TextStyle f28Bold(BuildContext context) =>
      _style(context, size: 28, weight: FontWeightHelper.bold);

  // Font 30
  static TextStyle f30Regular(BuildContext context) =>
      _style(context, size: 30, weight: FontWeightHelper.regular);

  static TextStyle f30Medium(BuildContext context) =>
      _style(context, size: 30, weight: FontWeightHelper.medium);

  static TextStyle f30SemiBold(BuildContext context) =>
      _style(context, size: 30, weight: FontWeightHelper.semiBold);

  static TextStyle f30Bold(BuildContext context) =>
      _style(context, size: 30, weight: FontWeightHelper.bold);

  // Font 32
  static TextStyle f32Regular(BuildContext context) =>
      _style(context, size: 32, weight: FontWeightHelper.regular);

  static TextStyle f32Medium(BuildContext context) =>
      _style(context, size: 32, weight: FontWeightHelper.medium);

  static TextStyle f32SemiBold(BuildContext context) =>
      _style(context, size: 32, weight: FontWeightHelper.semiBold);

  static TextStyle f32Bold(BuildContext context) =>
      _style(context, size: 32, weight: FontWeightHelper.bold);

  // Font 34
  static TextStyle f34Regular(BuildContext context) =>
      _style(context, size: 34, weight: FontWeightHelper.regular);

  static TextStyle f34Medium(BuildContext context) =>
      _style(context, size: 34, weight: FontWeightHelper.medium);

  static TextStyle f34SemiBold(BuildContext context) =>
      _style(context, size: 34, weight: FontWeightHelper.semiBold);

  static TextStyle f34Bold(BuildContext context) =>
      _style(context, size: 34, weight: FontWeightHelper.bold);

  // Font 36
  static TextStyle f36Regular(BuildContext context) =>
      _style(context, size: 36, weight: FontWeightHelper.regular);

  static TextStyle f36Medium(BuildContext context) =>
      _style(context, size: 36, weight: FontWeightHelper.medium);

  static TextStyle f36SemiBold(BuildContext context) =>
      _style(context, size: 36, weight: FontWeightHelper.semiBold);

  static TextStyle f36Bold(BuildContext context) =>
      _style(context, size: 36, weight: FontWeightHelper.bold);

  // Font 38
  static TextStyle f38Regular(BuildContext context) =>
      _style(context, size: 38, weight: FontWeightHelper.regular);

  static TextStyle f38Medium(BuildContext context) =>
      _style(context, size: 38, weight: FontWeightHelper.medium);

  static TextStyle f38SemiBold(BuildContext context) =>
      _style(context, size: 38, weight: FontWeightHelper.semiBold);

  static TextStyle f38Bold(BuildContext context) =>
      _style(context, size: 38, weight: FontWeightHelper.bold);

  // Font 40
  static TextStyle f40Regular(BuildContext context) =>
      _style(context, size: 40, weight: FontWeightHelper.regular);

  static TextStyle f40Medium(BuildContext context) =>
      _style(context, size: 40, weight: FontWeightHelper.medium);

  static TextStyle f40SemiBold(BuildContext context) =>
      _style(context, size: 40, weight: FontWeightHelper.semiBold);

  static TextStyle f40Bold(BuildContext context) =>
      _style(context, size: 40, weight: FontWeightHelper.bold);

  // Font 42
  static TextStyle f42Regular(BuildContext context) =>
      _style(context, size: 42, weight: FontWeightHelper.regular);

  static TextStyle f42Medium(BuildContext context) =>
      _style(context, size: 42, weight: FontWeightHelper.medium);

  static TextStyle f42SemiBold(BuildContext context) =>
      _style(context, size: 42, weight: FontWeightHelper.semiBold);

  static TextStyle f42Bold(BuildContext context) =>
      _style(context, size: 42, weight: FontWeightHelper.bold);

  // Font 44
  static TextStyle f44Regular(BuildContext context) =>
      _style(context, size: 44, weight: FontWeightHelper.regular);

  static TextStyle f44Medium(BuildContext context) =>
      _style(context, size: 44, weight: FontWeightHelper.medium);

  static TextStyle f44SemiBold(BuildContext context) =>
      _style(context, size: 44, weight: FontWeightHelper.semiBold);

  static TextStyle f44Bold(BuildContext context) =>
      _style(context, size: 44, weight: FontWeightHelper.bold);

  // Font 46
  static TextStyle f46Regular(BuildContext context) =>
      _style(context, size: 46, weight: FontWeightHelper.regular);

  static TextStyle f46Medium(BuildContext context) =>
      _style(context, size: 46, weight: FontWeightHelper.medium);

  static TextStyle f46SemiBold(BuildContext context) =>
      _style(context, size: 46, weight: FontWeightHelper.semiBold);

  static TextStyle f46Bold(BuildContext context) =>
      _style(context, size: 46, weight: FontWeightHelper.bold);

  // Font 48
  static TextStyle f48Regular(BuildContext context) =>
      _style(context, size: 48, weight: FontWeightHelper.regular);

  static TextStyle f48Medium(BuildContext context) =>
      _style(context, size: 48, weight: FontWeightHelper.medium);

  static TextStyle f48SemiBold(BuildContext context) =>
      _style(context, size: 48, weight: FontWeightHelper.semiBold);

  static TextStyle f48Bold(BuildContext context) =>
      _style(context, size: 48, weight: FontWeightHelper.bold);

  // Font 50
  static TextStyle f50Regular(BuildContext context) =>
      _style(context, size: 50, weight: FontWeightHelper.regular);

  static TextStyle f50Medium(BuildContext context) =>
      _style(context, size: 50, weight: FontWeightHelper.medium);

  static TextStyle f50SemiBold(BuildContext context) =>
      _style(context, size: 50, weight: FontWeightHelper.semiBold);

  static TextStyle f50Bold(BuildContext context) =>
      _style(context, size: 50, weight: FontWeightHelper.bold);
}

// App Text Styles Extension
extension AppTextStyleExtension on BuildContext {
  // Font 10
  TextStyle get f10r => AppTextStyle.f10Regular(this);
  TextStyle get f10m => AppTextStyle.f10Medium(this);
  TextStyle get f10sb => AppTextStyle.f10SemiBold(this);
  TextStyle get f10b => AppTextStyle.f10Bold(this);

  // Font 12
  TextStyle get f12r => AppTextStyle.f12Regular(this);
  TextStyle get f12m => AppTextStyle.f12Medium(this);
  TextStyle get f12sb => AppTextStyle.f12SemiBold(this);
  TextStyle get f12b => AppTextStyle.f12Bold(this);

  // Font 14
  TextStyle get f14r => AppTextStyle.f14Regular(this);
  TextStyle get f14m => AppTextStyle.f14Medium(this);
  TextStyle get f14sb => AppTextStyle.f14SemiBold(this);
  TextStyle get f14b => AppTextStyle.f14Bold(this);

  // Font 16
  TextStyle get f16r => AppTextStyle.f16Regular(this);
  TextStyle get f16m => AppTextStyle.f16Medium(this);
  TextStyle get f16sb => AppTextStyle.f16SemiBold(this);
  TextStyle get f16b => AppTextStyle.f16Bold(this);

  // Font 18
  TextStyle get f18r => AppTextStyle.f18Regular(this);
  TextStyle get f18m => AppTextStyle.f18Medium(this);
  TextStyle get f18sb => AppTextStyle.f18SemiBold(this);
  TextStyle get f18b => AppTextStyle.f18Bold(this);

  // Font 20
  TextStyle get f20r => AppTextStyle.f20Regular(this);
  TextStyle get f20m => AppTextStyle.f20Medium(this);
  TextStyle get f20sb => AppTextStyle.f20SemiBold(this);
  TextStyle get f20b => AppTextStyle.f20Bold(this);

  // Font 22
  TextStyle get f22r => AppTextStyle.f22Regular(this);
  TextStyle get f22m => AppTextStyle.f22Medium(this);
  TextStyle get f22sb => AppTextStyle.f22SemiBold(this);
  TextStyle get f22b => AppTextStyle.f22Bold(this);

  // Font 24
  TextStyle get f24r => AppTextStyle.f24Regular(this);
  TextStyle get f24m => AppTextStyle.f24Medium(this);
  TextStyle get f24sb => AppTextStyle.f24SemiBold(this);
  TextStyle get f24b => AppTextStyle.f24Bold(this);

  // Font 26
  TextStyle get f26r => AppTextStyle.f26Regular(this);
  TextStyle get f26m => AppTextStyle.f26Medium(this);
  TextStyle get f26sb => AppTextStyle.f26SemiBold(this);
  TextStyle get f26b => AppTextStyle.f26Bold(this);

  // Font 28
  TextStyle get f28r => AppTextStyle.f28Regular(this);
  TextStyle get f28m => AppTextStyle.f28Medium(this);
  TextStyle get f28sb => AppTextStyle.f28SemiBold(this);
  TextStyle get f28b => AppTextStyle.f28Bold(this);

  // Font 30
  TextStyle get f30r => AppTextStyle.f30Regular(this);
  TextStyle get f30m => AppTextStyle.f30Medium(this);
  TextStyle get f30sb => AppTextStyle.f30SemiBold(this);
  TextStyle get f30b => AppTextStyle.f30Bold(this);

  // Font 32
  TextStyle get f32r => AppTextStyle.f32Regular(this);
  TextStyle get f32m => AppTextStyle.f32Medium(this);
  TextStyle get f32sb => AppTextStyle.f32SemiBold(this);
  TextStyle get f32b => AppTextStyle.f32Bold(this);

  // Font 34
  TextStyle get f34r => AppTextStyle.f34Regular(this);
  TextStyle get f34m => AppTextStyle.f34Medium(this);
  TextStyle get f34sb => AppTextStyle.f34SemiBold(this);
  TextStyle get f34b => AppTextStyle.f34Bold(this);

  // Font 36
  TextStyle get f36r => AppTextStyle.f36Regular(this);
  TextStyle get f36m => AppTextStyle.f36Medium(this);
  TextStyle get f36sb => AppTextStyle.f36SemiBold(this);
  TextStyle get f36b => AppTextStyle.f36Bold(this);

  // Font 38
  TextStyle get f38r => AppTextStyle.f38Regular(this);
  TextStyle get f38m => AppTextStyle.f38Medium(this);
  TextStyle get f38sb => AppTextStyle.f38SemiBold(this);
  TextStyle get f38b => AppTextStyle.f38Bold(this);

  // Font 40
  TextStyle get f40r => AppTextStyle.f40Regular(this);
  TextStyle get f40m => AppTextStyle.f40Medium(this);
  TextStyle get f40sb => AppTextStyle.f40SemiBold(this);
  TextStyle get f40b => AppTextStyle.f40Bold(this);

  // Font 42
  TextStyle get f42r => AppTextStyle.f42Regular(this);
  TextStyle get f42m => AppTextStyle.f42Medium(this);
  TextStyle get f42sb => AppTextStyle.f42SemiBold(this);
  TextStyle get f42b => AppTextStyle.f42Bold(this);

  // Font 44
  TextStyle get f44r => AppTextStyle.f44Regular(this);
  TextStyle get f44m => AppTextStyle.f44Medium(this);
  TextStyle get f44sb => AppTextStyle.f44SemiBold(this);
  TextStyle get f44b => AppTextStyle.f44Bold(this);

  // Font 46
  TextStyle get f46r => AppTextStyle.f46Regular(this);
  TextStyle get f46m => AppTextStyle.f46Medium(this);
  TextStyle get f46sb => AppTextStyle.f46SemiBold(this);
  TextStyle get f46b => AppTextStyle.f46Bold(this);

  // Font 48
  TextStyle get f48r => AppTextStyle.f48Regular(this);
  TextStyle get f48m => AppTextStyle.f48Medium(this);
  TextStyle get f48sb => AppTextStyle.f48SemiBold(this);
  TextStyle get f48b => AppTextStyle.f48Bold(this);

  // Font 50
  TextStyle get f50r => AppTextStyle.f50Regular(this);
  TextStyle get f50m => AppTextStyle.f50Medium(this);
  TextStyle get f50sb => AppTextStyle.f50SemiBold(this);
  TextStyle get f50b => AppTextStyle.f50Bold(this);
}
