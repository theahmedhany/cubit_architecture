import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/app_logger.dart';
import '../helpers/dimensions_helper.dart';
import '../routing/route_manager.dart';
import '../theme/app_texts/app_text_styles.dart';
import '../theme/theme_manager/theme_extensions.dart';
import '../utils/url_launcher_util.dart';

class AppVersionUtil {
  AppVersionUtil._();

  static bool isVersionOutdated(String current, String latest) {
    final c = _parseVersion(current);
    final l = _parseVersion(latest);

    for (int i = 0; i < l.length; i++) {
      final cv = i < c.length ? c[i] : 0;
      if (cv < l[i]) return true;
      if (cv > l[i]) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String version) {
    return version
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList();
  }

  static Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  static Future<bool> checkIfUpdateRequired(String? latestVersion) async {
    if (latestVersion == null || latestVersion.isEmpty) return false;

    final current = await getCurrentVersion();
    final required = isVersionOutdated(current, latestVersion);

    AppLogger.log(
      'Version check: current = $current, latest = $latestVersion, updateRequired = $required',
      name: 'APP_VERSION_UTIL',
    );

    return required;
  }

  static void showUpdateDialog({BuildContext? context, String? storeUrl}) {
    final ctx = context ?? RouteManager.currentContext;

    showCupertinoDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: CupertinoAlertDialog(
          title: _buildDialogTitle(ctx),
          content: _buildDialogContent(ctx),
          actions: _buildDialogActions(ctx, storeUrl),
        ),
      ),
    );
  }

  static Widget _buildDialogTitle(BuildContext ctx) {
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
            CupertinoIcons.arrow_up_circle_fill,
            color: ctx.customAppColors.danger600,
            size: 28.radius,
          ),
        ),

        SizedBox(height: 12.radius),

        Text(
          'update_required_title'.tr(),
          textAlign: TextAlign.center,
          style: ctx.f16sb.copyWith(color: ctx.customAppColors.neutral950),
        ),
      ],
    );
  }

  static Widget _buildDialogContent(BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.only(top: 6.radius),
      child: Text(
        'update_required_message'.tr(),
        textAlign: TextAlign.center,
        style: ctx.f14r.copyWith(color: ctx.customAppColors.neutral600),
      ),
    );
  }

  static List<Widget> _buildDialogActions(BuildContext ctx, String? storeUrl) {
    return [
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: storeUrl != null
            ? () => UrlLauncherUtil.launchURL(url: storeUrl)
            : null,
        child: Text(
          'update_now'.tr(),
          style: ctx.f14sb.copyWith(color: ctx.customAppColors.danger600),
        ),
      ),
    ];
  }

  static Future<void> logAppInfo() async {
    if (!kDebugMode) return;

    final info = await PackageInfo.fromPlatform();

    AppLogger.log(
      'App: ${info.appName} | Package: ${info.packageName} | v${info.version}+${info.buildNumber}',
      name: 'APP_VERSION_UTIL',
    );
  }
}
