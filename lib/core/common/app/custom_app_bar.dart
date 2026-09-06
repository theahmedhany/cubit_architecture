import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../helpers/asset_helper.dart';
import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../routing/route_manager.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.onBackPressed,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.leadingWidth,
    this.titleSpacing,
    this.backButtonIcon,
    this.actions,
    this.centerTitle = false,
    this.backButtonColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.showBackButton = true,
    this.backgroundColor,
    this.forceMaterialTransparency = true,
    this.elevation = 0,
    this.showDivider = false,
    this.toolbarHeight,
    this.systemOverlayStyle,
  });

  final VoidCallback? onBackPressed;
  final String? title;
  final Widget? titleWidget;
  final bool centerTitle;
  final TextStyle? titleTextStyle;
  final String? subtitle;
  final TextStyle? subtitleTextStyle;
  final Widget? backButtonIcon;
  final Color? backButtonColor;
  final bool showBackButton;
  final Widget? leading;
  final double? leadingWidth;
  final double? titleSpacing;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool forceMaterialTransparency;
  final double elevation;
  final bool showDivider;
  final double? toolbarHeight;
  final SystemUiOverlayStyle? systemOverlayStyle;

  bool get _canPop => onBackPressed != null || RouteManager.canPop();

  void _handleBack() {
    if (onBackPressed != null) {
      onBackPressed!();
      return;
    }

    if (RouteManager.canPop()) {
      RouteManager.pop();
    }
  }

  Widget _buildBackButton(BuildContext context) {
    if (!_canPop) return const SizedBox.shrink();

    final Color resolvedColor =
        backButtonColor ?? context.customAppColors.neutral900;

    return IconButton(
      onPressed: _handleBack,
      splashRadius: 20.radius,
      icon:
          backButtonIcon ??
          SvgPicture.asset(
            AssetHelper.iconSVGPath('arrow_left'),
            matchTextDirection: true,
            width: 24.radius,
            height: 24.radius,
            colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
          ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (titleWidget != null) {
      return titleWidget!;
    }

    if (title == null) {
      return const SizedBox.shrink();
    }

    final titleWidgetText = Text(
      title!,
      style: titleTextStyle ?? context.f14sb,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    if (subtitle == null) {
      return titleWidgetText;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        titleWidgetText,

        verticalGap(2),

        Text(
          subtitle!,
          style:
              subtitleTextStyle ??
              context.f12r.copyWith(color: context.customAppColors.neutral600),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      systemOverlayStyle: systemOverlayStyle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      forceMaterialTransparency: forceMaterialTransparency,
      automaticallyImplyLeading: false,
      elevation: elevation,
      scrolledUnderElevation: elevation,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight ?? kToolbarHeight,
      titleSpacing: titleSpacing,
      title: _buildTitle(context),
      leadingWidth: leadingWidth,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: actions,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: context.customAppColors.neutral200,
              ),
            )
          : null,
    );

    return appBar;
  }

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (showDivider ? 1 : 0),
  );
}
