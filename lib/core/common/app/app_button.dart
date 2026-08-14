import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helpers/dimensions_helper.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_loading_indicator.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    this.titleColor,
    this.titleFontSize,
    this.titleFontWeight,
    this.titleTextStyle,
    this.titleTextAlign,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonMargin,
    this.buttonRadius,
    this.buttonBorder,
    this.buttonEnabled = true,
    this.buttonColor,
    this.buttonDisabledColor,
    this.isLoading = false,
    this.loaderSize,
    this.loaderColor,
    this.widget,
    this.onPressed,
    this.onPressWhenDisabled,
    this.onLongPress,
    this.enableHapticFeedback = false,
  });

  final String title;
  final Color? titleColor;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final TextStyle? titleTextStyle;
  final TextAlign? titleTextAlign;
  final double? buttonHeight;
  final double? buttonWidth;
  final EdgeInsetsGeometry? buttonPadding;
  final EdgeInsetsGeometry? buttonMargin;
  final double? buttonRadius;
  final BoxBorder? buttonBorder;
  final bool buttonEnabled;
  final Color? buttonColor;
  final Color? buttonDisabledColor;
  final bool isLoading;
  final double? loaderSize;
  final Color? loaderColor;
  final Widget? widget;
  final VoidCallback? onPressed;
  final VoidCallback? onPressWhenDisabled;
  final VoidCallback? onLongPress;
  final bool enableHapticFeedback;

  bool get _isClickable => buttonEnabled && onPressed != null && !isLoading;

  void _handleTap() {
    if (_isClickable) {
      if (enableHapticFeedback) HapticFeedback.selectionClick();
      onPressed?.call();
    } else {
      onPressWhenDisabled?.call();
    }
  }

  void _handleLongPress() {
    if (_isClickable) {
      onLongPress?.call();
    } else {
      onPressWhenDisabled?.call();
    }
  }

  Color _overlayBaseColor({
    required Color lightBaseColor,
    required Color darkBaseColor,
    required Color textColor,
    required Color background,
  }) {
    if (background == Colors.transparent) return textColor;

    final bool isBgLight = background.computeLuminance() > 0.5;

    if (isBgLight) {
      return textColor.computeLuminance() > 0.5 ? lightBaseColor : textColor;
    }
    return textColor.computeLuminance() <= 0.5 ? darkBaseColor : textColor;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    final Color backgroundColor = buttonColor ?? colors.primary600;
    final bool isTransparentBg = backgroundColor == Colors.transparent;

    final Color disabledColor =
        buttonDisabledColor ?? backgroundColor.withValues(alpha: 0.4);

    final Color effectiveBackground = isTransparentBg
        ? Colors.transparent
        : _isClickable
        ? backgroundColor
        : disabledColor;

    final Color textColor = titleColor ?? colors.neutral0;

    final BorderRadius radius = BorderRadius.circular(
      buttonRadius ?? 12.radius,
    );

    final Color overlayBaseColor = _overlayBaseColor(
      lightBaseColor: colors.neutral900,
      darkBaseColor: colors.neutral0,
      textColor: textColor,
      background: effectiveBackground,
    );

    return Semantics(
      button: true,
      enabled: _isClickable,
      label: title,
      child: Container(
        margin: buttonMargin,
        decoration: BoxDecoration(borderRadius: radius, border: buttonBorder),
        clipBehavior: buttonBorder != null ? Clip.antiAlias : Clip.none,
        child: Material(
          color: effectiveBackground,
          borderRadius: radius,
          child: InkWell(
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            borderRadius: radius,
            splashFactory: InkRipple.splashFactory,
            splashColor: overlayBaseColor.withValues(alpha: 0.30),
            highlightColor: overlayBaseColor.withValues(alpha: 0.28),
            hoverColor: overlayBaseColor.withValues(alpha: 0.10),
            focusColor: overlayBaseColor.withValues(alpha: 0.16),

            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (!_isClickable) return Colors.transparent;
              if (states.contains(WidgetState.pressed)) {
                return overlayBaseColor.withValues(alpha: 0.34);
              }
              if (states.contains(WidgetState.hovered)) {
                return overlayBaseColor.withValues(alpha: 0.10);
              }
              if (states.contains(WidgetState.focused)) {
                return overlayBaseColor.withValues(alpha: 0.16);
              }
              return null;
            }),

            mouseCursor: _isClickable
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,

            child: SizedBox(
              height: buttonHeight ?? 48.height,
              width: buttonWidth ?? double.infinity,
              child: Padding(
                padding:
                    buttonPadding ??
                    EdgeInsets.symmetric(horizontal: 12.radius),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: isLoading
                      ? Center(
                          key: const ValueKey('loading'),
                          child: Padding(
                            padding: EdgeInsets.all(8.radius),
                            child: AppLoadingIndicator(
                              color: loaderColor ?? textColor,
                              size: loaderSize ?? 28.radius,
                            ),
                          ),
                        )
                      : Center(
                          key: const ValueKey('content'),
                          child:
                              widget ??
                              Text(
                                title,
                                style:
                                    titleTextStyle ??
                                    context.f14m.copyWith(
                                      color: textColor,
                                      fontSize: titleFontSize ?? 14.font,
                                      fontWeight:
                                          titleFontWeight ?? FontWeight.w500,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: titleTextAlign ?? TextAlign.center,
                              ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
