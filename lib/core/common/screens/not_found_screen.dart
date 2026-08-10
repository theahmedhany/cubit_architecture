import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/media_helper.dart';
import '../../helpers/spacing.dart';
import '../../routing/route_manager.dart';
import '../../theme/app_texts/font_weight_helper.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import '../app/app_button.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({
    super.key,
    this.mainButtonText,
    this.onMainButtonPressed,
  });

  final String? mainButtonText;
  final VoidCallback? onMainButtonPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.customAppColors;

    final backgroundColor = colorScheme.neutral0;
    final neutralColor = colorScheme.neutral900;
    final dangerColor = colorScheme.danger700;
    final infoColor = colorScheme.info600;
    final warningColor = colorScheme.warning500;

    void notFountInitialNavigation() {
      // RouteManager.navigateAndPopAll(const LoginScreen());
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -24,
              child: Text(
                '404',
                style: TextStyle(
                  fontSize: 200.font,
                  fontWeight: FontWeightHelper.extraBold,
                  letterSpacing: -12,
                  height: 1,
                  color: neutralColor.withValues(alpha: 0.1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),

                  Row(
                    children: [
                      Container(
                        width: 8.radius,
                        height: 8.radius,
                        decoration: BoxDecoration(
                          color: dangerColor,
                          shape: BoxShape.circle,
                        ),
                      ),

                      horizontalGap(8),

                      Text(
                        context.tr('route_not_found').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.font,
                          fontWeight: FontWeightHelper.semiBold,
                          letterSpacing: 2.5,
                          color: dangerColor,
                        ),
                      ),
                    ],
                  ),

                  verticalGap(20),

                  Text(
                    '404',
                    style: TextStyle(
                      fontSize: 80.font,
                      fontWeight: FontWeightHelper.extraBold,
                      letterSpacing: -4,
                      height: 0.95,
                      color: neutralColor,
                    ),
                  ),

                  verticalGap(16),

                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1.radius, color: dangerColor),
                      ),

                      horizontalGap(10),

                      Container(
                        width: 6.radius,
                        height: 6.radius,
                        decoration: BoxDecoration(
                          color: dangerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  verticalGap(20),

                  Text(
                    context.tr('route_not_found_message'),
                    style: TextStyle(
                      fontSize: 26.font,
                      fontWeight: FontWeightHelper.bold,
                      height: 1.25,
                      letterSpacing: -0.5,
                      color: neutralColor,
                    ),
                  ),

                  verticalGap(12),

                  Text(
                    context.tr('page_moved_or_not_exist'),
                    style: TextStyle(
                      fontSize: 12.font,
                      height: 1.65,
                      color: neutralColor.withValues(alpha: 0.7),
                    ),
                  ),

                  const Spacer(flex: 4),

                  Row(
                    children: [
                      Container(
                        width: 7.radius,
                        height: 7.radius,
                        decoration: BoxDecoration(
                          color: infoColor,
                          shape: BoxShape.circle,
                        ),
                      ),

                      horizontalGap(6),

                      Text(
                        context.tr('route_unmatched'),
                        style: TextStyle(fontSize: 12.font, color: infoColor),
                      ),

                      const Spacer(),

                      Text(
                        'HTTP 404',
                        style: TextStyle(
                          fontSize: 12.font,
                          color: warningColor,
                        ),
                      ),
                    ],
                  ),

                  verticalGap(12),

                  AppButton(
                    text: mainButtonText ?? context.tr('go_to_login'),
                    onPressed: onMainButtonPressed ?? notFountInitialNavigation,
                    color: dangerColor,
                    textColor: backgroundColor,
                    radius: 14.radius,
                  ),

                  verticalGap(10),

                  AppButton(
                    text: context.tr('go_back'),
                    onPressed: () {
                      RouteManager.pop();
                    },
                    color: Colors.transparent,
                    boxBorder: Border.all(color: dangerColor),
                    textColor: dangerColor,
                    radius: 14.radius,
                  ),

                  verticalGap(MediaHelper.bottomPadding(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
