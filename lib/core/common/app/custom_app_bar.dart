import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../helpers/asset_helper.dart';
import '../../helpers/dimensions_helper.dart';
import '../../routing/route_manager.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.onBackPressed,
    this.title,
    this.backIcon = 'circle_arrow_left',
    this.actions,
    this.centerTitle = false,
    this.iconColor,
    this.titleTextStyle,
    this.showBackButton = true,
    this.backgroundColor,
    this.forceMaterialTransparency = true,
  });

  final VoidCallback? onBackPressed;
  final String? title;
  final String backIcon;
  final List<Widget>? actions;
  final bool centerTitle;
  final TextStyle? titleTextStyle;
  final Color? iconColor;
  final bool showBackButton;
  final Color? backgroundColor;
  final bool forceMaterialTransparency;

  void _handleBack(BuildContext context) {
    if (onBackPressed != null) {
      onBackPressed!();
    } else {
      RouteManager.pop();
    }
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () => _handleBack(context),
      icon: SvgPicture.asset(
        AssetHelper.iconSVGPath(backIcon),
        matchTextDirection: true,
        width: 24.radius,
        height: 24.radius,
        colorFilter: ColorFilter.mode(
          iconColor ?? context.customAppColors.neutral900,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      forceMaterialTransparency: forceMaterialTransparency,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: centerTitle,

      title: title == null
          ? null
          : Text(title!, style: titleTextStyle ?? context.f14sb),

      leading: showBackButton ? _buildBackButton(context) : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
