import 'package:cached_network_image/cached_network_image.dart';
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
    this.errorIconSize,
    this.enablePreview = false,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.errorIconColor,
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
  final Color? errorIconColor;
  final BoxShape shape;
  final Clip clipBehavior;
  final Widget? child;
  final VoidCallback? onTap;
  final Color? loadingColor;
  final double? loaderSize;
  final double? errorIconSize;
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
    final double computedLoaderSize = _computeLoaderSize(context);
    final BoxDecoration decoration = _buildDecoration(context);

    if (url.trim().isEmpty || !_isValidUrl) {
      return _AppNetworkImageErrorFallback(
        errorWidget: errorWidget,
        errorIcon: errorIcon,
        errorIconSize: errorIconSize ?? computedLoaderSize,
        errorIconColor: errorIconColor,
        width: width,
        height: height,
        decoration: decoration,
        backgroundColor: backgroundColor,
      );
    }

    final Widget imageWidget = _isSvg
        ? _AppNetworkImageSvg(
            url: url,
            fit: fit,
            width: width,
            height: height,
            alignment: alignment,
            clipBehavior: clipBehavior,
            decoration: decoration,
            placeholder: placeholder,
            loaderSize: computedLoaderSize,
            loadingColor: loadingColor,
          )
        : _AppNetworkImageRaster(
            url: url,
            fit: fit,
            width: width,
            height: height,
            alignment: alignment,
            clipBehavior: clipBehavior,
            decoration: decoration,
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
            filterQuality: filterQuality,
            placeholder: placeholder,
            loaderSize: computedLoaderSize,
            loadingColor: loadingColor,
            errorWidget: errorWidget,
            errorIcon: errorIcon,
            errorIconSize: errorIconSize ?? computedLoaderSize,
            errorIconColor: errorIconColor,
            backgroundColor: backgroundColor,
            child: child,
          );

    final Widget wrapped = Semantics(
      label: semanticLabel,
      image: true,
      child: imageWidget,
    );

    final VoidCallback? action = _resolveTapAction();

    if (action == null) {
      return wrapped;
    }

    return GestureDetector(onTap: action, child: wrapped);
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

  double _computeLoaderSize(BuildContext context) {
    if (loaderSize != null) {
      return loaderSize!;
    }

    if (height != null && height!.isFinite) {
      return height! / 3;
    }

    return 24.radius;
  }

  BoxDecoration _buildDecoration(BuildContext context) {
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

class _AppNetworkImageRaster extends StatelessWidget {
  const _AppNetworkImageRaster({
    required this.url,
    required this.fit,
    this.width,
    this.height,
    required this.alignment,
    required this.clipBehavior,
    required this.decoration,
    this.memCacheWidth,
    this.memCacheHeight,
    required this.filterQuality,
    this.placeholder,
    this.loaderSize,
    this.loadingColor,
    this.errorWidget,
    this.errorIcon,
    this.errorIconSize,
    this.errorIconColor,
    this.backgroundColor,
    this.child,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Clip clipBehavior;
  final BoxDecoration decoration;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final FilterQuality filterQuality;
  final Widget? placeholder;
  final double? loaderSize;
  final Color? loadingColor;
  final Widget? errorWidget;
  final Widget? errorIcon;
  final double? errorIconSize;
  final Color? errorIconColor;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
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
          decoration: decoration.copyWith(
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
          decoration: decoration,
          child: _AppNetworkImagePlaceholder(
            placeholder: placeholder,
            loaderSize: loaderSize,
            loadingColor: loadingColor,
          ),
        );
      },
      errorWidget: (_, _, _) {
        return _AppNetworkImageErrorFallback(
          errorWidget: errorWidget,
          errorIcon: errorIcon,
          errorIconSize: errorIconSize,
          errorIconColor: errorIconColor,
          width: width,
          height: height,
          decoration: decoration,
          backgroundColor: backgroundColor,
        );
      },
    );
  }
}

class _AppNetworkImageSvg extends StatelessWidget {
  const _AppNetworkImageSvg({
    required this.url,
    required this.fit,
    this.width,
    this.height,
    required this.alignment,
    required this.clipBehavior,
    required this.decoration,
    this.placeholder,
    this.loaderSize,
    this.loadingColor,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final Clip clipBehavior;
  final BoxDecoration decoration;
  final Widget? placeholder;
  final double? loaderSize;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      clipBehavior: clipBehavior,
      decoration: decoration,
      child: SvgPicture.network(
        url,
        fit: fit,
        alignment: alignment,
        placeholderBuilder: (_) => Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: decoration,
          child: _AppNetworkImagePlaceholder(
            placeholder: placeholder,
            loaderSize: loaderSize,
            loadingColor: loadingColor,
          ),
        ),
      ),
    );
  }
}

class _AppNetworkImagePlaceholder extends StatelessWidget {
  const _AppNetworkImagePlaceholder({
    this.placeholder,
    this.loaderSize,
    this.loadingColor,
  });

  final Widget? placeholder;
  final double? loaderSize;
  final Color? loadingColor;

  @override
  Widget build(BuildContext context) {
    if (placeholder != null) {
      return placeholder!;
    }

    return AppLoadingIndicator(
      size: loaderSize ?? 24.radius,
      color: loadingColor ?? context.customAppColors.primary600,
    );
  }
}

class _AppNetworkImageErrorFallback extends StatelessWidget {
  const _AppNetworkImageErrorFallback({
    this.errorWidget,
    this.errorIcon,
    this.errorIconSize,
    this.errorIconColor,
    this.width,
    this.height,
    required this.decoration,
    this.backgroundColor,
  });

  final Widget? errorWidget;
  final Widget? errorIcon;
  final double? errorIconSize;
  final Color? errorIconColor;
  final double? width;
  final double? height;
  final BoxDecoration decoration;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: decoration.copyWith(
        color: backgroundColor ?? context.customAppColors.neutral100,
      ),
      child:
          errorIcon ??
          Icon(
            Icons.error_rounded,
            size: errorIconSize ?? 24.radius,
            color: errorIconColor ?? context.customAppColors.neutral500,
          ),
    );
  }
}
