import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/app_logger.dart';
import '../helpers/dimensions_helper.dart';
import '../helpers/spacing.dart';
import '../localization/locale_keys.g.dart';
import '../routing/route_manager.dart';
import '../theme/app_texts/app_text_styles.dart';
import '../theme/theme_manager/theme_extensions.dart';
import 'device_security_check_util.dart';

class DeviceSecurityUtil {
  DeviceSecurityUtil._();

  static bool _isBlockingDialogVisible = false;

  static Future<bool> performSecurityCheck() async {
    final result = await DeviceSecurityCheckUtil.checkAll();

    if (result.isSecure) return true;

    AppLogger.log(
      'Security issues blocked: $result',
      name: 'DEVICE_SECURITY_UTIL',
    );

    _showBlockingDialogForResult(result: result);

    return false;
  }

  static void _showBlockingDialogForResult({
    required DeviceSecurityResult result,
  }) {
    final dialogContent = _dialogContentForResult(result);

    void showDialogIfPossible() {
      final ctx = RouteManager.navigatorKey.currentContext;

      if (ctx == null || !ctx.mounted) {
        AppLogger.log(
          'Unable to show security blocking dialog because context is not ready.',
          name: 'DEVICE_SECURITY_UTIL',
        );
        return;
      }

      _showBlockingDialog(
        context: ctx,
        title: dialogContent.title,
        message: dialogContent.message,
        canOpenSettings: _canOpenSettingsForResult(result),
      );
    }

    if (RouteManager.navigatorKey.currentContext != null) {
      showDialogIfPossible();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => showDialogIfPossible());
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  static ({String title, String message}) _dialogContentForResult(
    DeviceSecurityResult result,
  ) {
    if (result.isEmulator) {
      return (
        title: LocaleKeys.device_security_util_emulator_detected_title.tr(),
        message: LocaleKeys.device_security_util_emulator_detected_message.tr(),
      );
    }

    if (result.isRooted) {
      return (
        title: LocaleKeys.device_security_util_rooted_device_title.tr(),
        message: LocaleKeys.device_security_util_rooted_device_message.tr(),
      );
    }

    return (
      title: LocaleKeys.device_security_util_developer_mode_detected_title.tr(),
      message: LocaleKeys.device_security_util_developer_mode_detected_message
          .tr(),
    );
  }

  static bool _canOpenSettingsForResult(DeviceSecurityResult result) {
    return Platform.isAndroid &&
        result.isDeveloperOptionsEnabled &&
        !result.isEmulator &&
        !result.isRooted;
  }

  static void _showBlockingDialog({
    required BuildContext context,
    required String title,
    required String message,
    required bool canOpenSettings,
  }) {
    if (_isBlockingDialogVisible) return;

    _isBlockingDialogVisible = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: context.customAppColors.neutral900.withValues(alpha: 0.7),
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: _DeviceSecurityDialog(
            title: title,
            description: message,
            actionText: canOpenSettings
                ? context.tr(LocaleKeys.device_security_util_open_settings)
                : context.tr(LocaleKeys.device_security_util_okay),
            onPressed: canOpenSettings
                ? () => _openDeveloperOptionsSettings(context)
                : _exitApp,
          ),
        );
      },
    ).whenComplete(() => _isBlockingDialogVisible = false);
  }

  static void _exitApp() {
    if (Platform.isIOS) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }
  }

  static Future<void> _openDeveloperOptionsSettings(BuildContext ctx) async {
    Navigator.of(ctx, rootNavigator: true).pop();
    _isBlockingDialogVisible = false;

    final opened = await DeviceSecurityCheckUtil.openDeveloperOptionsSettings();

    if (!opened) _exitApp();
  }
}

class _DeviceSecurityDialog extends StatelessWidget {
  const _DeviceSecurityDialog({
    required this.title,
    required this.description,
    required this.actionText,
    this.onPressed,
  });

  final String title;
  final String description;
  final String actionText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    final borderRadius = BorderRadius.circular(18.radius);

    final bottomRadius = BorderRadius.vertical(
      bottom: Radius.circular(18.radius),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.radius),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: colors.neutral100.withValues(alpha: 0.95),
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: colors.neutral950.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              verticalGap(16),

              const _UpdateIcon(),

              verticalGap(16),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.radius),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.f16sb.copyWith(color: colors.danger600),
                      textAlign: TextAlign.center,
                    ),

                    verticalGap(8),

                    Text(
                      description,
                      style: context.f14r.copyWith(color: colors.neutral500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              verticalGap(16),

              Divider(height: 1, thickness: 0.5, color: colors.neutral400),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onPressed?.call();
                  },
                  borderRadius: bottomRadius,
                  splashFactory: InkRipple.splashFactory,
                  splashColor: colors.danger600.withValues(alpha: 0.16),
                  highlightColor: colors.danger600.withValues(alpha: 0.08),
                  hoverColor: colors.danger600.withValues(alpha: 0.04),
                  focusColor: colors.danger600.withValues(alpha: 0.12),

                  overlayColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.pressed)) {
                      return colors.danger600.withValues(alpha: 0.12);
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return colors.danger600.withValues(alpha: 0.04);
                    }
                    if (states.contains(WidgetState.focused)) {
                      return colors.danger600.withValues(alpha: 0.08);
                    }
                    return null;
                  }),

                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.radius),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.radius),
                      child: Center(
                        child: Text(
                          actionText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.f16sb.copyWith(
                            color: colors.danger600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateIcon extends StatelessWidget {
  const _UpdateIcon();

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return Container(
      width: 76.radius,
      height: 76.radius,
      padding: EdgeInsets.all(6.radius),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.danger600.withValues(alpha: 0.08),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.danger600.withValues(alpha: 0.12),
          border: Border.all(color: colors.danger600.withValues(alpha: 0.12)),
        ),
        child: Center(
          child: Container(
            width: 46.radius,
            height: 46.radius,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.danger600,
              boxShadow: [
                BoxShadow(
                  color: colors.danger600.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20.radius,
              color: colors.neutral0,
            ),
          ),
        ),
      ),
    );
  }
}
