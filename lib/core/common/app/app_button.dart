import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helpers/dimensions_helper.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_loading_indicator.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.height,
    this.width,
    this.radius,
    this.fontSize,
    this.loaderSize,
    this.color,
    this.disabledColor,
    this.textColor,
    this.loaderColor,
    this.fontWeight,
    this.textAlign,
    this.textStyle,
    this.boxBorder,
    this.padding,
    this.margin,
    this.widget,
    this.isLoading = false,
    this.enabled = true,
    this.onPressed,
  });

  final String text;
  final double? height;
  final double? width;
  final double? radius;
  final double? fontSize;
  final double? loaderSize;
  final Color? color;
  final Color? disabledColor;
  final Color? textColor;
  final Color? loaderColor;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final BoxBorder? boxBorder;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? widget;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onPressed;

  bool get _isClickable => enabled && onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    final Color backgroundColor = color ?? colors.primary600;

    final Color baseDisabledColor =
        disabledColor ?? backgroundColor.withValues(alpha: 0.35);

    final Color baseTextColor = textColor ?? colors.neutral0;

    return AbsorbPointer(
      absorbing: isLoading,
      child: CupertinoButton(
        onPressed: _isClickable ? onPressed : null,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: Opacity(
          opacity: enabled ? 1 : 0.7,
          child: Container(
            height: height ?? 48.height,
            width: width ?? double.infinity,
            padding: padding ?? EdgeInsets.symmetric(horizontal: 12.radius),
            margin: margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius ?? 16.radius),
              border: boxBorder,
              color: backgroundColor == Colors.transparent
                  ? Colors.transparent
                  : _isClickable
                  ? backgroundColor
                  : baseDisabledColor,
            ),
            child: isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.radius),
                      child: AppLoadingIndicator(
                        color: loaderColor ?? baseTextColor,
                        size: loaderSize ?? 28.radius,
                      ),
                    ),
                  )
                : Center(
                    child:
                        widget ??
                        Text(
                          text,
                          style:
                              textStyle ??
                              context.f14m.copyWith(
                                color: baseTextColor,
                                fontSize: fontSize ?? 14.font,
                                fontWeight: fontWeight ?? FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: textAlign ?? TextAlign.center,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
