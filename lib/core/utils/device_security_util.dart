import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../helpers/app_logger.dart';
import '../helpers/dimensions_helper.dart';
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
      final ctx = navigatorKey.currentContext;

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

    if (navigatorKey.currentContext != null) {
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
        title: 'emulator_detected_title'.tr(),
        message: 'emulator_detected_message'.tr(),
      );
    }

    if (result.isRooted) {
      return (
        title: 'rooted_device_title'.tr(),
        message: 'rooted_device_message'.tr(),
      );
    }

    return (
      title: 'developer_mode_detected_title'.tr(),
      message: 'developer_mode_detected_message'.tr(),
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

    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: CupertinoAlertDialog(
          title: _buildBlockingTitle(dialogContext, title),
          content: _buildBlockingContent(dialogContext, message),
          actions: _buildBlockingActions(
            dialogContext,
            canOpenSettings: canOpenSettings,
          ),
        ),
      ),
    ).whenComplete(() => _isBlockingDialogVisible = false);
  }

  static Widget _buildBlockingTitle(BuildContext ctx, String title) {
    return Column(
      children: [
        Container(
          width: 52.radius,
          height: 52.radius,
          decoration: BoxDecoration(
            color: ctx.customAppColors.danger600.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CupertinoIcons.xmark_circle_fill,
            color: ctx.customAppColors.danger600,
            size: 28.radius,
          ),
        ),

        SizedBox(height: 12.radius),

        Text(
          title,
          textAlign: TextAlign.center,
          style: ctx.f16sb.copyWith(color: ctx.customAppColors.neutral950),
        ),
      ],
    );
  }

  static Widget _buildBlockingContent(BuildContext ctx, String message) {
    return Padding(
      padding: EdgeInsets.only(top: 6.radius),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: ctx.f14r.copyWith(color: ctx.customAppColors.neutral600),
      ),
    );
  }

  static List<Widget> _buildBlockingActions(
    BuildContext ctx, {
    required bool canOpenSettings,
  }) {
    return [
      CupertinoDialogAction(
        isDestructiveAction: true,
        onPressed: canOpenSettings
            ? () => _openDeveloperOptionsSettings(ctx)
            : _exitApp,
        child: Text(
          (canOpenSettings ? 'open_settings' : 'ok').tr(),
          style: ctx.f14sb.copyWith(color: ctx.customAppColors.danger600),
        ),
      ),
    ];
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
