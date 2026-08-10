import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../helpers/asset_helper.dart';
import '../../helpers/dimensions_helper.dart';
import '../../helpers/media_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.size,
    this.lottiePath,
    this.textStyle,
    this.isScrollable = false,
  });

  final String message;
  final TextStyle? textStyle;
  final double? size;
  final String? lottiePath;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: EdgeInsets.all(18.radius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AssetHelper.assetLottiePath(lottiePath ?? 'empty_state'),
              width: size ?? MediaQuery.of(context).size.width - 40.width,
              fit: BoxFit.cover,
            ),

            verticalGap(24),

            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  textStyle ??
                  context.f16r.copyWith(
                    color: context.customAppColors.neutral400,
                  ),
            ),

            SizedBox(height: MediaHelper.bottomPadding(context) + 40.height),
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
