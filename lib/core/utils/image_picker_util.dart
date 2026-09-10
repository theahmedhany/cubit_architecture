import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/app/app_loading_indicator.dart';
import '../helpers/app_logger.dart';
import '../helpers/dimensions_helper.dart';
import '../helpers/media_helper.dart';
import '../helpers/spacing.dart';
import '../localization/locale_keys.g.dart';
import '../routing/route_manager.dart';
import '../theme/app_texts/app_text_styles.dart';
import '../theme/theme_manager/theme_extensions.dart';

abstract final class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<ImagePickResult> pickFromGallery({
    ImagePickOptions options = const ImagePickOptions(),
  }) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: options.imageQuality,
        maxWidth: options.maxWidth,
        maxHeight: options.maxHeight,
      );

      if (picked == null) {
        return const ImagePickCancelled();
      }

      return ImagePickSuccess([File(picked.path)]);
    } catch (e, st) {
      AppLogger.log(
        'Pick From Gallery - error: $e, stackTrace: $st',
        name: 'IMAGE_PICKER_UTIL',
      );

      return ImagePickError(e, st);
    }
  }

  static Future<ImagePickResult> pickFromCamera({
    ImagePickOptions options = const ImagePickOptions(),
  }) async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      return ImagePickPermissionDenied(isPermanent: status.isPermanentlyDenied);
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: options.imageQuality,
        maxWidth: options.maxWidth,
        maxHeight: options.maxHeight,
        preferredCameraDevice: options.preferredCameraDevice,
      );

      if (picked == null) {
        return const ImagePickCancelled();
      }

      return ImagePickSuccess([File(picked.path)]);
    } catch (e, st) {
      AppLogger.log(
        'Pick From Camera - error: $e, stackTrace: $st',
        name: 'IMAGE_PICKER_UTIL',
      );

      return ImagePickError(e, st);
    }
  }

  static Future<ImagePickResult> pickMultiple({
    ImagePickOptions options = const ImagePickOptions(),
  }) async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: options.imageQuality,
        maxWidth: options.maxWidth,
        maxHeight: options.maxHeight,
        limit: options.limit,
      );

      if (picked.isEmpty) {
        return const ImagePickCancelled();
      }

      return ImagePickSuccess(picked.map((f) => File(f.path)).toList());
    } catch (e, st) {
      AppLogger.log(
        'Pick Multiple - error: $e, stackTrace: $st',
        name: 'IMAGE_PICKER_UTIL',
      );

      return ImagePickError(e, st);
    }
  }

  static Future<ImagePickResult> showSourcePicker({
    String? title,
    String? subtitle,
    String? cameraTitle,
    String? cameraSubtitle,
    String? galleryTitle,
    String? gallerySubtitle,
    String? cancelTitle,
    bool multiImages = false,
    ImagePickOptions options = const ImagePickOptions(),
  }) async {
    final context = RouteManager.currentContext;

    final result = await showModalBottomSheet<ImagePickResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => _ImageSourceSheet(
        title: title ?? LocaleKeys.image_picker_util_title.tr(),
        subtitle: subtitle ?? LocaleKeys.image_picker_util_subtitle.tr(),
        cameraTitle:
            cameraTitle ?? LocaleKeys.image_picker_util_camera_title.tr(),
        cameraSubtitle:
            cameraSubtitle ?? LocaleKeys.image_picker_util_camera_subtitle.tr(),
        galleryTitle:
            galleryTitle ?? LocaleKeys.image_picker_util_gallery_title.tr(),
        gallerySubtitle:
            gallerySubtitle ??
            LocaleKeys.image_picker_util_gallery_subtitle.tr(),
        cancelTitle: cancelTitle ?? LocaleKeys.image_picker_util_cancel.tr(),
        multiImages: multiImages,
        options: options,
      ),
    );

    return result ?? const ImagePickCancelled();
  }

  static String fileSize(File file) {
    try {
      final int bytes = file.lengthSync();

      if (bytes <= 0) {
        return '0 B';
      }

      const suffixes = ['B', 'KB', 'MB', 'GB'];

      final int i = (bytes.bitLength / 10).floor().clamp(
        0,
        suffixes.length - 1,
      );

      return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
    } catch (_) {
      return '0 B';
    }
  }

  static String fileName(File file) =>
      file.path.split(Platform.pathSeparator).last;

  static String fileExtension(File file) {
    final int dot = file.path.lastIndexOf('.');

    if (dot != -1 && dot < file.path.length - 1) {
      return file.path.substring(dot + 1).toLowerCase();
    }

    return '';
  }

  static bool isImage(File file) {
    const imageExtensions = {
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'heic',
      'heif',
    };

    return imageExtensions.contains(fileExtension(file));
  }
}

class SelectedImagePreviewCard extends StatelessWidget {
  const SelectedImagePreviewCard({
    super.key,
    required this.file,
    this.onRemove,
    this.onTap,
  });

  final File file;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    final name = ImagePickerUtil.fileName(file);
    final size = ImagePickerUtil.fileSize(file);
    final ext = ImagePickerUtil.fileExtension(file).toUpperCase();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.height),
      decoration: BoxDecoration(
        color: colors.neutral50.withValues(
          alpha: context.isDarkMode ? 0.08 : 0.7,
        ),
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(
          color: colors.neutral300.withValues(
            alpha: context.isDarkMode ? 0.2 : 0.6,
          ),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.radius),
          splashColor: colors.primary600.withValues(alpha: 0.08),
          highlightColor: colors.primary600.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.width,
              vertical: 10.height,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.radius),
                  child: Image.file(
                    file,
                    width: 50.radius,
                    height: 50.radius,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50.radius,
                      height: 50.radius,
                      color: colors.primary600.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: colors.primary600,
                        size: 24.radius,
                      ),
                    ),
                  ),
                ),
                horizontalGap(14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.f14sb.copyWith(color: colors.neutral900),
                      ),

                      verticalGap(4),

                      Row(
                        children: [
                          if (ext.isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.width,
                                vertical: 2.height,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary600.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.radius),
                              ),
                              child: Text(
                                ext,
                                style: context.f12r.copyWith(
                                  color: colors.primary600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.font,
                                ),
                              ),
                            ),

                            horizontalGap(6),
                          ],

                          Text(
                            size,
                            style: context.f12r.copyWith(
                              color: colors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (onRemove != null) ...[
                  horizontalGap(8),

                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onRemove?.call();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.neutral500,
                      size: 20.radius,
                    ),
                    splashRadius: 20.radius,
                    tooltip: LocaleKeys.image_picker_util_remove_image.tr(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ImagePickerLoadingSource { none, camera, gallery }

class _ImageSourceSheet extends StatefulWidget {
  const _ImageSourceSheet({
    required this.title,
    required this.subtitle,
    required this.cameraTitle,
    required this.cameraSubtitle,
    required this.galleryTitle,
    required this.gallerySubtitle,
    required this.cancelTitle,
    required this.multiImages,
    required this.options,
  });

  final String title;
  final String subtitle;
  final String cameraTitle;
  final String cameraSubtitle;
  final String galleryTitle;
  final String gallerySubtitle;
  final String cancelTitle;
  final bool multiImages;
  final ImagePickOptions options;

  @override
  State<_ImageSourceSheet> createState() => _ImageSourceSheetState();
}

class _ImageSourceSheetState extends State<_ImageSourceSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  _ImagePickerLoadingSource _loadingSource = _ImagePickerLoadingSource.none;

  bool get _isAnyLoading => _loadingSource != _ImagePickerLoadingSource.none;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleCamera() => _pick(
    _ImagePickerLoadingSource.camera,
    () => ImagePickerUtil.pickFromCamera(options: widget.options),
  );

  Future<void> _handleGallery() => _pick(
    _ImagePickerLoadingSource.gallery,
    () => widget.multiImages
        ? ImagePickerUtil.pickMultiple(options: widget.options)
        : ImagePickerUtil.pickFromGallery(options: widget.options),
  );

  Future<void> _pick(
    _ImagePickerLoadingSource source,
    Future<ImagePickResult> Function() action,
  ) async {
    if (_isAnyLoading) {
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() => _loadingSource = source);

    final result = await action();

    if (!mounted) return;

    setState(() => _loadingSource = _ImagePickerLoadingSource.none);

    RouteManager.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: colors.neutral0,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28.radius),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.neutral950.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.width,
                14.height,
                20.width,
                20.height,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44.width,
                    height: 4.height,
                    decoration: BoxDecoration(
                      color: colors.neutral300,
                      borderRadius: BorderRadius.circular(3.radius),
                    ),
                  ),

                  verticalGap(18),

                  Text(
                    widget.title,
                    style: context.f20sb.copyWith(color: colors.neutral900),
                    textAlign: TextAlign.center,
                  ),

                  verticalGap(6),

                  Text(
                    widget.subtitle,
                    style: context.f14r.copyWith(color: colors.neutral500),
                    textAlign: TextAlign.center,
                  ),

                  verticalGap(20),

                  _ImageSourceTile(
                    icon: Icons.camera_alt_rounded,
                    title: widget.cameraTitle,
                    subtitle: widget.cameraSubtitle,
                    accentColor: colors.danger600,
                    isLoading:
                        _loadingSource == _ImagePickerLoadingSource.camera,
                    isDisabled:
                        _isAnyLoading &&
                        _loadingSource != _ImagePickerLoadingSource.camera,
                    onTap: _handleCamera,
                  ),

                  verticalGap(12),

                  _ImageSourceTile(
                    icon: Icons.photo_library_rounded,
                    title: widget.galleryTitle,
                    subtitle: widget.multiImages && widget.options.limit != null
                        ? '${widget.gallerySubtitle} (${LocaleKeys.image_picker_util_max_limit.tr()}: ${widget.options.limit})'
                        : widget.gallerySubtitle,
                    accentColor: colors.primary600,
                    isLoading:
                        _loadingSource == _ImagePickerLoadingSource.gallery,
                    isDisabled:
                        _isAnyLoading &&
                        _loadingSource != _ImagePickerLoadingSource.gallery,
                    onTap: _handleGallery,
                  ),

                  verticalGap(16),

                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.radius),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _isAnyLoading
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              RouteManager.pop(const ImagePickCancelled());
                            },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.height),
                        decoration: BoxDecoration(
                          color: colors.neutral100.withValues(
                            alpha: context.isDarkMode ? 0.15 : 0.6,
                          ),
                          borderRadius: BorderRadius.circular(16.radius),
                          border: Border.all(
                            color: colors.neutral300.withValues(
                              alpha: context.isDarkMode ? 0.2 : 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          widget.cancelTitle,
                          textAlign: TextAlign.center,
                          style: context.f16sb.copyWith(
                            color: colors.neutral700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  verticalGap(MediaHelper.bottomPadding(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;
    final effectiveAccent = isDisabled ? colors.neutral400 : accentColor;

    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: (isLoading || isDisabled) ? null : onTap,
          splashColor: effectiveAccent.withValues(alpha: 0.12),
          highlightColor: effectiveAccent.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  effectiveAccent.withValues(alpha: 0.08),
                  effectiveAccent.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.radius),
              border: Border.all(
                color: effectiveAccent.withValues(alpha: 0.2),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.radius),
              child: Row(
                children: [
                  Container(
                    width: 50.radius,
                    height: 50.radius,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          effectiveAccent,
                          effectiveAccent.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.radius),
                      boxShadow: [
                        BoxShadow(
                          color: effectiveAccent.withValues(alpha: 0.3),
                          blurRadius: 12.radius,
                          offset: Offset(0, 4.radius),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isLoading
                          ? AppLoadingIndicator(
                              color: colors.neutral0,
                              size: 20.radius,
                            )
                          : Icon(icon, color: colors.neutral0, size: 26.radius),
                    ),
                  ),

                  horizontalGap(16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.f16sb.copyWith(
                            color: colors.neutral900,
                          ),
                        ),

                        verticalGap(4),

                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.f14r.copyWith(
                            color: colors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  horizontalGap(12),

                  Container(
                    padding: EdgeInsets.all(8.radius),
                    decoration: BoxDecoration(
                      color: effectiveAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.radius),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.radius,
                      color: effectiveAccent,
                    ),
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

class ImagePickOptions {
  const ImagePickOptions({
    this.imageQuality = 85,
    this.maxWidth,
    this.maxHeight,
    this.preferredCameraDevice = CameraDevice.rear,
    this.limit,
  });

  final int imageQuality;
  final double? maxWidth;
  final double? maxHeight;
  final CameraDevice preferredCameraDevice;
  final int? limit;
}

sealed class ImagePickResult {
  const ImagePickResult();
}

final class ImagePickSuccess extends ImagePickResult {
  const ImagePickSuccess(this.files);

  final List<File> files;

  File get file => files.first;

  int get count => files.length;
}

final class ImagePickCancelled extends ImagePickResult {
  const ImagePickCancelled();
}

final class ImagePickPermissionDenied extends ImagePickResult {
  const ImagePickPermissionDenied({this.isPermanent = false});

  final bool isPermanent;
}

final class ImagePickError extends ImagePickResult {
  const ImagePickError(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;
}
