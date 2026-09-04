import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../localization/locale_keys.g.dart';
import '../../routing/route_manager.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_network_image.dart';

class ImageView extends StatefulWidget {
  const ImageView({super.key, required this.imageUrl});

  final String imageUrl;

  void show() {
    RouteManager.navigateTo(this, animation: RouteAnimation.fade);
  }

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  late final AnimationController _overlayController;

  bool _showControls = true;

  int _quarterTurns = 0;

  ImageFitMode _fitMode = ImageFitMode.contain;

  double _currentScale = 1.0;

  static const double _minScale = 1;
  static const double _maxScale = 5;

  static const _fitIcons = {
    ImageFitMode.fitWidth: Icons.swap_horiz_rounded,
    ImageFitMode.fitHeight: Icons.swap_vert_rounded,
    ImageFitMode.contain: Icons.fullscreen_exit_rounded,
    ImageFitMode.cover: Icons.crop_rounded,
    ImageFitMode.fill: Icons.fullscreen_rounded,
  };

  @override
  void initState() {
    super.initState();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }
  }

  void _rotateLeft() {
    setState(() {
      _quarterTurns = (_quarterTurns - 1) % 4;
    });
  }

  void _rotateRight() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  void _changeFit() {
    const values = ImageFitMode.values;

    setState(() {
      _fitMode = values[(_fitMode.index + 1) % values.length];
    });
  }

  void _resetEverything() {
    _transformationController.value = Matrix4.identity();

    setState(() {
      _currentScale = 1.0;
      _quarterTurns = 0;
      _fitMode = ImageFitMode.contain;
    });
  }

  void _handleDoubleTap() {
    if (_currentScale > 1) {
      _transformationController.value = Matrix4.identity();
      setState(() {
        _currentScale = 1.0;
      });
      return;
    }

    final matrix = Matrix4.identity();
    matrix.scaleByDouble(2.0, 2.0, 1.0, 1.0);
    _transformationController.value = matrix;

    setState(() {
      _currentScale = 2.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: colors.neutral50,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControls,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: _minScale,
                maxScale: _maxScale,
                onInteractionUpdate: (details) {
                  setState(() {
                    _currentScale = details.scale;
                  });
                },
                child: SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: _quarterTurns,
                      child: SizedBox(
                        width: (_quarterTurns % 2 == 0)
                            ? screenSize.width
                            : screenSize.height,
                        height: (_quarterTurns % 2 == 0)
                            ? screenSize.height
                            : screenSize.width,
                        child: Hero(
                          tag: widget.imageUrl,
                          child: AppNetworkImage(
                            url: widget.imageUrl,
                            fit: _fitMode.fit,
                            width: double.infinity,
                            height: double.infinity,
                            enablePreview: false,
                            backgroundColor: colors.neutral0.withValues(
                              alpha: 0.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top Gradient Scrim for guaranteed contrast
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120.height,
            child: FadeTransition(
              opacity: _overlayController,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.neutral950.withValues(alpha: 0.55),
                        colors.neutral950.withValues(alpha: 0.25),
                        colors.neutral950.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Gradient Scrim for guaranteed contrast
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 130.height,
            child: FadeTransition(
              opacity: _overlayController,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        colors.neutral950.withValues(alpha: 0.55),
                        colors.neutral950.withValues(alpha: 0.25),
                        colors.neutral950.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          _ImageViewTopBar(
            overlayAnimation: _overlayController,
            fitMode: _fitMode,
            fitIcon: _fitIcons[_fitMode]!,
            onRotateLeft: _rotateLeft,
            onRotateRight: _rotateRight,
            onChangeFit: _changeFit,
          ),

          _ImageViewBottomBar(
            overlayAnimation: _overlayController,
            fitMode: _fitMode,
            fitIcon: _fitIcons[_fitMode]!,
            currentScale: _currentScale,
            onReset: _resetEverything,
          ),
        ],
      ),
    );
  }
}

class _ImageViewTopBar extends StatelessWidget {
  const _ImageViewTopBar({
    required this.overlayAnimation,
    required this.fitMode,
    required this.fitIcon,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onChangeFit,
  });

  final Animation<double> overlayAnimation;
  final ImageFitMode fitMode;
  final IconData fitIcon;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onChangeFit;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: overlayAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.width,
              vertical: 12.height,
            ),
            child: Row(
              children: [
                const _ImageViewActionButton(
                  icon: Icons.close_rounded,
                  onTap: RouteManager.pop,
                ),

                const Spacer(),

                // Grouped Toolbar Capsule for Actions
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: EdgeInsets.all(4.radius),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.neutral950.withValues(alpha: 0.65),
                            colors.neutral900.withValues(alpha: 0.45),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50.radius),
                        border: Border.all(
                          color: colors.neutral0.withValues(alpha: 0.22),
                          width: 1.width,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.neutral950.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ImageViewToolbarButton(
                            icon: Icons.rotate_left_rounded,
                            onTap: onRotateLeft,
                          ),

                          Container(
                            width: 1,
                            height: 20.height,
                            margin: EdgeInsets.symmetric(horizontal: 2.width),
                            color: colors.neutral0.withValues(alpha: 0.15),
                          ),

                          _ImageViewToolbarButton(
                            icon: fitIcon,
                            onTap: onChangeFit,
                            isAnimated: true,
                          ),

                          Container(
                            width: 1,
                            height: 20.height,
                            margin: EdgeInsets.symmetric(horizontal: 2.width),
                            color: colors.neutral0.withValues(alpha: 0.15),
                          ),

                          _ImageViewToolbarButton(
                            icon: Icons.rotate_right_rounded,
                            onTap: onRotateRight,
                          ),
                        ],
                      ),
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

class _ImageViewToolbarButton extends StatelessWidget {
  const _ImageViewToolbarButton({
    required this.icon,
    required this.onTap,
    this.isAnimated = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return Material(
      color: colors.neutral0.withValues(alpha: 0.0),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: colors.neutral0.withValues(alpha: 0.25),
        highlightColor: colors.neutral0.withValues(alpha: 0.1),
        child: Container(
          width: 38.radius,
          height: 38.radius,
          alignment: Alignment.center,
          child: isAnimated
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    icon,
                    key: ValueKey<IconData>(icon),
                    color: colors.neutral0,
                    size: 20.radius,
                    shadows: [
                      Shadow(
                        color: colors.neutral950.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                )
              : Icon(
                  icon,
                  color: colors.neutral0,
                  size: 20.radius,
                  shadows: [
                    Shadow(
                      color: colors.neutral950.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ImageViewBottomBar extends StatelessWidget {
  const _ImageViewBottomBar({
    required this.overlayAnimation,
    required this.fitMode,
    required this.fitIcon,
    required this.currentScale,
    required this.onReset,
  });

  final Animation<double> overlayAnimation;
  final ImageFitMode fitMode;
  final IconData fitIcon;
  final double currentScale;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: overlayAnimation,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.width,
              vertical: 16.height,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.width,
                    vertical: 10.height,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.neutral950.withValues(alpha: 0.70),
                        colors.neutral900.withValues(alpha: 0.50),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30.radius),
                    border: Border.all(
                      color: colors.neutral0.withValues(alpha: 0.22),
                      width: 1.width,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.neutral950.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: colors.neutral950.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Fit Mode info
                      _ImageViewInfoItem(
                        icon: fitIcon,
                        label: fitMode.label(context),
                      ),

                      Container(
                        width: 1,
                        height: 20.height,
                        color: colors.neutral0.withValues(alpha: 0.18),
                      ),

                      // Scale Percentage info
                      _ImageViewInfoItem(
                        icon: Icons.zoom_in_rounded,
                        label: '${(currentScale * 100).toInt()}%',
                      ),

                      Container(
                        width: 1,
                        height: 20.height,
                        color: colors.neutral0.withValues(alpha: 0.18),
                      ),

                      // Interactive Reset Button
                      Material(
                        color: colors.neutral0.withValues(alpha: 0.0),
                        child: InkWell(
                          onTap: onReset,
                          borderRadius: BorderRadius.circular(16.radius),
                          splashColor: colors.neutral0.withValues(alpha: 0.25),
                          highlightColor: colors.neutral0.withValues(
                            alpha: 0.12,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.width,
                              vertical: 6.height,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colors.neutral0.withValues(alpha: 0.26),
                                  colors.neutral0.withValues(alpha: 0.14),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16.radius),
                              border: Border.all(
                                color: colors.neutral0.withValues(alpha: 0.35),
                                width: 1.width,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.neutral950.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.restart_alt_rounded,
                                  size: 14.radius,
                                  color: colors.neutral0,
                                ),
                                horizontalGap(5),
                                Text(
                                  LocaleKeys.image_view_reset.tr(),
                                  style: context.f12sb.copyWith(
                                    color: colors.neutral0,
                                    shadows: [
                                      Shadow(
                                        color: colors.neutral950.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageViewInfoItem extends StatelessWidget {
  const _ImageViewInfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26.radius,
          height: 26.radius,
          decoration: BoxDecoration(
            color: colors.neutral0.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.neutral0.withValues(alpha: 0.15),
              width: 1.width,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 14.radius,
            color: colors.neutral0,
            shadows: [
              Shadow(
                color: colors.neutral950.withValues(alpha: 0.5),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),

        horizontalGap(8),

        Text(
          label,
          style: context.f12m.copyWith(
            color: colors.neutral0,
            shadows: [
              Shadow(
                color: colors.neutral950.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageViewActionButton extends StatelessWidget {
  const _ImageViewActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: colors.neutral0.withValues(alpha: 0.0),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            splashColor: colors.neutral0.withValues(alpha: 0.25),
            highlightColor: colors.neutral0.withValues(alpha: 0.12),
            customBorder: const CircleBorder(),
            child: Container(
              width: 44.radius,
              height: 44.radius,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.neutral950.withValues(alpha: 0.65),
                    colors.neutral900.withValues(alpha: 0.45),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.neutral0.withValues(alpha: 0.25),
                  width: 1.width,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.neutral950.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: colors.neutral0,
                size: 20.radius,
                shadows: [
                  Shadow(
                    color: colors.neutral950.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ImageFitMode { fitWidth, fitHeight, contain, cover, fill }

extension ImageFitModeX on ImageFitMode {
  BoxFit get fit {
    switch (this) {
      case ImageFitMode.fitWidth:
        return BoxFit.fitWidth;

      case ImageFitMode.fitHeight:
        return BoxFit.fitHeight;

      case ImageFitMode.contain:
        return BoxFit.contain;

      case ImageFitMode.cover:
        return BoxFit.cover;

      case ImageFitMode.fill:
        return BoxFit.fill;
    }
  }

  String label(BuildContext context) {
    switch (this) {
      case ImageFitMode.fitWidth:
        return LocaleKeys.image_view_fit_width.tr();

      case ImageFitMode.fitHeight:
        return LocaleKeys.image_view_fit_height.tr();

      case ImageFitMode.contain:
        return LocaleKeys.image_view_contain.tr();

      case ImageFitMode.cover:
        return LocaleKeys.image_view_cover.tr();

      case ImageFitMode.fill:
        return LocaleKeys.image_view_fill.tr();
    }
  }
}
