import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../helpers/dimensions_helper.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_loading_indicator.dart';
import 'image_view.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.alignment = Alignment.center,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    this.shape = BoxShape.rectangle,
    this.clipBehavior = Clip.antiAlias,
    this.child,
    this.onTap,
    this.loadingColor,
    this.loaderSize,
    this.errorSize,
    this.enablePreview = false,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.errorColor,
    this.errorIcon,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Alignment alignment;
  final Color? borderColor;
  final double? borderWidth;
  final Color? backgroundColor;
  final Color? errorColor;
  final BoxShape shape;
  final Clip clipBehavior;
  final Widget? child;
  final VoidCallback? onTap;
  final Color? loadingColor;
  final double? loaderSize;
  final double? errorSize;
  final bool enablePreview;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Widget? errorIcon;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final FilterQuality filterQuality;
  final String? semanticLabel;

  bool get _isSvg => url.toLowerCase().split('?').first.endsWith('.svg');

  bool get _isValidUrl {
    final uri = Uri.tryParse(url);

    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty || !_isValidUrl) {
      return _errorFallback(context);
    }

    final Widget imageWidget = _isSvg
        ? _buildSvg(context)
        : _buildRaster(context);

    final Widget wrapped = Semantics(
      label: semanticLabel,
      image: true,
      child: imageWidget,
    );

    final VoidCallback? action = _resolveTapAction();

    if (action == null) {
      return wrapped;
    }

    return CupertinoButton(
      onPressed: action,
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      child: wrapped,
    );
  }

  Widget _buildSvg(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      clipBehavior: clipBehavior,
      decoration: _decoration,
      child: SvgPicture.network(
        url,
        fit: fit,
        alignment: alignment,
        placeholderBuilder: (_) => _placeholder(context),
      ),
    );
  }

  Widget _buildRaster(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),

      imageBuilder: (_, imageProvider) {
        return Container(
          width: width,
          height: height,
          clipBehavior: clipBehavior,
          decoration: _decoration.copyWith(
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
              alignment: alignment,
              filterQuality: filterQuality,
            ),
          ),
          child: child,
        );
      },

      placeholder: (_, _) {
        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: _decoration,
          child: _placeholder(context),
        );
      },

      errorWidget: (_, _, _) {
        return _errorFallback(context);
      },
    );
  }

  Widget _placeholder(BuildContext context) {
    if (placeholder != null) {
      return placeholder!;
    }

    return AppLoadingIndicator(
      size: _computedLoaderSize,
      color: loadingColor ?? context.customAppColors.primary600,
    );
  }

  Widget _errorFallback(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: _decoration.copyWith(
        color: backgroundColor ?? context.customAppColors.neutral100,
      ),
      child:
          errorIcon ??
          Icon(
            CupertinoIcons.photo,
            size: errorSize ?? _computedLoaderSize,
            color: errorColor ?? context.customAppColors.neutral500,
          ),
    );
  }

  VoidCallback? _resolveTapAction() {
    if (onTap != null) {
      return onTap;
    }

    if (enablePreview) {
      return () {
        ImageView(imageUrl: url).show();
      };
    }

    return null;
  }

  double get _computedLoaderSize {
    if (loaderSize != null) {
      return loaderSize!;
    }

    if (height != null && height!.isFinite) {
      return height! / 3;
    }

    return 24.radius;
  }

  BoxDecoration get _decoration {
    return BoxDecoration(
      color: backgroundColor,
      shape: shape,
      border: Border.all(
        color: borderColor ?? Colors.transparent,
        width: borderWidth ?? 1.width,
      ),
      borderRadius: shape == BoxShape.rectangle
          ? BorderRadius.circular(borderRadius ?? 8.radius)
          : null,
    );
  }
}
