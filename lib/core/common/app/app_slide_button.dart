import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import '../../helpers/asset_helper.dart';
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
    this.sliderIcon = 'arrow_right',
    this.sliderIconColor,
  });

  final String text;
  final String? doneText;
  final bool isLoading;
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
  final String sliderIcon;
  final Color? sliderIconColor;

  @override
  State<AppSlideButton> createState() => _AppSlideButtonState();
}

enum _SlideStatus { idle, dragging, loading, completed }

class _AppSlideButtonState extends State<AppSlideButton>
    with TickerProviderStateMixin {
  double _progress = 0;

  _SlideStatus _status = _SlideStatus.idle;

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

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(double dx, double maxDrag, bool isRtl) {
    if (_isLoading || _status == _SlideStatus.completed) return;

    setState(() {
      _status = _SlideStatus.dragging;

      final delta = dx / maxDrag;
      _progress = isRtl ? (_progress - delta) : (_progress + delta);

      _progress = _progress.clamp(0.0, 1.0);
    });

    _shimmerCtrl.stop();
  }

  Future<void> _onDragEnd() async {
    if (_isLoading || _status == _SlideStatus.completed) return;

    final shouldTrigger = _progress > 0.78;

    if (!shouldTrigger) {
      _resetThumb();
      return;
    }

    setState(() => _status = _SlideStatus.loading);

    await widget.onSlideCompleted?.call();

    if (!mounted) return;

    final shouldComplete = widget.shouldCompleteSlide?.call() ?? true;

    setState(() => _status = _SlideStatus.idle);

    if (shouldComplete) {
      _complete();
    } else {
      _resetThumb();
    }
  }

  void _complete() {
    if (!mounted) return;

    setState(() => _status = _SlideStatus.completed);
    _rippleCtrl.forward(from: 0);
  }

  void _resetThumb() {
    setState(() {
      _progress = 0;
      _status = _SlideStatus.idle;
    });

    _shimmerCtrl.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.RTL;

    final double buttonHeight = widget.height ?? 48.height;
    final double buttonWidth = widget.width ?? double.infinity;

    final double sliderSize = (buttonHeight - 14.radius);
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

        final double xOffset = isRtl
            ? (1 - _progress) * maxDrag
            : _progress * maxDrag;

        return CupertinoButton(
          onPressed: _status == _SlideStatus.completed ? _resetThumb : null,
          padding: EdgeInsets.zero,
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
                    trackStart: trackStart,
                    trackEnd: trackEnd,
                    radius: widget.radius ?? 50.radius,
                    rippleProgress: _ripple.value,
                    shimmerProgress: _shimmer.value,
                    sliderCenter: Offset(
                      xOffset + 6.radius + sliderSize / 2,
                      buttonHeight / 2,
                    ),
                    isCompleted: _status == _SlideStatus.completed,
                    showShimmer:
                        _status != _SlideStatus.completed &&
                        _status != _SlideStatus.dragging,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      widget.radius ?? 50.radius,
                    ),
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

                        if (_status == _SlideStatus.completed)
                          _DoneOverlay(
                            doneText: widget.doneText ?? context.tr('done'),
                            textStyle: widget.textStyle,
                          ),

                        if (_status != _SlideStatus.completed)
                          Positioned(
                            left: isRtl ? null : xOffset + 6.radius,
                            right: isRtl ? xOffset + 6.radius : null,
                            top: (buttonHeight - sliderSize) / 2,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onHorizontalDragUpdate: (d) =>
                                  _onDragUpdate(d.delta.dx, maxDrag, isRtl),
                              onHorizontalDragEnd: (_) => _onDragEnd(),
                              child: _SlideThumb(
                                sliderSize: sliderSize,
                                sliderBg: sliderBg,
                                iconColor: iconColor,
                                sliderIcon: widget.sliderIcon,
                                isLoading: _isLoading,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
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
          Text(doneText, style: context.f14m.copyWith(color: color)),

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
  });

  final double sliderSize;
  final Color sliderBg;
  final Color iconColor;
  final String sliderIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: sliderSize,
      width: sliderSize,
      decoration: BoxDecoration(color: sliderBg, shape: BoxShape.circle),
      child: Center(
        child: isLoading
            ? AppLoadingIndicator(color: iconColor, size: sliderSize / 1.5)
            : Center(
                child: SvgPicture.asset(
                  AssetHelper.iconSVGPath(sliderIcon),
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  width: 22.radius,
                  height: 22.radius,
                ),
              ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
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
  });

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
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Offset.zero & size),
    );

    if (progress > 0 && !isCompleted) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width * progress, size.height),
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.lerp(trackStart, context.customAppColors.neutral0, 0.22)!,
              Color.lerp(trackEnd, context.customAppColors.neutral0, 0.10)!,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(Offset.zero & size),
      );
    }

    if (showShimmer) {
      final double cx = shimmerProgress * size.width;
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
      old.isCompleted != isCompleted;
}
