import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../routing/route_manager.dart';
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

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();

    setState(() {
      _currentScale = 1;
    });
  }

  void _handleDoubleTap() {
    if (_currentScale > 1) {
      _resetZoom();
      return;
    }

    final matrix = Matrix4.identity();

    matrix.scaleByDouble(2.0, 2.0, 1.0, 1.0);

    _transformationController.value = matrix;

    setState(() {
      _currentScale = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customAppColors.neutral50,
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
                child: Center(
                  child: RotatedBox(
                    quarterTurns: _quarterTurns,
                    child: Hero(
                      tag: widget.imageUrl,
                      child: AppNetworkImage(
                        url: widget.imageUrl,
                        fit: _fitMode.fit,
                      ),
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
            onResetZoom: _resetZoom,
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

                _ImageViewActionButton(
                  icon: Icons.rotate_left_rounded,
                  onTap: onRotateLeft,
                ),

                horizontalGap(12),

                _ImageViewActionButton(icon: fitIcon, onTap: onChangeFit),

                horizontalGap(12),

                _ImageViewActionButton(
                  icon: Icons.rotate_right_rounded,
                  onTap: onRotateRight,
                ),
              ],
            ),
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
    required this.onResetZoom,
  });

  final Animation<double> overlayAnimation;
  final ImageFitMode fitMode;
  final IconData fitIcon;
  final double currentScale;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: overlayAnimation,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(20.radius),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.radius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.width,
                    vertical: 14.height,
                  ),
                  decoration: BoxDecoration(
                    color: context.customAppColors.neutral900.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(24.radius),
                    border: Border.all(
                      color: context.customAppColors.neutral900.withValues(
                        alpha: 0.12,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ImageViewInfoItem(
                        icon: fitIcon,
                        label: fitMode.label(context),
                      ),

                      _ImageViewInfoItem(
                        icon: Icons.zoom_in_rounded,
                        label: '${(currentScale * 100).toInt()}%',
                      ),

                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onResetZoom,
                        child: Text(
                          context.tr('reset'),
                          style: TextStyle(
                            color: context.customAppColors.neutral900,
                            fontSize: 13.font,
                            fontWeight: FontWeight.w600,
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
    return Row(
      children: [
        Icon(icon, size: 16.radius, color: context.customAppColors.neutral900),

        horizontalGap(8),

        Text(
          label,
          style: TextStyle(
            color: context.customAppColors.neutral900,
            fontSize: 13.font,
            fontWeight: FontWeight.w600,
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
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: context.customAppColors.neutral900.withValues(alpha: 0.12),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 46.radius,
              height: 46.radius,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.customAppColors.neutral900.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              child: Icon(
                icon,
                color: context.customAppColors.neutral900,
                size: 22.radius,
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
        return context.tr('fit_width');

      case ImageFitMode.fitHeight:
        return context.tr('fit_height');

      case ImageFitMode.contain:
        return context.tr('contain');

      case ImageFitMode.cover:
        return context.tr('cover');

      case ImageFitMode.fill:
        return context.tr('fill');
    }
  }
}
