import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../helpers/app_logger.dart';
import '../helpers/dimensions_helper.dart';
import '../helpers/spacing.dart';
import '../localization/locale_keys.g.dart';
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

    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      barrierColor: ctx.customAppColors.neutral900.withValues(alpha: 0.7),
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: _UpdateRequiredDialog(
            title: ctx.tr(LocaleKeys.app_version_util_update_required_title),
            description: ctx.tr(
              LocaleKeys.app_version_util_update_required_message,
            ),
            actionText: ctx.tr(LocaleKeys.app_version_util_update_now),
            onUpdate: storeUrl != null
                ? () => UrlLauncherUtil.launchURL(context: ctx, url: storeUrl)
                : null,
          ),
        );
      },
    );
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

class _UpdateRequiredDialog extends StatelessWidget {
  const _UpdateRequiredDialog({
    required this.title,
    required this.description,
    required this.actionText,
    this.onUpdate,
  });

  final String title;
  final String description;
  final String actionText;
  final VoidCallback? onUpdate;

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
                    onUpdate?.call();
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
              Icons.system_update_alt_rounded,
              size: 20.radius,
              color: colors.neutral0,
            ),
          ),
        ),
      ),
    );
  }
}
