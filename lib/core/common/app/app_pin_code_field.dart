import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';

class AppPinCodeField extends StatefulWidget {
  const AppPinCodeField({
    super.key,
    required this.controller,
    this.focusNode,
    this.length = 4,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.autoValidate = true,
    this.showCursor = true,
    this.validator,
    this.onChanged,
    this.onCompleted,
    this.onTap,
    this.itemWidth,
    this.itemHeight,
    this.spacing,
    this.borderRadius,
    this.borderWidth,
    this.backgroundColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.submittedBorderColor,
    this.errorBorderColor,
    this.cursorColor,
    this.textStyle,
    this.errorTextStyle,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final int length;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final bool autoValidate;
  final bool showCursor;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final VoidCallback? onTap;
  final double? itemWidth;
  final double? itemHeight;
  final double? spacing;
  final double? borderRadius;
  final double? borderWidth;
  final Color? backgroundColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? submittedBorderColor;
  final Color? errorBorderColor;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final TextStyle? errorTextStyle;

  @override
  State<AppPinCodeField> createState() => _AppPinCodeFieldState();
}

class _AppPinCodeFieldState extends State<AppPinCodeField> {
  bool _hasInteracted = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_handleValidation);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleValidation);
    super.dispose();
  }

  void _handleValidation() {
    if (!widget.autoValidate || !_hasInteracted) {
      return;
    }

    final error = widget.validator?.call(widget.controller.text);

    if (error != _errorText) {
      setState(() {
        _errorText = error;
      });
    }
  }

  void _onChanged(String value) {
    if (!_hasInteracted) {
      setState(() {
        _hasInteracted = true;
      });
    }

    widget.onChanged?.call(value);

    if (widget.autoValidate) {
      _handleValidation();
    }

    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    final enabledColor = widget.enabledBorderColor ?? colors.neutral300;

    final focusedColor = widget.focusedBorderColor ?? colors.primary600;

    final submittedColor = widget.submittedBorderColor ?? colors.primary600;

    final errorColor = widget.errorBorderColor ?? colors.danger600;

    final hasError =
        widget.autoValidate && _hasInteracted && _errorText != null;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        controller: widget.controller,
        focusNode: widget.focusNode,

        length: widget.length,

        enabled: widget.enabled,
        autofocus: widget.autofocus,

        obscureText: widget.obscureText,

        keyboardType: TextInputType.number,

        inputFormatters: [FilteringTextInputFormatter.digitsOnly],

        showCursor: widget.showCursor,

        cursor: Container(
          width: 2.width,
          height: 24.height,
          decoration: BoxDecoration(
            color: widget.cursorColor ?? focusedColor,
            borderRadius: BorderRadius.circular(2.radius),
          ),
        ),

        hapticFeedbackType: HapticFeedbackType.lightImpact,

        separatorBuilder: (_) {
          return horizontalGap(widget.spacing ?? 12);
        },

        onTap: widget.onTap,

        onChanged: _onChanged,

        forceErrorState: hasError,

        errorText: _errorText,

        validator: widget.validator,

        pinputAutovalidateMode: widget.autoValidate
            ? PinputAutovalidateMode.onSubmit
            : PinputAutovalidateMode.disabled,

        defaultPinTheme: _buildTheme(context, borderColor: enabledColor),

        focusedPinTheme: _buildTheme(context, borderColor: focusedColor),

        submittedPinTheme: _buildTheme(context, borderColor: submittedColor),

        errorPinTheme: _buildTheme(context, borderColor: errorColor),

        errorBuilder: (errorText, pin) {
          if (errorText == null) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: EdgeInsets.only(top: 8.height),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                errorText,
                textAlign: TextAlign.center,
                style:
                    widget.errorTextStyle ??
                    context.f14r.copyWith(color: errorColor),
              ),
            ),
          );
        },
      ),
    );
  }

  PinTheme _buildTheme(BuildContext context, {required Color borderColor}) {
    final colors = context.customAppColors;

    return PinTheme(
      width: widget.itemWidth ?? 56.radius,
      height: widget.itemHeight ?? 56.radius,

      textStyle: widget.textStyle ?? context.f18sb,

      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colors.neutral50,

        borderRadius: BorderRadius.circular(widget.borderRadius ?? 14.radius),

        border: Border.all(
          color: borderColor,
          width: widget.borderWidth ?? 1.4.width,
        ),
      ),
    );
  }
}
