import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/common/app/app_button.dart';
import '../../../../core/helpers/dimensions_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/route_manager.dart';
import '../../../../core/theme/app_texts/app_text_styles.dart';
import '../../../../core/theme/theme_manager/theme_extensions.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: AppButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                barrierColor: colors.neutral900.withValues(alpha: 0.7),
                builder: (dialogContext) {
                  return PopScope(
                    canPop: false,
                    child: UpdateRequiredDialog(
                      title: 'Update Required',
                      description:
                          'Please update your app to the latest version to continue using it.',
                      actionText: 'Update',
                      onUpdate: () {
                        RouteManager.pop();
                      },
                    ),
                  );
                },
              );
            },
            title: 'Onboarding Screen',
          ),
        ),
      ),
    );
  }
}

class UpdateRequiredDialog extends StatelessWidget {
  const UpdateRequiredDialog({
    super.key,
    required this.title,
    required this.description,
    required this.actionText,
    required this.onUpdate,
  });

  final String title;
  final String description;
  final String actionText;
  final VoidCallback onUpdate;

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
                    onUpdate();
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
