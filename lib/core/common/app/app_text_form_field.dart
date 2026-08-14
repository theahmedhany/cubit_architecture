import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../helpers/asset_helper.dart';
import '../../helpers/dimensions_helper.dart';
import '../../helpers/media_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    required this.hintText,
    this.title,
    this.helperText,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.inputTextStyle,
    this.hintStyle,
    this.titleTextStyle,
    this.helperTextStyle,
    this.errorTextStyle,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.disabledBorder,
    this.backgroundColor,
    this.focusedBackgroundColor,
    this.titleColor,
    this.cursorColor,
    this.suffixIconColor,
    this.suffixIcon,
    this.prefixIcon,
    this.prefix,
    this.prefixText,
    this.contentPadding,
    this.suffixIconConstraints,
    this.prefixIconConstraints,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.withTitle = false,
    this.isRequired = false,
    this.isPassword = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.errorMaxLines = 2,
    this.validator,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
  }) : assert(
         !isPassword || maxLines == 1,
         'isPassword fields must be single line; pass maxLines: 1 or omit it.',
       );

  final String? title;
  final String hintText;
  final String? helperText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? inputTextStyle;
  final TextStyle? hintStyle;
  final TextStyle? titleTextStyle;
  final TextStyle? helperTextStyle;
  final TextStyle? errorTextStyle;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final InputBorder? disabledBorder;
  final Color? backgroundColor;
  final Color? focusedBackgroundColor;
  final Color? titleColor;
  final Color? cursorColor;
  final Color? suffixIconColor;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefix;
  final String? prefixText;
  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool withTitle;
  final bool isRequired;
  final bool isPassword;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final int errorMaxLines;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late bool _obscureText;
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    _obscureText = widget.isPassword;
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPassword != oldWidget.isPassword) {
      _obscureText = widget.isPassword;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);

    if (_ownsFocusNode) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  void _handleFocusChange() {
    if (_hasFocus != _focusNode.hasFocus) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.withTitle) ...[
          _TitleSection(
            title: widget.title ?? widget.hintText,
            isRequired: widget.isRequired,
            titleColor: widget.titleColor,
            titleTextStyle: widget.titleTextStyle,
          ),

          verticalGap(6),
        ],

        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _focusNode,

          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,

          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,

          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,

          obscureText: _obscureText,
          obscuringCharacter: '•',

          validator: widget.validator,

          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,

          autovalidateMode: AutovalidateMode.onUserInteraction,
          onTapOutside: (_) => MediaHelper.dismissKeyboard(context),

          cursorColor: widget.cursorColor ?? colors.primary600,
          cursorRadius: const Radius.circular(8),
          cursorWidth: 2,

          style: (widget.inputTextStyle ?? context.f14r).copyWith(
            color: widget.enabled ? null : colors.neutral400,
          ),

          decoration: InputDecoration(
            hintText: widget.hintText,

            helperText: widget.helperText,
            helperMaxLines: 2,
            helperStyle:
                widget.helperTextStyle ??
                context.f12r.copyWith(color: colors.neutral400),

            errorMaxLines: widget.errorMaxLines,
            errorStyle:
                widget.errorTextStyle ??
                context.f12r.copyWith(color: colors.danger600),

            counterText: widget.maxLength == null ? '' : null,

            filled: true,
            fillColor: _hasFocus
                ? (widget.focusedBackgroundColor ??
                      widget.backgroundColor ??
                      colors.neutral50)
                : (widget.backgroundColor ?? colors.neutral50),

            isDense: true,

            contentPadding:
                widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 14.width, vertical: 14.height),

            hintStyle:
                widget.hintStyle ??
                context.f14r.copyWith(color: colors.neutral400),

            border: _defaultBorder(colors.neutral300),

            enabledBorder:
                widget.enabledBorder ?? _defaultBorder(colors.neutral300),

            focusedBorder:
                widget.focusedBorder ??
                _defaultBorder(colors.primary600, width: 1.5),

            errorBorder: widget.errorBorder ?? _defaultBorder(colors.danger600),

            focusedErrorBorder:
                widget.errorBorder ??
                _defaultBorder(colors.danger600, width: 1.5),

            disabledBorder:
                widget.disabledBorder ?? _defaultBorder(colors.neutral200),

            prefix:
                widget.prefix ??
                (widget.prefixText != null
                    ? Text(widget.prefixText!, style: context.f12r)
                    : null),

            prefixIcon: widget.prefixIcon,
            prefixIconConstraints:
                widget.prefixIconConstraints ??
                BoxConstraints(minWidth: 20.width, minHeight: 20.height),

            suffixIcon: _buildSuffixIcon(context),

            suffixIconConstraints:
                widget.suffixIconConstraints ??
                BoxConstraints(minWidth: 20.width, minHeight: 20.height),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.isPassword) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: 2.radius, end: 4.radius),
        child: Semantics(
          button: true,
          label: _obscureText ? 'Show password' : 'Hide password',
          child: IconButton(
            onPressed: widget.enabled ? _togglePasswordVisibility : null,
            splashRadius: 20.radius,
            tooltip: _obscureText ? 'Show password' : 'Hide password',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: SvgPicture.asset(
                _obscureText
                    ? AssetHelper.iconSVGPath('hidden_password')
                    : AssetHelper.iconSVGPath('shown_password'),
                key: ValueKey(_obscureText),
                width: 20.radius,
                height: 20.radius,
                colorFilter: ColorFilter.mode(
                  widget.suffixIconColor ?? context.customAppColors.neutral500,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widget.suffixIcon;
  }

  OutlineInputBorder _defaultBorder(Color color, {double width = 1.1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.radius),
      borderSide: BorderSide(color: color, width: width.width),
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
              text: ' *',
              style: context.f14r.copyWith(color: colors.danger600),
            ),
          ],
        ],
      ),
    );
  }
}
