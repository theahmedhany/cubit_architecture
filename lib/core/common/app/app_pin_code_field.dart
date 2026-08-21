import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/media_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';

class AppPinCodeField extends StatefulWidget {
  const AppPinCodeField({
    super.key,
    this.title,
    this.helperText,
    this.controller,
    this.focusNode,
    this.length = 4,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.withTitle = false,
    this.isRequired = false,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.obscuringWidget,
    this.autoValidate = true,
    this.showCursor = true,
    this.keyboardType = TextInputType.number,
    this.textInputAction,
    this.inputFormatters,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.pinAnimationType = PinAnimationType.scale,
    this.animationDuration = const Duration(milliseconds: 180),
    this.hapticFeedbackType = HapticFeedbackType.lightImpact,
    this.validator,
    this.onTap,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    this.itemWidth,
    this.itemHeight,
    this.spacing,
    this.borderRadius,
    this.borderWidth,
    this.focusedBorderWidth,
    this.backgroundColor,
    this.focusedBackgroundColor,
    this.disabledBackgroundColor,
    this.titleColor,
    this.cursorColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.submittedBorderColor,
    this.errorBorderColor,
    this.disabledBorderColor,
    this.crossAxisAlignment,
    this.textStyle,
    this.titleTextStyle,
    this.helperTextStyle,
    this.errorTextStyle,
    this.errorMaxLines = 2,
    this.helperMaxLines = 2,
  });

  final String? title;
  final String? helperText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int length;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool withTitle;
  final bool isRequired;
  final bool obscureText;
  final String obscuringCharacter;
  final Widget? obscuringWidget;
  final bool autoValidate;
  final bool showCursor;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final PinAnimationType pinAnimationType;
  final Duration animationDuration;
  final HapticFeedbackType hapticFeedbackType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onSubmitted;
  final double? itemWidth;
  final double? itemHeight;
  final double? spacing;
  final double? borderRadius;
  final double? borderWidth;
  final double? focusedBorderWidth;
  final Color? backgroundColor;
  final Color? focusedBackgroundColor;
  final Color? disabledBackgroundColor;
  final Color? titleColor;
  final Color? cursorColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? submittedBorderColor;
  final Color? errorBorderColor;
  final Color? disabledBorderColor;
  final TextStyle? textStyle;
  final TextStyle? titleTextStyle;
  final TextStyle? helperTextStyle;
  final TextStyle? errorTextStyle;
  final int errorMaxLines;
  final int helperMaxLines;

  @override
  State<AppPinCodeField> createState() => _AppPinCodeFieldState();
}

class _AppPinCodeFieldState extends State<AppPinCodeField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;
  late final bool _ownsFocusNode;
  bool _hasInteracted = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();

    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_handleValidation);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleValidation);

    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _handleValidation() {
    if (!widget.autoValidate || !_hasInteracted) {
      return;
    }

    final error = widget.validator?.call(_controller.text);

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
    final submittedColor = widget.submittedBorderColor ?? enabledColor;
    final errorColor = widget.errorBorderColor ?? colors.danger600;
    final disabledColor = widget.disabledBorderColor ?? colors.neutral200;

    final double standardBorderWidth = widget.borderWidth ?? 1.1.width;
    final double activeFocusedBorderWidth =
        widget.focusedBorderWidth ?? 1.7.width;

    final hasError =
        widget.autoValidate && _hasInteracted && _errorText != null;

    final defaultTheme = _buildTheme(
      context,
      borderColor: enabledColor,
      fillColor: widget.backgroundColor ?? colors.neutral50,
      textColor: colors.neutral950,
      borderWidth: standardBorderWidth,
    );

    final focusedTheme = _buildTheme(
      context,
      borderColor: focusedColor,
      fillColor:
          widget.focusedBackgroundColor ??
          widget.backgroundColor ??
          colors.neutral50,
      textColor: colors.neutral950,
      borderWidth: activeFocusedBorderWidth,
    );

    final submittedTheme = _buildTheme(
      context,
      borderColor: submittedColor,
      fillColor: widget.backgroundColor ?? colors.neutral50,
      textColor: colors.neutral950,
      borderWidth: standardBorderWidth,
    );

    final errorTheme = _buildTheme(
      context,
      borderColor: errorColor,
      fillColor: widget.backgroundColor ?? colors.neutral50,
      textColor: colors.danger600,
      borderWidth: standardBorderWidth,
    );

    final focusedErrorTheme = _buildTheme(
      context,
      borderColor: errorColor,
      fillColor:
          widget.focusedBackgroundColor ??
          widget.backgroundColor ??
          colors.neutral50,
      textColor: colors.danger600,
      borderWidth: activeFocusedBorderWidth,
    );

    final disabledTheme = _buildTheme(
      context,
      borderColor: disabledColor,
      fillColor: widget.disabledBackgroundColor ?? colors.neutral100,
      textColor: colors.neutral400,
      borderWidth: widget.borderWidth ?? 1.0.width,
    );

    final effectiveCrossAlign =
        widget.crossAxisAlignment ?? CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: effectiveCrossAlign,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.withTitle && widget.title != null) ...[
          _TitleSection(
            title: widget.title!,
            isRequired: widget.isRequired,
            titleColor: widget.titleColor,
            titleTextStyle: widget.titleTextStyle,
          ),

          verticalGap(8),
        ],

        Directionality(
          textDirection: TextDirection.ltr,
          child: Pinput(
            controller: _controller,
            focusNode: _focusNode,
            length: widget.length,

            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,

            obscureText: widget.obscureText,
            obscuringCharacter: widget.obscuringCharacter,
            obscuringWidget: widget.obscuringWidget,

            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters:
                widget.inputFormatters ??
                [FilteringTextInputFormatter.digitsOnly],

            showCursor: widget.showCursor,
            cursor: Container(
              width: 2.width,
              height: 24.height,
              decoration: BoxDecoration(
                color:
                    widget.cursorColor ??
                    (hasError ? errorColor : focusedColor),
                borderRadius: BorderRadius.circular(2.radius),
              ),
            ),

            mainAxisAlignment: widget.mainAxisAlignment,
            pinAnimationType: widget.pinAnimationType,
            animationDuration: widget.animationDuration,
            hapticFeedbackType: widget.hapticFeedbackType,

            separatorBuilder: (_) {
              return horizontalGap(widget.spacing ?? 10.width);
            },

            onTap: widget.onTap,
            onChanged: _onChanged,
            onCompleted: widget.onCompleted,
            onSubmitted: widget.onSubmitted,
            onTapOutside: (_) => MediaHelper.dismissKeyboard(context),

            defaultPinTheme: hasError ? errorTheme : defaultTheme,
            focusedPinTheme: hasError ? focusedErrorTheme : focusedTheme,
            followingPinTheme: hasError ? errorTheme : defaultTheme,
            submittedPinTheme: hasError ? errorTheme : submittedTheme,
            disabledPinTheme: disabledTheme,
          ),
        ),

        if (hasError) ...[
          verticalGap(8),

          Align(
            alignment: Alignment.center,
            child: Text(
              _errorText!,
              textAlign: TextAlign.center,
              maxLines: widget.errorMaxLines,
              overflow: TextOverflow.ellipsis,
              style:
                  widget.errorTextStyle ??
                  context.f14r.copyWith(color: errorColor),
            ),
          ),
        ] else if (widget.helperText != null &&
            widget.helperText!.isNotEmpty) ...[
          verticalGap(8),

          Align(
            alignment: Alignment.center,
            child: Text(
              widget.helperText!,
              textAlign: TextAlign.center,
              maxLines: widget.helperMaxLines,
              overflow: TextOverflow.ellipsis,
              style:
                  widget.helperTextStyle ??
                  context.f12r.copyWith(color: colors.neutral400),
            ),
          ),
        ],
      ],
    );
  }

  PinTheme _buildTheme(
    BuildContext context, {
    required Color borderColor,
    required Color fillColor,
    required Color textColor,
    required double borderWidth,
  }) {
    return PinTheme(
      width: widget.itemWidth ?? 56.radius,
      height: widget.itemHeight ?? 56.radius,
      textStyle: (widget.textStyle ?? context.f18sb).copyWith(color: textColor),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 14.radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({
    required this.title,
    required this.isRequired,
    this.titleColor,
    this.titleTextStyle,
  });

  final String title;
  final bool isRequired;
  final Color? titleColor;
  final TextStyle? titleTextStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style:
                titleTextStyle ??
                context.f16sb.copyWith(color: titleColor ?? colors.neutral950),
          ),

          if (isRequired) ...[
            TextSpan(
              text: ' * ',
              style: context.f14r.copyWith(color: colors.danger600),
            ),
          ],
        ],
      ),
    );
  }
}
