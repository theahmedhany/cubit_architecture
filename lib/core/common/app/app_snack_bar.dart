import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../routing/route_manager.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';

class AppSnackBar {
  AppSnackBar._();

  static OverlayEntry? _currentEntry;
  static GlobalKey<_ToastWidgetState>? _currentKey;

  static void show({
    required String message,
    BuildContext? context,
    AppSnackBarType type = AppSnackBarType.success,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool showProgressBar = false,
    VoidCallback? onDismiss,
  }) {
    if (message.trim().isEmpty) return;

    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    dismiss();

    final key = GlobalKey<_ToastWidgetState>();

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _ToastWidget(
            key: key,
            message: message.trim(),
            type: type,
            backgroundColor: backgroundColor,
            textColor: textColor,
            icon: icon,
            duration: duration,
            showProgressBar: showProgressBar,
            onDismiss: () {
              dismiss();
              onDismiss?.call();
            },
          ),
        );
      },
    );

    _currentEntry = entry;
    _currentKey = key;

    overlay.insert(entry);

    Future.delayed(duration, () {
      if (_currentEntry == entry) {
        dismiss();
        onDismiss?.call();
      }
    });
  }

  static void dismiss() {
    final entry = _currentEntry;
    final key = _currentKey;

    if (entry == null) return;

    _currentEntry = null;
    _currentKey = null;

    final state = key?.currentState;
    if (state != null && state.mounted) {
      state.animateOut(() {
        try {
          entry.remove();
        } catch (_) {}
      });
    } else {
      try {
        entry.remove();
      } catch (_) {}
    }
  }

  static void dismissAll() {
    dismiss();
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.showProgressBar = false,
  });

  final String message;
  final AppSnackBarType type;
  final Duration duration;
  final VoidCallback onDismiss;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool showProgressBar;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  bool _dismissing = false;
  VoidCallback? _onExitComplete;

  AnimationController? _progressController;

  void animateOut(VoidCallback onComplete) {
    if (_dismissing) return;

    _onExitComplete = onComplete;
    _progressController?.stop();

    if (!mounted) {
      onComplete();
      return;
    }

    setState(() {
      _dismissing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;
    final bg = widget.backgroundColor ?? _backgroundColor(context, widget.type);
    final fg = widget.textColor ?? colors.neutral0;
    final icn = widget.icon ?? _icon(widget.type);

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final cardContent = Material(
      color: Colors.transparent,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18.radius),
          border: Border.all(
            color: context.customAppColors.neutral0.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: context.customAppColors.neutral950.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14.radius,
                vertical: 13.radius,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Pulse(
                    infinite: true,
                    duration: const Duration(milliseconds: 1500),
                    from: 0.85,
                    to: 1.08,
                    child: Container(
                      padding: EdgeInsets.all(8.radius),
                      decoration: BoxDecoration(
                        color: fg.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: fg.withValues(alpha: 0.24),
                          width: 1,
                        ),
                      ),
                      child: Icon(icn, color: fg, size: 20.font),
                    ),
                  ),

                  horizontalGap(12),

                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 120.radius),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          widget.message,
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                          style: context.f14r.copyWith(
                            color: fg,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  horizontalGap(12),

                  Spin(
                    duration: const Duration(milliseconds: 500),
                    spins: 1,
                    child: CupertinoButton(
                      onPressed: widget.onDismiss,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      child: Container(
                        padding: EdgeInsets.all(6.width),
                        decoration: BoxDecoration(
                          color: fg.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: fg.withValues(alpha: 0.24),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 16.font,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.showProgressBar)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18.radius),
                  bottomRight: Radius.circular(18.radius),
                ),
                child: _progressController == null
                    ? LinearProgressIndicator(
                        value: 1,
                        backgroundColor: context.customAppColors.neutral0
                            .withValues(alpha: 0.18),
                        valueColor: AlwaysStoppedAnimation(
                          context.customAppColors.neutral0.withValues(
                            alpha: 0.85,
                          ),
                        ),
                        minHeight: 3,
                      )
                    : AnimatedBuilder(
                        animation: _progressController!,
                        builder: (_, _) => LinearProgressIndicator(
                          value: 1 - _progressController!.value,
                          backgroundColor: context.customAppColors.neutral0
                              .withValues(alpha: 0.18),
                          valueColor: AlwaysStoppedAnimation(
                            context.customAppColors.neutral0.withValues(
                              alpha: 0.85,
                            ),
                          ),
                          minHeight: 3,
                        ),
                      ),
              ),
          ],
        ),
      ),
    );

    final animatedCard = _dismissing
        ? FadeOutDown(
            duration: const Duration(milliseconds: 220),
            from: 24,
            onFinish: (_) => _onExitComplete?.call(),
            child: cardContent,
          )
        : BounceInUp(
            duration: const Duration(milliseconds: 380),
            from: 60,
            child: cardContent,
          );

    return SafeArea(
      bottom: keyboardHeight == 0,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.radius,
          right: 16.radius,
          bottom: keyboardHeight > 0 ? keyboardHeight + 8.radius : 24.radius,
          top: 24.radius,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            animatedCard,

            if (widget.showProgressBar)
              Offstage(
                offstage: true,
                child: Spin(
                  duration: widget.duration,
                  spins: 1,
                  animate: !_dismissing,
                  controller: (c) {
                    _progressController = c;
                    if (mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() {});
                      });
                    }
                  },
                  child: const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _backgroundColor(BuildContext context, AppSnackBarType type) {
    final colors = context.customAppColors;

    switch (type) {
      case AppSnackBarType.success:
        return colors.success600;

      case AppSnackBarType.error:
        return colors.danger600;

      case AppSnackBarType.warning:
        return colors.warning600;

      case AppSnackBarType.info:
        return colors.info600;
    }
  }

  IconData _icon(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return CupertinoIcons.check_mark_circled;

      case AppSnackBarType.error:
        return CupertinoIcons.exclamationmark_circle;

      case AppSnackBarType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;

      case AppSnackBarType.info:
        return CupertinoIcons.info_circle_fill;
    }
  }
}

enum AppSnackBarType { success, error, warning, info }
