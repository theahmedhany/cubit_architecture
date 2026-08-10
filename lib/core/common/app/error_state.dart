import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../helpers/asset_helper.dart';
import '../../helpers/dimensions_helper.dart';
import '../../helpers/media_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.size,
    this.lottiePath,
    this.textStyle,
    this.isScrollable = false,
    this.onRetry,
    this.retryText,
  });

  final String message;
  final double? size;
  final String? lottiePath;
  final TextStyle? textStyle;
  final bool isScrollable;
  final VoidCallback? onRetry;
  final String? retryText;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: EdgeInsets.all(18.radius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AssetHelper.assetLottiePath(lottiePath ?? 'error_state'),
              width: size ?? MediaQuery.of(context).size.width - 80.width,
              fit: BoxFit.cover,
            ),

            verticalGap(24),

            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  textStyle ??
                  context.f16r.copyWith(
                    color: context.customAppColors.danger600,
                  ),
            ),

            if (onRetry != null) ...[
              verticalGap(32),

              AppButton(
                onPressed: onRetry,
                text: '',
                color: context.customAppColors.danger100,
                boxBorder: Border.all(color: context.customAppColors.danger600),
                radius: 50.radius,
                widget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 16.radius,
                      color: context.customAppColors.danger600,
                    ),

                    horizontalGap(8),

                    Flexible(
                      child: Text(
                        retryText ?? context.tr('try_again'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.f14r.copyWith(
                          color: context.customAppColors.danger600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaHelper.bottomPadding(context) + 12.radius),
            ],
          ],
        ),
      ),
    );

    if (!isScrollable) return content;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: content,
    );
  }
}
