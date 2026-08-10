import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
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
    ImageFitMode.fitWidth: CupertinoIcons.arrow_left_right,
    ImageFitMode.fitHeight: CupertinoIcons.arrow_up_down,
    ImageFitMode.contain: CupertinoIcons.fullscreen_exit,
    ImageFitMode.cover: CupertinoIcons.crop,
    ImageFitMode.fill: CupertinoIcons.fullscreen,
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
    final values = ImageFitMode.values;

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

          _topBar(),

          _bottomBar(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _overlayController,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.width,
              vertical: 12.height,
            ),
            child: Row(
              children: [
                _actionButton(
                  icon: CupertinoIcons.xmark,
                  onTap: RouteManager.pop,
                ),

                const Spacer(),

                _actionButton(
                  icon: CupertinoIcons.rotate_left,
                  onTap: _rotateLeft,
                ),

                horizontalGap(12),

                _actionButton(icon: _fitIcons[_fitMode]!, onTap: _changeFit),

                horizontalGap(12),

                _actionButton(
                  icon: CupertinoIcons.rotate_right,
                  onTap: _rotateRight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _overlayController,
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
                      _infoItem(
                        icon: _fitIcons[_fitMode]!,
                        label: _fitMode.label(context),
                      ),

                      _infoItem(
                        icon: CupertinoIcons.zoom_in,
                        label: '${(_currentScale * 100).toInt()}%',
                      ),

                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _resetZoom,
                        minimumSize: Size(0, 0),
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

  Widget _infoItem({required IconData icon, required String label}) {
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

  Widget _actionButton({required IconData icon, required VoidCallback onTap}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: context.customAppColors.neutral900.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: context.customAppColors.neutral900.withValues(alpha: 0.12),
            ),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            minimumSize: Size.zero,
            child: SizedBox(
              width: 46.radius,
              height: 46.radius,
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
