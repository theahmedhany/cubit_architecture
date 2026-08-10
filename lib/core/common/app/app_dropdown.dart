import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../helpers/asset_helper.dart';
import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/app_texts/font_weight_helper.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_loading_indicator.dart';

class AppDropdown<T> extends StatefulWidget {
  final String? title;
  final bool withTitle;
  final bool isRequired;

  final List<T> items;
  final T? value;

  final String Function(T item) itemLabelBuilder;
  final Widget Function(T item)? itemBuilder;

  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  final bool enabled;
  final bool isLoading;
  final bool isError;
  final bool autofocus;

  final String hintText;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? emptyIcon;
  final Widget? errorIcon;

  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? titleTextStyle;

  final Color? backgroundColor;
  final Color? titleColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final Color? iconColor;
  final Color? loaderColor;

  final double? borderRadius;
  final double? borderWidth;
  final double? dropdownMaxHeight;
  final double? dropdownWidth;

  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? itemPadding;

  final double? loaderSize;

  const AppDropdown({
    super.key,
    this.title,
    this.withTitle = false,
    this.isRequired = false,
    required this.items,
    required this.itemLabelBuilder,
    required this.hintText,
    this.itemBuilder,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.isLoading = false,
    this.isError = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.emptyIcon,
    this.errorIcon,
    this.textStyle,
    this.hintStyle,
    this.titleTextStyle,
    this.backgroundColor,
    this.titleColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.iconColor,
    this.loaderColor,
    this.borderRadius,
    this.borderWidth,
    this.dropdownMaxHeight,
    this.dropdownWidth,
    this.contentPadding,
    this.itemPadding,
    this.loaderSize,
  });

  bool get _isEmpty => items.isEmpty;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _fieldKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _showAbove = false;
  double? _dropdownWidth;

  static final double _itemHeight = 48.radius;
  static final double _dropdownGap = 4.radius;
  static final double _screenMargin = 16.radius;

  T? get _safeValue =>
      (!widget.isError &&
          !widget._isEmpty &&
          widget.items.contains(widget.value))
      ? widget.value
      : null;

  @override
  void initState() {
    super.initState();
    _syncText();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.items != widget.items ||
        oldWidget.isError != widget.isError) {
      _syncText();
      _overlayEntry?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _closeDropdown();
    _focusNode.removeListener(_handleFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncText() {
    final value = _safeValue;
    final newText = value != null ? widget.itemLabelBuilder(value) : '';

    if (_controller.text != newText) {
      _controller.text = newText;
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      if (widget.enabled &&
          !widget.isLoading &&
          !widget._isEmpty &&
          !widget.isError) {
        _openDropdown();
      } else {
        _focusNode.unfocus();
      }
    } else {
      _closeDropdown();
    }
  }

  void _updateDropdownWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _fieldKey.currentContext?.findRenderObject() as RenderBox?;
      final width = renderBox?.size.width;
      if (width != null && width != _dropdownWidth) {
        setState(() => _dropdownWidth = width);
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  bool _computeShowAbove() {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    final position = renderBox.localToGlobal(Offset.zero);
    final fieldBottom = position.dy + renderBox.size.height;
    final screenHeight = MediaQuery.of(context).size.height;

    final spaceBelow = screenHeight - fieldBottom - _screenMargin;
    final spaceAbove = position.dy - _screenMargin;
    final maxH = widget.dropdownMaxHeight ?? 200.radius;

    return spaceBelow < maxH && spaceAbove > spaceBelow;
  }

  void _openDropdown() {
    if (_isOpen) return;

    _showAbove = _computeShowAbove();
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    if (!_isOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _syncText();
    setState(() => _isOpen = false);
  }

  void _selectItem(T item) {
    widget.onChanged?.call(item);
    _controller.text = widget.itemLabelBuilder(item);
    _focusNode.unfocus();
    _closeDropdown();
  }

  OverlayEntry _buildOverlayEntry() {
    final colors = context.customAppColors;

    return OverlayEntry(
      builder: (_) {
        final maxH = widget.dropdownMaxHeight ?? 200.radius;
        final showScrollbar = widget.items.length * _itemHeight > maxH;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _focusNode.unfocus();
            _closeDropdown();
          },
          child: Stack(
            children: [
              const SizedBox.expand(),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: _showAbove
                    ? Alignment.topLeft
                    : Alignment.bottomLeft,
                followerAnchor: _showAbove
                    ? Alignment.bottomLeft
                    : Alignment.topLeft,
                offset: Offset(0, _showAbove ? -_dropdownGap : _dropdownGap),
                child: Material(
                  color: Colors.transparent,
                  child: _DropdownContainer(
                    width: widget.dropdownWidth ?? _dropdownWidth ?? 300,
                    maxHeight: maxH,
                    fillColor: widget.backgroundColor ?? colors.neutral50,
                    radius: BorderRadius.circular(
                      widget.borderRadius ?? 12.radius,
                    ),
                    borderColor: widget.isError
                        ? (widget.errorBorderColor ?? colors.danger600)
                        : (widget.borderColor ?? colors.neutral300),
                    borderWidth: widget.borderWidth ?? 1.3,
                    child: _DropdownList<T>(
                      items: widget.items,
                      selectedValue: widget.value,
                      scrollController: _scrollController,
                      showScrollbar: showScrollbar,
                      itemLabelBuilder: widget.itemLabelBuilder,
                      itemBuilder: widget.itemBuilder,
                      itemPadding: widget.itemPadding,
                      textStyle: widget.textStyle,
                      onSelect: _selectItem,
                      dividerColor: colors.neutral200,
                      selectedColor: colors.primary600,
                      neutralColor: colors.neutral600,
                      scrollbarColor: colors.neutral300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateDropdownWidth();

    final colors = context.customAppColors;
    final radius = BorderRadius.circular(widget.borderRadius ?? 12.radius);
    final borderW = widget.borderWidth ?? 1.3;
    final fillColor = widget.backgroundColor ?? colors.neutral50;
    final enabledBorderColor = widget.borderColor ?? colors.neutral300;
    final focusedColor = widget.focusedBorderColor ?? colors.primary600;
    final dangerColor = widget.errorBorderColor ?? colors.danger600;
    final defaultHintStyle =
        widget.hintStyle ?? context.f14r.copyWith(color: colors.neutral400);

    final defaultContentPadding =
        widget.contentPadding ??
        EdgeInsetsDirectional.only(
          start: widget.prefixIcon != null ? 32.radius : 12.radius,
          end: 16.radius,
          top: 14.radius,
          bottom: 14.radius,
        );

    final isFieldEnabled =
        widget.enabled &&
        !widget.isLoading &&
        !widget._isEmpty &&
        !widget.isError;

    return FormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        final hasError = field.hasError || widget.isError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.withTitle) ...[
              _DropdownTitle(
                title: widget.title ?? widget.hintText,
                isRequired: widget.isRequired,
                titleColor: widget.titleColor,
                titleTextStyle: widget.titleTextStyle,
              ),
              verticalGap(6),
            ],

            CompositedTransformTarget(
              link: _layerLink,
              child: SizedBox(
                key: _fieldKey,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: isFieldEnabled,
                  readOnly: true,
                  autofocus: widget.autofocus,
                  style: widget.textStyle ?? context.f14r,
                  cursorColor: focusedColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fillColor,
                    isDense: true,
                    contentPadding: defaultContentPadding,
                    hintText: widget.isError
                        ? context.tr('there_is_something_went_wrong')
                        : widget._isEmpty
                        ? context.tr('no_data_available')
                        : widget.hintText,
                    hintStyle: defaultHintStyle,
                    prefixIcon: widget.prefixIcon,
                    prefixIconConstraints: BoxConstraints.tightFor(
                      width: widget.prefixIcon != null ? 38.radius : 0,
                      height: 38.radius,
                    ),
                    suffixIcon: _buildSuffixIcon(),
                    suffixIconConstraints: BoxConstraints.tightFor(
                      width: 44.radius,
                      height: 44.radius,
                    ),
                    border: _border(radius, enabledBorderColor, borderW),
                    enabledBorder: _border(
                      radius,
                      hasError ? dangerColor : enabledBorderColor,
                      borderW,
                    ),
                    focusedBorder: _border(
                      radius,
                      hasError ? dangerColor : focusedColor,
                      borderW,
                    ),
                    errorBorder: _border(radius, dangerColor, borderW),
                    focusedErrorBorder: _border(radius, dangerColor, borderW),
                    disabledBorder: _border(radius, colors.neutral200, borderW),
                    errorStyle: context.f12r.copyWith(color: dangerColor),
                  ),
                ),
              ),
            ),

            if (field.hasError) ...[
              verticalGap(4),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 12.radius),
                child: Text(
                  field.errorText ?? '',
                  style: context.f12r.copyWith(color: dangerColor),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSuffixIcon() {
    if (widget.isLoading) {
      return Padding(
        padding: EdgeInsetsDirectional.only(end: 12.radius),
        child: AppLoadingIndicator(
          size: widget.loaderSize ?? 24.radius,
          color: widget.loaderColor ?? context.customAppColors.primary600,
        ),
      );
    }

    if (widget.isError) {
      return widget.errorIcon ??
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12.radius),
            child: Center(
              child: SvgPicture.asset(
                AssetHelper.iconSVGPath('error_case'),
                width: 20.radius,
                height: 20.radius,
                colorFilter: ColorFilter.mode(
                  context.customAppColors.danger600,
                  BlendMode.srcIn,
                ),
              ),
            ),
          );
    }

    if (widget._isEmpty) {
      return widget.emptyIcon ??
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12.radius),
            child: Center(
              child: SvgPicture.asset(
                AssetHelper.iconSVGPath('info_case'),
                width: 20.radius,
                height: 20.radius,
                colorFilter: ColorFilter.mode(
                  context.customAppColors.neutral400,
                  BlendMode.srcIn,
                ),
              ),
            ),
          );
    }

    return widget.suffixIcon ??
        Padding(
          padding: EdgeInsetsDirectional.only(end: 12.radius),
          child: AnimatedRotation(
            turns: _isOpen ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Center(
              child: SvgPicture.asset(
                AssetHelper.iconSVGPath('arrow_down'),
                width: 20.radius,
                height: 20.radius,
                colorFilter: ColorFilter.mode(
                  widget.iconColor ?? context.customAppColors.neutral500,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
  }

  OutlineInputBorder _border(BorderRadius radius, Color color, double width) {
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _DropdownContainer extends StatelessWidget {
  final double width;
  final double? maxHeight;
  final Color fillColor;
  final BorderRadius radius;
  final Color borderColor;
  final double borderWidth;
  final Widget child;

  const _DropdownContainer({
    required this.width,
    this.maxHeight,
    required this.fillColor,
    required this.radius,
    required this.borderColor,
    required this.borderWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            blurRadius: 32.radius,
            spreadRadius: -4.radius,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.06),
          ),
          BoxShadow(
            blurRadius: 12.radius,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }
}

class _DropdownList<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedValue;
  final ScrollController scrollController;
  final bool showScrollbar;
  final String Function(T) itemLabelBuilder;
  final Widget Function(T)? itemBuilder;
  final EdgeInsetsGeometry? itemPadding;
  final TextStyle? textStyle;
  final ValueChanged<T> onSelect;
  final Color dividerColor;
  final Color selectedColor;
  final Color neutralColor;
  final Color scrollbarColor;

  const _DropdownList({
    required this.items,
    required this.selectedValue,
    required this.scrollController,
    required this.showScrollbar,
    required this.itemLabelBuilder,
    required this.itemBuilder,
    required this.itemPadding,
    required this.textStyle,
    required this.onSelect,
    required this.dividerColor,
    required this.selectedColor,
    required this.neutralColor,
    required this.scrollbarColor,
  });

  @override
  Widget build(BuildContext context) {
    final list = ListView.separated(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 8.radius),
      itemCount: items.length,
      separatorBuilder: (_, _) => Divider(
        height: 1.radius,
        thickness: 1.radius,
        endIndent: 12.radius,
        indent: 12.radius,
        color: dividerColor,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item == selectedValue;

        return _DropdownItemTile<T>(
          item: item,
          isSelected: isSelected,
          label: itemLabelBuilder(item),
          customChild: itemBuilder?.call(item),
          textStyle: textStyle,
          itemPadding: itemPadding,
          selectedColor: selectedColor,
          neutralColor: neutralColor,
          onTap: () => onSelect(item),
        );
      },
    );

    if (!showScrollbar) return list;

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(scrollbars: false),
      child: RawScrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: false,
        thickness: 4.radius,
        radius: Radius.circular(8.radius),
        padding: EdgeInsetsDirectional.only(
          end: 4.radius,
          top: 6.radius,
          bottom: 6.radius,
        ),
        thumbColor: scrollbarColor,
        child: list,
      ),
    );
  }
}

class _DropdownItemTile<T> extends StatefulWidget {
  final T item;
  final bool isSelected;
  final String label;
  final Widget? customChild;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? itemPadding;
  final Color selectedColor;
  final Color neutralColor;
  final VoidCallback onTap;

  const _DropdownItemTile({
    required this.item,
    required this.isSelected,
    required this.label,
    required this.selectedColor,
    required this.neutralColor,
    required this.onTap,
    this.customChild,
    this.textStyle,
    this.itemPadding,
  });

  @override
  State<_DropdownItemTile<T>> createState() => _DropdownItemTileState<T>();
}

class _DropdownItemTileState<T> extends State<_DropdownItemTile<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: CupertinoButton(
        onPressed: widget.onTap,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          alignment: AlignmentDirectional.centerStart,
          padding:
              widget.itemPadding ??
              EdgeInsets.symmetric(horizontal: 14.radius, vertical: 12.radius),
          color: widget.isSelected
              ? widget.selectedColor.withValues(alpha: 0.08)
              : _hovered
              ? widget.neutralColor.withValues(alpha: 0.04)
              : Colors.transparent,
          child: _DropdownMenuItemContent<T>(
            item: widget.item,
            label: widget.label,
            customChild: widget.customChild,
            textStyle: widget.textStyle,
            selectedColor: widget.selectedColor,
            neutralColor: widget.neutralColor,
            isSelected: widget.isSelected,
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuItemContent<T> extends StatelessWidget {
  final T item;
  final String label;
  final Widget? customChild;
  final TextStyle? textStyle;
  final Color selectedColor;
  final Color neutralColor;
  final bool isSelected;

  const _DropdownMenuItemContent({
    required this.item,
    required this.label,
    required this.selectedColor,
    required this.neutralColor,
    this.customChild,
    this.textStyle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child:
              customChild ??
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: context.f14r.copyWith(
                  color: isSelected ? selectedColor : neutralColor,
                  fontWeight: isSelected
                      ? FontWeightHelper.medium
                      : FontWeightHelper.regular,
                ),
              ),
        ),

        if (isSelected) ...[
          horizontalGap(8),

          Icon(Icons.check, size: 18.radius, color: selectedColor),

          horizontalGap(8),
        ],
      ],
    );
  }
}

class _DropdownTitle extends StatelessWidget {
  final String title;
  final bool isRequired;
  final Color? titleColor;
  final TextStyle? titleTextStyle;

  const _DropdownTitle({
    required this.title,
    required this.isRequired,
    this.titleColor,
    this.titleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style:
                titleTextStyle ??
                context.f16sb.copyWith(
                  color: titleColor ?? context.customAppColors.neutral950,
                ),
          ),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: context.f14r.copyWith(
                color: context.customAppColors.danger600,
              ),
            ),
        ],
      ),
    );
  }
}
