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
    this.enableScaleAnimation = true,
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
  final bool enableScaleAnimation;

  bool get _isClickable => buttonEnabled && onPressed != null && !isLoading;

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

    final pressedScale = enableScaleAnimation ? 0.95 : 1.0;
    const duration = Duration(milliseconds: 100);

    return Semantics(
      button: true,
      enabled: _isClickable,
      label: title,
      child: _BouncingButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        onPressWhenDisabled: onPressWhenDisabled,
        isClickable: _isClickable,
        enableScaleAnimation: enableScaleAnimation,
        enableHapticFeedback: enableHapticFeedback,
        pressedScale: pressedScale,
        duration: duration,
        builder:
            (
              context,
              handleTap,
              handleLongPress,
              handleTapDown,
              handleTapUp,
              handleTapCancel,
            ) {
              return Container(
                margin: buttonMargin,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: buttonBorder,
                ),
                clipBehavior: buttonBorder != null ? Clip.antiAlias : Clip.none,
                child: Material(
                  color: effectiveBackground,
                  borderRadius: radius,
                  child: InkWell(
                    onTap: handleTap,
                    onLongPress: handleLongPress,
                    onTapDown: handleTapDown,
                    onTapUp: handleTapUp,
                    onTapCancel: handleTapCancel,
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
                                              fontSize:
                                                  titleFontSize ?? 14.font,
                                              fontWeight:
                                                  titleFontWeight ??
                                                  FontWeight.w500,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign:
                                            titleTextAlign ?? TextAlign.center,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
      ),
    );
  }
}

class _BouncingButton extends StatefulWidget {
  const _BouncingButton({
    required this.builder,
    required this.onPressed,
    this.onLongPress,
    this.onPressWhenDisabled,
    required this.isClickable,
    required this.enableScaleAnimation,
    required this.enableHapticFeedback,
    required this.pressedScale,
    required this.duration,
  });

  final Widget Function(
    BuildContext context,
    VoidCallback handleTap,
    VoidCallback? handleLongPress,
    GestureTapDownCallback handleTapDown,
    GestureTapUpCallback handleTapUp,
    VoidCallback handleTapCancel,
  )
  builder;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final VoidCallback? onPressWhenDisabled;
  final bool isClickable;
  final bool enableScaleAnimation;
  final bool enableHapticFeedback;
  final double pressedScale;
  final Duration duration;

  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressedScale)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(covariant _BouncingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _controller.reverseDuration = widget.duration;
    }

    if (oldWidget.pressedScale != widget.pressedScale) {
      _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressedScale)
          .animate(
            CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut,
              reverseCurve: Curves.easeOutCubic,
            ),
          );
    }

    if (!widget.enableScaleAnimation || !widget.isClickable) {
      if (_controller.value != 0.0) {
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enableScaleAnimation || !widget.isClickable) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enableScaleAnimation || !widget.isClickable) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enableScaleAnimation || !widget.isClickable) return;
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.isClickable) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.selectionClick();
      }

      if (widget.enableScaleAnimation) {
        _controller.forward().then((_) {
          if (mounted) {
            _controller.reverse();
          }
        });
      }

      widget.onPressed?.call();
    } else {
      widget.onPressWhenDisabled?.call();
    }
  }

  void _handleLongPress() {
    if (widget.isClickable) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.heavyImpact();
      }

      widget.onLongPress?.call();
    } else {
      widget.onPressWhenDisabled?.call();
    }
  }

  VoidCallback? get _longPressCallback {
    if (widget.isClickable) {
      return widget.onLongPress != null ? _handleLongPress : null;
    }

    return widget.onPressWhenDisabled != null ? _handleLongPress : null;
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(
      context,
      _handleTap,
      _longPressCallback,
      _handleTapDown,
      _handleTapUp,
      _handleTapCancel,
    );

    if (widget.enableScaleAnimation) {
      return ScaleTransition(scale: _scaleAnimation, child: child);
    }

    return child;
  }
}
