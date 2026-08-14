import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../helpers/app_logger.dart';
import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';

enum AppSnackBarType { success, error, warning, info }

enum AppSnackBarPosition { top, bottom }

enum AppSnackBarAnimation { bounce, slide, fade, scale }

class AppSnackBar {
  AppSnackBar._();

  static final Map<AppSnackBarPosition, OverlayEntry?> _entries = {};
  static final Map<AppSnackBarPosition, GlobalKey<_ToastWidgetState>?> _keys =
      {};
  static final Map<AppSnackBarPosition, Timer?> _timers = {};
  static final Map<AppSnackBarPosition, DateTime?> _startTimes = {};
  static final Map<AppSnackBarPosition, int> _tapCounts = {};

  static void show({
    required BuildContext context,
    required String message,
    AppSnackBarType type = AppSnackBarType.success,
    AppSnackBarPosition position = AppSnackBarPosition.bottom,
    AppSnackBarAnimation animation = AppSnackBarAnimation.bounce,
    Duration duration = const Duration(seconds: 5),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool showProgressCircle = true,
    bool enableHaptics = false,
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onDismiss,
  }) {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) return;

    final data = _ToastData(
      message: trimmedMessage,
      type: type,
      position: position,
      animation: animation,
      duration: duration,
      showProgressCircle: showProgressCircle,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      onDismiss: onDismiss,
    );

    if (enableHaptics) _fireHaptic(type);

    final currentState = _keys[position]?.currentState;
    final currentEntry = _entries[position];

    if (currentEntry != null &&
        currentState != null &&
        currentState.mounted &&
        !currentState.isDismissing) {
      _extendExisting(position: position, state: currentState, data: data);
      return;
    }

    _timers[position]?.cancel();
    _forceRemoveEntry(position);
    _mountNew(context: context, position: position, data: data);
  }

  static void _extendExisting({
    required AppSnackBarPosition position,
    required _ToastWidgetState state,
    required _ToastData data,
  }) {
    _timers[position]?.cancel();
    _tapCounts[position] = (_tapCounts[position] ?? 0) + 1;

    final startTime = _startTimes[position];
    final elapsedSeconds = startTime != null
        ? DateTime.now().difference(startTime).inMilliseconds / 1000.0
        : 0.0;

    AppLogger.log(
      'Snackbar extended | Position: ${position.name} | Tap #${_tapCounts[position]} '
      '| +${data.duration.inSeconds}s | Active: ${elapsedSeconds.toStringAsFixed(1)}s '
      '| Message: "${data.message}"',
      name: 'APP_SNACK_BAR',
    );

    state.updateContent(data);

    _timers[position] = Timer(data.duration, () {
      dismiss(position: position);
      data.onDismiss?.call();
    });
  }

  static void _mountNew({
    required BuildContext context,
    required AppSnackBarPosition position,
    required _ToastData data,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      AppLogger.log(
        'No Overlay found in context — snackbar "${data.message}" was not shown.',
        name: 'APP_SNACK_BAR',
      );
      return;
    }

    _startTimes[position] = DateTime.now();
    _tapCounts[position] = 1;

    AppLogger.log(
      'Showing Snackbar | Position: ${position.name} | Duration: ${data.duration.inSeconds}s '
      '| Type: ${data.type.name} | Animation: ${data.animation.name} | Message: "${data.message}"',
      name: 'APP_SNACK_BAR',
    );

    final key = GlobalKey<_ToastWidgetState>();

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: position == AppSnackBarPosition.top ? 0 : null,
          bottom: position == AppSnackBarPosition.bottom ? 0 : null,
          left: 0,
          right: 0,
          child: _ToastWidget(
            key: key,
            data: data,
            onRequestDismiss: () {
              dismiss(position: position);
              data.onDismiss?.call();
            },
          ),
        );
      },
    );

    _entries[position] = entry;
    _keys[position] = key;
    overlay.insert(entry);

    _timers[position] = Timer(data.duration, () {
      if (_entries[position] == entry) {
        dismiss(position: position);
        data.onDismiss?.call();
      }
    });
  }

  static void _fireHaptic(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.error:
        HapticFeedback.heavyImpact();
        break;
      case AppSnackBarType.warning:
        HapticFeedback.mediumImpact();
        break;
      case AppSnackBarType.success:
      case AppSnackBarType.info:
        HapticFeedback.lightImpact();
        break;
    }
  }

  static void dismiss({AppSnackBarPosition? position}) {
    if (position == null) {
      dismissAll();
      return;
    }

    _timers[position]?.cancel();
    _timers[position] = null;

    final startTime = _startTimes[position];
    if (startTime != null) {
      final totalActiveDuration =
          DateTime.now().difference(startTime).inMilliseconds / 1000.0;

      AppLogger.log(
        'Snackbar dismissed | Position: ${position.name} | Active: '
        '${totalActiveDuration.toStringAsFixed(1)}s | Taps: ${_tapCounts[position]}',
        name: 'APP_SNACK_BAR',
      );

      _startTimes[position] = null;
      _tapCounts[position] = 0;
    }

    final entry = _entries[position];
    final key = _keys[position];
    if (entry == null) return;

    _entries[position] = null;
    _keys[position] = null;

    final state = key?.currentState;
    if (state != null && state.mounted && !state.isDismissing) {
      state.animateOut(() => _safeRemove(entry));
    } else {
      _safeRemove(entry);
    }
  }

  static void _forceRemoveEntry(AppSnackBarPosition position) {
    _timers[position]?.cancel();
    _timers[position] = null;
    _startTimes[position] = null;
    _tapCounts[position] = 0;

    final entry = _entries[position];
    _entries[position] = null;
    _keys[position] = null;

    if (entry != null) _safeRemove(entry);
  }

  static void _safeRemove(OverlayEntry entry) {
    try {
      entry.remove();
    } catch (_) {}
  }

  static void dismissAll() {
    for (final pos in AppSnackBarPosition.values) {
      dismiss(position: pos);
    }
  }
}

class _ToastData {
  const _ToastData({
    required this.message,
    required this.type,
    required this.position,
    required this.animation,
    required this.duration,
    required this.showProgressCircle,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final String message;
  final AppSnackBarType type;
  final AppSnackBarPosition position;
  final AppSnackBarAnimation animation;
  final Duration duration;
  final bool showProgressCircle;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    super.key,
    required this.data,
    required this.onRequestDismiss,
  });

  final _ToastData data;
  final VoidCallback onRequestDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with TickerProviderStateMixin {
  late _ToastData _data;

  bool _dismissing = false;
  bool get isDismissing => _dismissing;

  late AnimationController _animController;
  AnimationController? _progressController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _data = widget.data;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 240),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.035,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.035,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_pulseController);

    _initAnimations();
    _animController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: _data.duration,
    );
    if (_data.showProgressCircle) {
      _progressController?.forward(from: 0.0);
    }
  }

  void _initAnimations() {
    final bool isTop = _data.position == AppSnackBarPosition.top;

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    switch (_data.animation) {
      case AppSnackBarAnimation.bounce:
        _slideAnimation =
            Tween<Offset>(
              begin: Offset(0, isTop ? -0.8 : 0.8),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animController,
                curve: Curves.bounceOut,
                reverseCurve: Curves.easeInCubic,
              ),
            );
        _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeInCubic,
          ),
        );
        break;

      case AppSnackBarAnimation.slide:
        _slideAnimation =
            Tween<Offset>(
              begin: Offset(0, isTop ? -1.0 : 1.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animController,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );
        _scaleAnimation = const AlwaysStoppedAnimation<double>(1.0);
        break;

      case AppSnackBarAnimation.fade:
        _slideAnimation = const AlwaysStoppedAnimation<Offset>(Offset.zero);
        _scaleAnimation = const AlwaysStoppedAnimation<double>(1.0);
        break;

      case AppSnackBarAnimation.scale:
        _slideAnimation = const AlwaysStoppedAnimation<Offset>(Offset.zero);
        _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeInCubic,
          ),
        );
        break;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _progressController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void updateContent(_ToastData data) {
    if (!mounted || _dismissing) return;

    final bool configChanged =
        _data.position != data.position || _data.animation != data.animation;

    setState(() => _data = data);

    if (configChanged) {
      _initAnimations();
      _animController.forward(from: 0.0);
    } else {
      _pulseController.forward(from: 0.0);
    }

    if (_progressController != null) {
      _progressController!.duration = _data.duration;
      if (_data.showProgressCircle) {
        _progressController!.forward(from: 0.0);
      } else {
        _progressController!.stop();
      }
    }
  }

  void markDismissedBySwipe() {
    _dismissing = true;
    _progressController?.stop();
  }

  void animateOut(VoidCallback onComplete) {
    if (_dismissing) return;

    _dismissing = true;
    _progressController?.stop();

    if (!mounted) {
      onComplete();
      return;
    }

    _animController.reverse().then((_) {
      if (mounted) onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;
    final bg =
        _data.backgroundColor ?? _getBackgroundColor(context, _data.type);
    final fg = _data.textColor ?? colors.neutral0;
    final icn = _data.icon ?? _getIcon(_data.type);

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isTop = _data.position == AppSnackBarPosition.top;

    final cardContent = Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.radius),
          border: Border.all(
            color: colors.neutral0.withValues(alpha: 0.14),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: Offset(0, isTop ? -8 : 12),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: colors.neutral950.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: Offset(0, isTop ? -2 : 4),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 14.radius,
              vertical: 12.radius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _StatusIconBadge(
                  icon: icn,
                  foregroundColor: fg,
                  size: 36.radius,
                ),

                horizontalGap(12),

                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 120.radius),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        _data.message,
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                        style: context.f14m.copyWith(color: fg, height: 1.35),
                      ),
                    ),
                  ),
                ),

                if (_data.actionLabel != null && _data.onAction != null) ...[
                  horizontalGap(8),
                  _ActionButton(
                    label: _data.actionLabel!,
                    color: fg,
                    onTap: () {
                      _data.onAction?.call();
                      widget.onRequestDismiss();
                    },
                  ),
                ],

                horizontalGap(12),

                if (_data.showProgressCircle &&
                    _progressController != null) ...[
                  AnimatedBuilder(
                    animation: _progressController!,
                    builder: (_, _) => _CircularCloseButtonProgress(
                      progress: 1 - _progressController!.value,
                      foregroundColor: fg,
                      onTap: widget.onRequestDismiss,
                      showProgress: true,
                      size: 28.radius,
                      strokeWidth: 2.2.width,
                    ),
                  ),
                ] else ...[
                  _CircularCloseButtonProgress(
                    progress: 0,
                    foregroundColor: fg,
                    onTap: widget.onRequestDismiss,
                    showProgress: false,
                    size: 28.radius,
                    strokeWidth: 2.2.width,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final Widget animatedCard = SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Dismissible(
              key: ValueKey(identityHashCode(_data)),
              direction: DismissDirection.horizontal,
              onDismissed: (_) {
                markDismissedBySwipe();
                widget.onRequestDismiss();
              },
              child: Semantics(
                liveRegion: true,
                label: '${_data.type.name} notification: ${_data.message}',
                child: cardContent,
              ),
            ),
          ),
        ),
      ),
    );

    return SafeArea(
      top: isTop,
      bottom: !isTop && keyboardHeight == 0,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 16.radius,
          end: 16.radius,
          top: isTop ? 16.radius : 24.radius,
          bottom: !isTop
              ? (keyboardHeight > 0 ? keyboardHeight + 8.radius : 24.radius)
              : 16.radius,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: animatedCard,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context, AppSnackBarType type) {
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

  IconData _getIcon(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return Icons.task_alt_rounded;
      case AppSnackBarType.error:
        return Icons.cancel_rounded;
      case AppSnackBarType.warning:
        return Icons.warning_rounded;
      case AppSnackBarType.info:
        return Icons.info_rounded;
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.radius),
        splashColor: color.withValues(alpha: 0.18),
        highlightColor: color.withValues(alpha: 0.10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.radius,
            vertical: 8.radius,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10.radius),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            label,
            style: context.f14m.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseWidget extends StatefulWidget {
  const _PulseWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 1100),
    this.minScale = 0.86,
    this.maxScale = 1.12,
  });

  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _scaleAnimation =
        Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

class _StatusIconBadge extends StatelessWidget {
  const _StatusIconBadge({
    required this.icon,
    required this.foregroundColor,
    this.size = 36.0,
  });

  final IconData icon;
  final Color foregroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _PulseWidget(
      duration: const Duration(milliseconds: 1400),
      minScale: 0.90,
      maxScale: 1.08,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              foregroundColor.withValues(alpha: 0.30),
              foregroundColor.withValues(alpha: 0.14),
            ],
          ),
          border: Border.all(
            color: foregroundColor.withValues(alpha: 0.40),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: foregroundColor.withValues(alpha: 0.32),
              blurRadius: 12,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: context.customAppColors.neutral950.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: foregroundColor, size: (size * 0.46).font),
        ),
      ),
    );
  }
}

class _CircularCloseButtonProgress extends StatelessWidget {
  const _CircularCloseButtonProgress({
    required this.progress,
    required this.foregroundColor,
    required this.onTap,
    this.showProgress = true,
    this.size = 28.0,
    this.strokeWidth = 2.2,
  });

  final double progress;
  final Color foregroundColor;
  final VoidCallback onTap;
  final bool showProgress;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final innerPadding = showProgress ? (strokeWidth + 2.5) : 0.0;
    final innerSize = size - (innerPadding * 2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        splashColor: foregroundColor.withValues(alpha: 0.18),
        highlightColor: foregroundColor.withValues(alpha: 0.10),
        child: Semantics(
          button: true,
          label: 'Dismiss notification',
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (showProgress)
                  CustomPaint(
                    size: Size(size, size),
                    painter: _CircularProgressPainter(
                      progress: progress.clamp(0.0, 1.0),
                      color: foregroundColor,
                      strokeWidth: strokeWidth,
                    ),
                  ),
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        foregroundColor.withValues(alpha: 0.22),
                        foregroundColor.withValues(alpha: 0.10),
                      ],
                    ),
                    border: Border.all(
                      color: foregroundColor.withValues(alpha: 0.30),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: foregroundColor.withValues(alpha: 0.20),
                        blurRadius: 6,
                        spreadRadius: -1,
                      ),
                      BoxShadow(
                        color: context.customAppColors.neutral950.withValues(
                          alpha: 0.10,
                        ),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: (innerSize * 0.52).font,
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    const double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * progress;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 1.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * math.pi,
        colors: [
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.85),
          color,
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: const GradientRotation(startAngle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    final double endAngle = startAngle + sweepAngle;
    final Offset tipOffset = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );

    final glowDotPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(tipOffset, strokeWidth * 1.3, glowDotPaint);

    final tipDotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(tipOffset, strokeWidth * 0.75, tipDotPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
