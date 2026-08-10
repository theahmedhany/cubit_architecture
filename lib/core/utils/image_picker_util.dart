import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helpers/app_logger.dart';
import '../helpers/asset_helper.dart';
import '../helpers/dimensions_helper.dart';
import '../helpers/media_helper.dart';
import '../helpers/spacing.dart';
import '../routing/route_manager.dart';
import '../theme/app_texts/app_text_styles.dart';
import '../theme/theme_manager/theme_extensions.dart';

class ImagePickerUtil {
  ImagePickerUtil._();

  static final ImagePicker _picker = ImagePicker();

  static Future<ImagePickResult> pickFromGallery({
    ImagePickOptions options = const ImagePickOptions(),
  }) async {
    final permResult = await _requestGalleryPermission();
    if (permResult != _PermissionResult.granted) {
      return ImagePickPermissionDenied(
        isPermanent: permResult == _PermissionResult.permanentlyDenied,
      );
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: options.imageQuality,
        maxWidth: options.maxWidth,
        maxHeight: options.maxHeight,
      );

      if (picked == null) return ImagePickCancelled();
      return ImagePickSuccess([File(picked.path)]);
    } catch (e, st) {
      AppLogger.log('ImagePickerUtil.pickFromGallery error: $e');
      return ImagePickError(e, st);
    }
  }

  static Future<ImagePickResult> pickFromCamera({
    ImagePickOptions options = const ImagePickOptions(),
  }) async {
    final permResult = await _requestCameraPermission();
    if (permResult != _PermissionResult.granted) {
      return ImagePickPermissionDenied(
        isPermanent: permResult == _PermissionResult.permanentlyDenied,
      );
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: options.imageQuality,
        maxWidth: options.maxWidth,
        maxHeight: options.maxHeight,
        preferredCameraDevice: options.preferredCameraDevice,
      );

      if (picked == null) return ImagePickCancelled();
      return ImagePickSuccess([File(picked.path)]);
    } catch (e, st) {
      AppLogger.log('ImagePickerUtil.pickFromCamera error: $e');
      return ImagePickError(e, st);
    }
  }

  static Future<ImagePickResult> pickMultiple({
    ImagePickOptions options = const ImagePickOptions(),
  }) async {
    final permResult = await _requestGalleryPermission();
    if (permResult != _PermissionResult.granted) {
      return ImagePickPermissionDenied(
        isPermanent: permResult == _PermissionResult.permanentlyDenied,
      );
    }

    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: options.imageQuality,
        maxWidth: options.maxWidth,
        maxHeight: options.maxHeight,
        limit: options.limit,
      );

      if (picked.isEmpty) return ImagePickCancelled();
      return ImagePickSuccess(picked.map((f) => File(f.path)).toList());
    } catch (e, st) {
      AppLogger.log('ImagePickerUtil.pickMultiple error: $e');
      return ImagePickError(e, st);
    }
  }

  static Future<ImagePickResult> showSourcePicker({
    required String title,
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
        title: title,
        cameraTitle: cameraTitle ?? 'camera_upload_title'.tr(),
        cameraSubtitle: cameraSubtitle ?? 'camera_upload_subtitle'.tr(),
        galleryTitle: galleryTitle ?? 'gallery_upload_title'.tr(),
        gallerySubtitle: gallerySubtitle ?? 'gallery_upload_subtitle'.tr(),
        cancelTitle: cancelTitle ?? 'image_picker_cancel'.tr(),
        multiImages: multiImages,
        options: options,
      ),
    );

    return result ?? ImagePickCancelled();
  }

  static String fileSize(File file) {
    final int bytes = file.lengthSync();
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final int i = (bytes.bitLength / 10).floor().clamp(0, suffixes.length - 1);
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }

  static String fileName(File file) => file.path.split('/').last;

  static String fileExtension(File file) {
    final int dot = file.path.lastIndexOf('.');
    if (dot != -1 && dot < file.path.length - 1) {
      return file.path.substring(dot + 1);
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
    };
    return imageExtensions.contains(fileExtension(file).toLowerCase());
  }

  static Future<_PermissionResult> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return _PermissionResult.granted;
    if (status.isPermanentlyDenied) return _PermissionResult.permanentlyDenied;
    return _PermissionResult.denied;
  }

  static Future<_PermissionResult> _requestGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) {
        return _PermissionResult.granted;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return _PermissionResult.permanentlyDenied;
      }
      return _PermissionResult.denied;
    }

    if (Platform.isAndroid) {
      final photo = await Permission.photos.request();
      if (photo.isGranted) return _PermissionResult.granted;

      final storage = await Permission.storage.request();
      if (storage.isGranted) return _PermissionResult.granted;
      if (storage.isPermanentlyDenied) {
        return _PermissionResult.permanentlyDenied;
      }
      return _PermissionResult.denied;
    }

    return _PermissionResult.granted;
  }
}

enum _PermissionResult { granted, denied, permanentlyDenied }

class _ImageSourceSheet extends StatefulWidget {
  const _ImageSourceSheet({
    required this.title,
    required this.cameraTitle,
    required this.cameraSubtitle,
    required this.galleryTitle,
    required this.gallerySubtitle,
    required this.cancelTitle,
    required this.multiImages,
    required this.options,
  });

  final String title;
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

  bool _isLoading = false;

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

  Future<void> _handleCamera() =>
      _pick(() => ImagePickerUtil.pickFromCamera(options: widget.options));

  Future<void> _handleGallery() => _pick(
    () => widget.multiImages
        ? ImagePickerUtil.pickMultiple(options: widget.options)
        : ImagePickerUtil.pickFromGallery(options: widget.options),
  );

  Future<void> _pick(Future<ImagePickResult> Function() action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final result = await action();

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _SheetSurface(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.width,
                12.height,
                20.width,
                20.height,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DragHandle(),
                  verticalGap(14),
                  Text(widget.title, style: context.f20sb),
                  verticalGap(20),
                  _OptionTile(
                    icon: CupertinoIcons.camera_fill,
                    title: widget.cameraTitle,
                    subtitle: widget.cameraSubtitle,
                    gradientColors: [
                      context.customAppColors.danger600.withValues(alpha: 0.8),
                      context.customAppColors.danger600,
                    ],
                    isLoading: _isLoading,
                    onTap: _handleCamera,
                  ),
                  verticalGap(12),
                  _OptionTile(
                    icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                    title: widget.galleryTitle,
                    subtitle: widget.multiImages && widget.options.limit != null
                        ? '${widget.gallerySubtitle} (${'max'.tr()}: ${widget.options.limit})'
                        : widget.gallerySubtitle,
                    gradientColors: [
                      context.customAppColors.info700.withValues(alpha: 0.8),
                      context.customAppColors.info700,
                    ],
                    isLoading: _isLoading,
                    onTap: _handleGallery,
                  ),

                  verticalGap(16),

                  _CancelButton(
                    label: widget.cancelTitle,
                    onTap: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(ImagePickCancelled()),
                  ),

                  verticalGap(MediaHelper.bottomPadding(context) + 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.customAppColors.neutral0,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.radius)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.radius)),
        child: child,
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.width,
      height: 4.height,
      decoration: BoxDecoration(
        color: context.customAppColors.neutral300,
        borderRadius: BorderRadius.circular(2.radius),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20.radius),
        splashColor: gradientColors[1].withValues(alpha: 0.1),
        highlightColor: gradientColors[1].withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientColors[0].withValues(alpha: 0.1),
                gradientColors[1].withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.radius),
            border: Border.all(
              color: gradientColors[1].withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.radius),
            child: Row(
              children: [
                _IconContainer(
                  icon: icon,
                  gradientColors: gradientColors,
                  isLoading: isLoading,
                ),
                horizontalGap(16),
                Expanded(
                  child: _TileText(title: title, subtitle: subtitle),
                ),
                horizontalGap(12),
                _ChevronBadge(gradientColors: gradientColors),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconContainer extends StatelessWidget {
  const _IconContainer({
    required this.icon,
    required this.gradientColors,
    this.isLoading = false,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.radius,
      height: 48.radius,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.radius),
        boxShadow: [
          BoxShadow(
            color: gradientColors[1].withValues(alpha: 0.3),
            blurRadius: 10.radius,
            offset: Offset(0, 3.radius),
          ),
        ],
      ),
      child: isLoading
          ? Padding(
              padding: EdgeInsets.all(12.radius),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.customAppColors.neutral0,
              ),
            )
          : Icon(
              icon,
              color: context.customAppColors.neutral0,
              size: 24.radius,
            ),
    );
  }
}

class _TileText extends StatelessWidget {
  const _TileText({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.f18sb,
        ),
        verticalGap(4),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.f14r.copyWith(
            color: context.customAppColors.neutral700,
          ),
        ),
      ],
    );
  }
}

class _ChevronBadge extends StatelessWidget {
  const _ChevronBadge({required this.gradientColors});
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.radius),
      decoration: BoxDecoration(
        color: gradientColors[1].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.radius),
      ),
      child: Center(
        child: SvgPicture.asset(
          AssetHelper.iconSVGPath('arrow_right'),
          width: 18.radius,
          height: 18.radius,
          matchTextDirection: true,
          colorFilter: ColorFilter.mode(gradientColors[1], BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.radius),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.radius),
          decoration: BoxDecoration(
            color: context.customAppColors.neutral950.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16.radius),
            border: Border.all(
              color: context.customAppColors.neutral950.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.f18sb.copyWith(
              color: onTap == null
                  ? context.customAppColors.neutral700
                  : context.customAppColors.danger600,
            ),
          ),
        ),
      ),
    );
  }
}

sealed class ImagePickResult {}

final class ImagePickSuccess extends ImagePickResult {
  final List<File> files;
  ImagePickSuccess(this.files);

  File get file => files.first;
}

final class ImagePickCancelled extends ImagePickResult {}

final class ImagePickPermissionDenied extends ImagePickResult {
  final bool isPermanent;
  ImagePickPermissionDenied({this.isPermanent = false});
}

final class ImagePickError extends ImagePickResult {
  final Object error;
  final StackTrace stackTrace;
  ImagePickError(this.error, this.stackTrace);
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
