import 'package:cubit_architecture/core/helpers/dimensions_helper.dart';
import 'package:cubit_architecture/core/theme/theme_manager/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size,
    this.color,
    this.padding,
    this.type = AppLoadingIndicatorType.fallingDot,
    this.centered = true,
    this.unconstrained = true,
  });

  final double? size;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final AppLoadingIndicatorType type;
  final bool centered;
  final bool unconstrained;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = Padding(
      padding: padding ?? EdgeInsets.zero,

      child: _LoadingIndicator(
        type: type,
        size: size ?? 40.radius,
        color: color ?? context.customAppColors.neutral500,
      ),
    );

    if (centered) {
      final Widget centeredIndicator = Center(child: indicator);

      if (unconstrained) {
        return UnconstrainedBox(child: centeredIndicator);
      }

      return centeredIndicator;
    }

    if (unconstrained) {
      return UnconstrainedBox(child: indicator);
    }

    return indicator;
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({
    required this.type,
    required this.size,
    required this.color,
  });

  final AppLoadingIndicatorType type;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppLoadingIndicatorType.fallingDot:
        return LoadingAnimationWidget.fallingDot(color: color, size: size);

      case AppLoadingIndicatorType.staggeredDotsWave:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: color,
          size: size,
        );

      case AppLoadingIndicatorType.threeRotatingDots:
        return LoadingAnimationWidget.threeRotatingDots(
          color: color,
          size: size,
        );

      case AppLoadingIndicatorType.fourRotatingDots:
        return LoadingAnimationWidget.fourRotatingDots(
          color: color,
          size: size,
        );

      case AppLoadingIndicatorType.threeArchedCircle:
        return LoadingAnimationWidget.threeArchedCircle(
          color: color,
          size: size,
        );

      case AppLoadingIndicatorType.progressiveDots:
        return LoadingAnimationWidget.progressiveDots(color: color, size: size);

      case AppLoadingIndicatorType.hexagonDots:
        return LoadingAnimationWidget.hexagonDots(color: color, size: size);

      case AppLoadingIndicatorType.beat:
        return LoadingAnimationWidget.beat(color: color, size: size);

      case AppLoadingIndicatorType.twoRotatingArc:
        return LoadingAnimationWidget.twoRotatingArc(color: color, size: size);

      case AppLoadingIndicatorType.twistingDots:
        return LoadingAnimationWidget.twistingDots(
          leftDotColor: color.withValues(alpha: 0.7),
          rightDotColor: color,
          size: size,
        );

      case AppLoadingIndicatorType.waveDots:
        return LoadingAnimationWidget.waveDots(color: color, size: size);
    }
  }
}

enum AppLoadingIndicatorType {
  fallingDot,
  staggeredDotsWave,
  threeRotatingDots,
  fourRotatingDots,
  threeArchedCircle,
  progressiveDots,
  hexagonDots,
  beat,
  twoRotatingArc,
  twistingDots,
  waveDots,
}
