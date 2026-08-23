import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_loading_indicator.dart';

class AppSlideButton extends StatefulWidget {
  const AppSlideButton({
    super.key,
    required this.text,
    this.doneText,
    this.isLoading = false,
    this.enabled = true,
    this.autoReset = true,
    this.doneDisplayDuration = const Duration(seconds: 5),
    this.shouldCompleteSlide,
    this.onSlideCompleted,
    this.height,
    this.width,
    this.radius,
    this.textStyle,
    this.trackColor,
    this.trackColorEnd,
    this.sliderColor,
    this.textColor,
    this.disabledTrackColor,
    this.sliderIcon,
    this.sliderIconColor,
    this.enableHapticFeedback = true,
    this.completionThreshold = 0.78,
  }) : assert(
         completionThreshold > 0 && completionThreshold <= 1.0,
         'completionThreshold must be between 0 (exclusive) and 1 (inclusive)',
       );

  final String text;
  final String? doneText;
  final bool isLoading;
  final bool enabled;
  final bool autoReset;
  final Duration doneDisplayDuration;
  final bool Function()? shouldCompleteSlide;
  final Future<void> Function()? onSlideCompleted;
  final double? height;
  final double? width;
  final double? radius;
  final TextStyle? textStyle;
  final Color? trackColor;
  final Color? trackColorEnd;
  final Color? sliderColor;
  final Color? textColor;
  final Color? disabledTrackColor;
  final Widget? sliderIcon;
  final Color? sliderIconColor;
  final bool enableHapticFeedback;
  final double completionThreshold;

  @override
  State<AppSlideButton> createState() => AppSlideButtonState();
}

enum _SlideStatus { idle, dragging, loading, completed }

class AppSlideButtonState extends State<AppSlideButton>
    with TickerProviderStateMixin {
  double _progress = 0;

  _SlideStatus _status = _SlideStatus.idle;

  Timer? _autoResetTimer;

  late final AnimationController _snapCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  late final AnimationController _rippleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  late final AnimationController _shimmerCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  Animation<double> get _ripple =>
      CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut);

  Animation<double> get _shimmer => Tween<double>(
    begin: -0.4,
    end: 1.4,
  ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

  bool get _isLoading => _status == _SlideStatus.loading || widget.isLoading;

  bool get _isInteractive =>
      widget.enabled && !_isLoading && _status != _SlideStatus.completed;

  @override
  void didUpdateWidget(covariant AppSlideButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && !oldWidget.isLoading) {
      _shimmerCtrl.stop();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      if (_status == _SlideStatus.idle) _shimmerCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _autoResetTimer?.cancel();
    _snapCtrl.dispose();
    _rippleCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void reset() {
    _autoResetTimer?.cancel();

    if (!mounted) return;

    _animateProgressTo(
      0,
      onDone: () {
        if (!mounted) return;
        setState(() => _status = _SlideStatus.idle);
        _shimmerCtrl.repeat();
      },
    );
  }

  void _onDragUpdate(double dx, double maxDrag, bool isRtl) {
    if (!_isInteractive) return;

    setState(() {
      _status = _SlideStatus.dragging;

      final delta = dx / maxDrag;
      _progress = isRtl ? (_progress - delta) : (_progress + delta);

      _progress = _progress.clamp(0.0, 1.0);
    });

    _shimmerCtrl.stop();
  }

  Future<void> _onDragEnd(DragEndDetails details, double maxDrag) async {
    if (!_isInteractive) return;

    final velocity = details.primaryVelocity ?? 0;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final effectiveVelocity = isRtl ? -velocity : velocity;

    final shouldTrigger =
        _progress > widget.completionThreshold ||
        (effectiveVelocity > 800 && _progress > 0.40);

    if (!shouldTrigger) {
      _animateProgressTo(
        0,
        onDone: () {
          if (!mounted) return;
          setState(() => _status = _SlideStatus.idle);
          _shimmerCtrl.repeat();
        },
      );
      return;
    }

    _animateProgressTo(1.0);

    setState(() => _status = _SlideStatus.loading);

    await widget.onSlideCompleted?.call();

    if (!mounted) return;

    final shouldComplete = widget.shouldCompleteSlide?.call() ?? true;

    if (shouldComplete) {
      _complete();
    } else {
      _animateProgressTo(
        0,
        onDone: () {
          if (!mounted) return;
          setState(() => _status = _SlideStatus.idle);
          _shimmerCtrl.repeat();
        },
      );
    }
  }

  void _complete() {
    if (!mounted) return;

    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    setState(() => _status = _SlideStatus.completed);
    _rippleCtrl.forward(from: 0);

    _autoResetTimer?.cancel();
    if (widget.autoReset) {
      _autoResetTimer = Timer(widget.doneDisplayDuration, () {
        if (mounted && _status == _SlideStatus.completed) {
          reset();
        }
      });
    }
  }

  void _animateProgressTo(double target, {VoidCallback? onDone}) {
    final start = _progress;

    _snapCtrl
      ..reset()
      ..duration = Duration(
        milliseconds: ((start - target).abs() * 350).toInt().clamp(120, 350),
      );

    late final Animation<double> tween;
    tween = Tween<double>(
      begin: start,
      end: target,
    ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic));

    void listener() {
      if (!mounted) return;
      setState(() => _progress = tween.value);
    }

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _snapCtrl.removeListener(listener);
        _snapCtrl.removeStatusListener(statusListener);
        onDone?.call();
      }
    }

    _snapCtrl.addListener(listener);
    _snapCtrl.addStatusListener(statusListener);
    _snapCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final double buttonHeight = widget.height ?? 56.height;
    final double buttonWidth = widget.width ?? double.infinity;
    final double cornerRadius = widget.radius ?? 50.radius;

    final double sliderSize = buttonHeight - 14.radius;
    final double edgePadding = sliderSize + 12.radius;

    final Color trackStart =
        widget.trackColor ?? context.customAppColors.primary600;
    final Color trackEnd =
        widget.trackColorEnd ??
        Color.lerp(trackStart, context.customAppColors.primary600, 0.28)!;

    final Color sliderBg =
        widget.sliderColor ?? context.customAppColors.neutral0;

    final Color iconColor = widget.sliderIconColor ?? trackStart;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = buttonWidth == double.infinity
            ? constraints.maxWidth
            : buttonWidth;

        final double maxDrag = maxWidth - sliderSize - 14.radius;

        final double xOffset = _progress * maxDrag;

        return Opacity(
          opacity: widget.enabled ? 1.0 : 0.45,
          child: IgnorePointer(
            ignoring: !widget.enabled,
            child: SizedBox(
              height: buttonHeight,
              width: maxWidth,
              child: AnimatedBuilder(
                animation: Listenable.merge([_rippleCtrl, _shimmerCtrl]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: _TrackPainter(
                      context: context,
                      progress: _progress,
                      trackStart: widget.enabled
                          ? trackStart
                          : (widget.disabledTrackColor ??
                                context.customAppColors.neutral300),
                      trackEnd: widget.enabled
                          ? trackEnd
                          : (widget.disabledTrackColor ??
                                context.customAppColors.neutral400),
                      radius: cornerRadius,
                      rippleProgress: _ripple.value,
                      shimmerProgress: _shimmer.value,
                      sliderCenter: Offset(
                        isRtl
                            ? (maxWidth - (xOffset + 6.radius + sliderSize / 2))
                            : (xOffset + 6.radius + sliderSize / 2),
                        buttonHeight / 2,
                      ),
                      isCompleted: _status == _SlideStatus.completed,
                      showShimmer:
                          _status != _SlideStatus.completed &&
                          _status != _SlideStatus.dragging,
                      isRtl: isRtl,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(cornerRadius),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _SlideLabel(
                            text: widget.text,
                            textStyle: widget.textStyle,
                            textColor: widget.textColor,
                            edgePadding: edgePadding,
                            isCompleted: _status == _SlideStatus.completed,
                            progress: _progress,
                          ),

                          if (_status == _SlideStatus.completed) ...[
                            Positioned.fill(
                              child: Builder(
                                builder: (context) {
                                  final rippleColor =
                                      context.customAppColors.neutral0;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        if (widget.enableHapticFeedback) {
                                          HapticFeedback.selectionClick();
                                        }
                                        reset();
                                      },
                                      borderRadius: BorderRadius.circular(
                                        cornerRadius,
                                      ),
                                      splashFactory: InkRipple.splashFactory,
                                      splashColor: rippleColor.withValues(
                                        alpha: 0.30,
                                      ),
                                      highlightColor: rippleColor.withValues(
                                        alpha: 0.28,
                                      ),
                                      hoverColor: rippleColor.withValues(
                                        alpha: 0.10,
                                      ),
                                      focusColor: rippleColor.withValues(
                                        alpha: 0.16,
                                      ),
                                      overlayColor:
                                          WidgetStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                              WidgetState.pressed,
                                            )) {
                                              return rippleColor.withValues(
                                                alpha: 0.34,
                                              );
                                            }
                                            if (states.contains(
                                              WidgetState.hovered,
                                            )) {
                                              return rippleColor.withValues(
                                                alpha: 0.10,
                                              );
                                            }
                                            if (states.contains(
                                              WidgetState.focused,
                                            )) {
                                              return rippleColor.withValues(
                                                alpha: 0.16,
                                              );
                                            }
                                            return null;
                                          }),
                                      mouseCursor: SystemMouseCursors.click,
                                      child: _DoneOverlay(
                                        doneText:
                                            widget.doneText ??
                                            context.tr('done'),
                                        textStyle: widget.textStyle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          if (_status != _SlideStatus.completed) ...[
                            Positioned(
                              left: isRtl ? null : xOffset + 6.radius,
                              right: isRtl ? xOffset + 6.radius : null,
                              top: (buttonHeight - sliderSize) / 2,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onHorizontalDragUpdate: (d) =>
                                    _onDragUpdate(d.delta.dx, maxDrag, isRtl),
                                onHorizontalDragEnd: (d) =>
                                    _onDragEnd(d, maxDrag),
                                child: _SlideThumb(
                                  sliderSize: sliderSize,
                                  sliderBg: sliderBg,
                                  iconColor: iconColor,
                                  sliderIcon:
                                      widget.sliderIcon ??
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: iconColor,
                                        size: 18.radius,
                                      ),
                                  isLoading: _isLoading,
                                  progress: _progress,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlideLabel extends StatelessWidget {
  const _SlideLabel({
    required this.text,
    required this.edgePadding,
    required this.isCompleted,
    required this.progress,
    this.textStyle,
    this.textColor,
  });

  final String text;
  final TextStyle? textStyle;
  final Color? textColor;
  final double edgePadding;
  final bool isCompleted;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: edgePadding),
      child: AnimatedOpacity(
        opacity: isCompleted ? 0 : (1 - progress * 0.7),
        duration: const Duration(milliseconds: 150),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                textStyle ??
                context.f14m.copyWith(
                  color: textColor ?? context.customAppColors.neutral0,
                ),
          ),
        ),
      ),
    );
  }
}

class _DoneOverlay extends StatelessWidget {
  const _DoneOverlay({required this.doneText, this.textStyle});

  final String doneText;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final color = context.customAppColors.neutral0;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            doneText,
            style: textStyle ?? context.f14m.copyWith(color: color),
          ),

          horizontalGap(8),

          Container(
            width: 22.radius,
            height: 22.radius,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5.radius),
            ),
            child: Icon(Icons.check_rounded, color: color, size: 14.radius),
          ),
        ],
      ),
    );
  }
}

class _SlideThumb extends StatelessWidget {
  const _SlideThumb({
    required this.sliderSize,
    required this.sliderBg,
    required this.iconColor,
    required this.sliderIcon,
    required this.isLoading,
    required this.progress,
  });

  final double sliderSize;
  final Color sliderBg;
  final Color iconColor;
  final Widget sliderIcon;
  final bool isLoading;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: sliderSize,
      width: sliderSize,
      decoration: BoxDecoration(
        color: sliderBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? AppLoadingIndicator(
                  key: const ValueKey('loading'),
                  color: iconColor,
                  size: sliderSize / 1.5,
                )
              : Transform.rotate(
                  key: const ValueKey('icon'),
                  angle: progress * 0.15,
                  child: sliderIcon,
                ),
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.context,
    required this.progress,
    required this.trackStart,
    required this.trackEnd,
    required this.radius,
    required this.rippleProgress,
    required this.shimmerProgress,
    required this.sliderCenter,
    required this.isCompleted,
    required this.showShimmer,
    required this.isRtl,
  });

  final BuildContext context;
  final double progress;
  final Color trackStart;
  final Color trackEnd;
  final double radius;
  final double rippleProgress;
  final double shimmerProgress;
  final Offset sliderCenter;
  final bool isCompleted;
  final bool showShimmer;
  final bool isRtl;

  @override
  void paint(Canvas canvas, Size size) {
    final rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    canvas.save();
    canvas.clipRRect(rRect);

    canvas.drawRRect(
      rRect,
      Paint()
        ..shader = LinearGradient(
          colors: [trackStart, trackEnd],
          begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        ).createShader(Offset.zero & size),
    );

    if (progress > 0 && !isCompleted) {
      final fillRect = isRtl
          ? Rect.fromLTWH(
              size.width * (1 - progress),
              0,
              size.width * progress,
              size.height,
            )
          : Rect.fromLTWH(0, 0, size.width * progress, size.height);

      canvas.drawRect(
        fillRect,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.lerp(trackStart, context.customAppColors.neutral0, 0.22)!,
              Color.lerp(trackEnd, context.customAppColors.neutral0, 0.10)!,
            ],
            begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
            end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
          ).createShader(Offset.zero & size),
      );
    }

    if (showShimmer) {
      final double cx = isRtl
          ? (1 - shimmerProgress) * size.width
          : shimmerProgress * size.width;
      final double bandHalf = size.width * 0.20;
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader =
              LinearGradient(
                colors: [
                  context.customAppColors.neutral0.withValues(alpha: 0.0),
                  context.customAppColors.neutral0.withValues(alpha: 0.14),
                  context.customAppColors.neutral0.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(
                Rect.fromCenter(
                  center: Offset(cx, size.height / 2),
                  width: bandHalf * 2,
                  height: size.height,
                ),
              ),
      );
    }

    if (rippleProgress > 0) {
      final maxR = math.sqrt(
        size.width * size.width + size.height * size.height,
      );
      canvas.drawCircle(
        sliderCenter,
        maxR * rippleProgress,
        Paint()
          ..color = context.customAppColors.neutral0.withValues(
            alpha: 0.22 * (1 - rippleProgress),
          )
          ..style = PaintingStyle.fill,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.progress != progress ||
      old.rippleProgress != rippleProgress ||
      old.shimmerProgress != shimmerProgress ||
      old.showShimmer != showShimmer ||
      old.isCompleted != isCompleted ||
      old.isRtl != isRtl;
}
