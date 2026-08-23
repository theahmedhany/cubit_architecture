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

enum BaseStateType { empty, error }

class BaseState extends StatelessWidget {
  const BaseState({
    super.key,
    required this.type,
    required this.message,
    this.messageTextStyle,
    this.size,
    this.lottiePath,
    this.isScrollable = false,
    this.controller,
    this.onRetry,
    this.retryText,
  }) : assert(
         type != BaseStateType.empty || onRetry == null,
         'onRetry / retryText are only supported for BaseStateType.error',
       );

  const BaseState.empty({
    super.key,
    required this.message,
    this.messageTextStyle,
    this.size,
    this.lottiePath,
    this.isScrollable = false,
    this.controller,
    this.onRetry,
    this.retryText,
  }) : type = BaseStateType.empty;

  const BaseState.error({
    super.key,
    required this.message,
    this.messageTextStyle,
    this.size,
    this.lottiePath,
    this.isScrollable = false,
    this.controller,
    this.onRetry,
    this.retryText,
  }) : type = BaseStateType.error;

  final BaseStateType type;
  final String message;
  final TextStyle? messageTextStyle;
  final double? size;
  final String? lottiePath;
  final bool isScrollable;
  final ScrollController? controller;
  final VoidCallback? onRetry;
  final String? retryText;

  bool get _isError => type == BaseStateType.error;

  Color _baseColor(BuildContext context) => _isError
      ? context.customAppColors.danger600
      : context.customAppColors.neutral500;

  String _defaultLottiePath() => _isError ? 'error_state' : 'empty_state';

  double _defaultSize() => 200.radius;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 18.radius,
          vertical: 12.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AssetHelper.assetLottiePath(lottiePath ?? _defaultLottiePath()),
              width: size ?? _defaultSize(),
              height: size ?? _defaultSize(),
              fit: BoxFit.contain,
            ),

            verticalGap(16),

            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  messageTextStyle ??
                  context.f14r.copyWith(color: _baseColor(context)),
            ),

            if (onRetry != null) ...[
              verticalGap(20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.radius),
                child: AppButton(
                  onPressed: onRetry,
                  title: '',
                  buttonColor: _baseColor(context).withValues(alpha: 0.2),
                  buttonBorder: Border.all(color: _baseColor(context)),
                  buttonRadius: 100.radius,
                  widget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 16.radius,
                        color: _baseColor(context),
                      ),

                      horizontalGap(8),

                      Flexible(
                        child: Text(
                          retryText ?? context.tr('try_again'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.f14r.copyWith(
                            color: _baseColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: MediaHelper.bottomPadding(context) + 12.radius),
            ] else ...[
              verticalGap(16),
            ],
          ],
        ),
      ),
    );

    if (!isScrollable) {
      return content;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0,
            ),
            child: content,
          ),
        );
      },
    );
  }
}
