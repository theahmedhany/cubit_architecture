import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../helpers/app_logger.dart';
import '../helpers/asset_helper.dart';
import '../helpers/dimensions_helper.dart';
import '../helpers/media_helper.dart';
import '../helpers/spacing.dart';
import '../routing/route_manager.dart';
import '../theme/app_texts/app_text_styles.dart';
import '../theme/theme_manager/theme_extensions.dart';

abstract final class FilePickerUtil {
  static Future<File?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool withData = false,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        withData: withData,
        allowMultiple: false,
      );

      final path = result?.files.single.path;
      return path != null ? File(path) : null;
    } catch (e, st) {
      AppLogger.log('FilePickerUtil.pickFile error: $e, stackTrace: $st');
      return null;
    }
  }

  static Future<List<File>?> pickMultipleFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool withData = false,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        withData: withData,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final files = result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList(growable: false);

      return files.isNotEmpty ? files : null;
    } catch (e, st) {
      AppLogger.log(
        'FilePickerUtil.pickMultipleFiles error: $e, stackTrace: $st',
      );
      return null;
    }
  }

  static Future<String?> pickDirectory() async {
    try {
      return await FilePicker.getDirectoryPath();
    } catch (e, st) {
      AppLogger.log('FilePickerUtil.pickDirectory error: $e, stackTrace: $st');
      return null;
    }
  }

  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    final index = i.clamp(0, suffixes.length - 1);
    final value = bytes / (1 << (index * 10));
    return '${value.toStringAsFixed(2)} ${suffixes[index]}';
  }

  static int getFileSizeInBytes(File file) => file.lengthSync();

  static String getFileName(File file) =>
      file.path.split(Platform.pathSeparator).last;

  static String getFileNameWithoutExtension(File file) {
    final name = getFileName(file);
    final dot = name.lastIndexOf('.');
    return dot != -1 ? name.substring(0, dot) : name;
  }

  static String getFileExtension(File file) {
    final dot = file.path.lastIndexOf('.');
    if (dot == -1 || dot == file.path.length - 1) return '';
    return file.path.substring(dot + 1).toLowerCase();
  }

  static String getMimeType(File file) =>
      _mimeMap[getFileExtension(file)] ?? 'application/octet-stream';

  static DateTime getLastModified(File file) => file.lastModifiedSync();

  static String getFormattedLastModified(File file) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(getLastModified(file));

  static SupportedFileType getFileType(File file) =>
      _typeMap[getFileExtension(file)] ?? SupportedFileType.unknown;

  static bool isPdf(File file) => getFileExtension(file) == 'pdf';
  static bool isImage(File file) =>
      getFileType(file) == SupportedFileType.image;
  static bool isVideo(File file) =>
      getFileType(file) == SupportedFileType.video;
  static bool isAudio(File file) =>
      getFileType(file) == SupportedFileType.audio;
  static bool isDocument(File file) =>
      getFileType(file) == SupportedFileType.document;
  static bool isArchive(File file) =>
      getFileType(file) == SupportedFileType.archive;
  static bool isSpreadsheet(File file) =>
      getFileType(file) == SupportedFileType.spreadsheet;
  static bool isPresentation(File file) =>
      getFileType(file) == SupportedFileType.presentation;
  static bool isCode(File file) => getFileType(file) == SupportedFileType.code;

  static IconData getFileIcon(File file) {
    switch (getFileType(file)) {
      case SupportedFileType.image:
        return CupertinoIcons.photo_fill;
      case SupportedFileType.video:
        return CupertinoIcons.film_fill;
      case SupportedFileType.audio:
        return CupertinoIcons.music_note_2;
      case SupportedFileType.document:
        return isPdf(file)
            ? CupertinoIcons.doc_text_fill
            : CupertinoIcons.doc_fill;
      case SupportedFileType.archive:
        return CupertinoIcons.folder_fill;
      case SupportedFileType.spreadsheet:
        return CupertinoIcons.table_fill;
      case SupportedFileType.presentation:
        return CupertinoIcons.chart_bar_fill;
      case SupportedFileType.code:
        return CupertinoIcons.chevron_left_slash_chevron_right;
      case SupportedFileType.unknown:
        return CupertinoIcons.doc;
    }
  }

  static bool validateFileSize(File file, int maxSizeInBytes) =>
      getFileSizeInBytes(file) <= maxSizeInBytes;

  static bool validateFileExtension(
    File file,
    List<String> allowedExtensions,
  ) => allowedExtensions.contains(getFileExtension(file));

  static bool fileExists(File file) => file.existsSync();

  static Future<bool> deleteFile(File file) async {
    try {
      if (!fileExists(file)) return false;
      await file.delete();
      return true;
    } catch (e, st) {
      AppLogger.log('FilePickerUtil.deleteFile error: $e, stackTrace: $st');
      return false;
    }
  }

  static Future<File?> copyFile(File sourceFile, String destinationPath) async {
    try {
      return await sourceFile.copy(destinationPath);
    } catch (e, st) {
      AppLogger.log('FilePickerUtil.copyFile error: $e, stackTrace: $st');
      return null;
    }
  }

  static Future<File?> moveFile(File sourceFile, String destinationPath) async {
    try {
      return await sourceFile.rename(destinationPath);
    } catch (e, st) {
      AppLogger.log('FilePickerUtil.moveFile error: $e, stackTrace: $st');
      return null;
    }
  }

  static Future<dynamic> showFilePickerDialog(FilePickerConfig config) async {
    final context = RouteManager.currentContext;

    return showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => _FilePickerSheet(config: config),
    );
  }
}

class _FilePickerSheet extends StatefulWidget {
  const _FilePickerSheet({required this.config});

  final FilePickerConfig config;

  @override
  State<_FilePickerSheet> createState() => _FilePickerSheetState();
}

class _FilePickerSheetState extends State<_FilePickerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FilePickerConfig get _config => widget.config;

  Future<void> _onPickTap() async {
    dynamic result;

    if (_config.multiFiles) {
      result = await FilePickerUtil.pickMultipleFiles(
        type: _config.fileType,
        allowedExtensions: _config.allowedExtensions,
      );
    } else {
      result = await FilePickerUtil.pickFile(
        type: _config.fileType,
        allowedExtensions: _config.allowedExtensions,
      );
    }

    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _SheetSurface(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.width,
                16.height,
                20.width,
                20.height,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DragHandle(),
                  verticalGap(14),
                  Text(
                    _config.title,
                    style: context.f20sb,
                    textAlign: TextAlign.center,
                  ),
                  verticalGap(18),
                  _PickerOptionTile(
                    icon: CupertinoIcons.folder_fill,
                    title: _config.filePickerTitle ?? 'file_picker_title'.tr(),
                    subtitle:
                        _config.filePickerSubtitle ??
                        'file_picker_subtitle'.tr(),
                    onTap: _onPickTap,
                  ),
                  verticalGap(12),
                  _CancelButton(
                    label: _config.cancelTitle ?? 'file_picker_cancel'.tr(),
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
    return DecoratedBox(
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
    return Center(
      child: Container(
        width: 40.width,
        height: 4.height,
        decoration: BoxDecoration(
          color: context.customAppColors.neutral300,
          borderRadius: BorderRadius.circular(2.radius),
        ),
      ),
    );
  }
}

class _PickerOptionTile extends StatelessWidget {
  const _PickerOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = context.customAppColors.neutral700;
    final accentStart = primary.withValues(alpha: 0.8);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: primary.withValues(alpha: 0.1),
        highlightColor: primary.withValues(alpha: 0.05),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentStart.withValues(alpha: 0.1),
                primary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.radius),
            border: Border.all(color: primary.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.radius),
            child: Row(
              children: [
                _IconBadge(icon: icon, colors: [accentStart, primary]),
                horizontalGap(16),
                Expanded(
                  child: Column(
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
                  ),
                ),
                horizontalGap(16),
                _ArrowChip(color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.colors});

  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.radius,
      height: 48.radius,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.radius),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 12.radius,
            offset: Offset(0, 4.radius),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: context.customAppColors.neutral0,
        size: 24.radius,
      ),
    );
  }
}

class _ArrowChip extends StatelessWidget {
  const _ArrowChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.radius),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.radius),
      ),
      child: SvgPicture.asset(
        AssetHelper.iconSVGPath('arrow_right'),
        width: 18.radius,
        height: 18.radius,
        matchTextDirection: true,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: RouteManager.pop,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.radius),
          decoration: BoxDecoration(
            color: context.customAppColors.neutral900.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16.radius),
            border: Border.all(
              color: context.customAppColors.neutral900.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.f18sb.copyWith(
              color: context.customAppColors.danger600,
            ),
          ),
        ),
      ),
    );
  }
}

enum SupportedFileType {
  document,
  image,
  video,
  audio,
  archive,
  code,
  spreadsheet,
  presentation,
  unknown,
}

class FilePickerConfig {
  const FilePickerConfig({
    required this.title,
    this.filePickerTitle,
    this.filePickerSubtitle,
    this.cancelTitle,
    this.multiFiles = false,
    this.maxFiles = 1,
    this.allowedExtensions,
    this.fileType = FileType.any,
  });

  final String title;
  final String? filePickerTitle;
  final String? filePickerSubtitle;
  final String? cancelTitle;
  final bool multiFiles;
  final int maxFiles;
  final List<String>? allowedExtensions;
  final FileType fileType;

  FilePickerConfig copyWith({
    String? title,
    String? filePickerTitle,
    String? filePickerSubtitle,
    String? cancelTitle,
    bool? multiFiles,
    int? maxFiles,
    List<String>? allowedExtensions,
    FileType? fileType,
  }) {
    return FilePickerConfig(
      title: title ?? this.title,
      filePickerTitle: filePickerTitle ?? this.filePickerTitle,
      filePickerSubtitle: filePickerSubtitle ?? this.filePickerSubtitle,
      cancelTitle: cancelTitle ?? this.cancelTitle,
      multiFiles: multiFiles ?? this.multiFiles,
      maxFiles: maxFiles ?? this.maxFiles,
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      fileType: fileType ?? this.fileType,
    );
  }
}

const _mimeMap = <String, String>{
  // Images
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'bmp': 'image/bmp',
  'webp': 'image/webp',
  'svg': 'image/svg+xml',
  // Video
  'mp4': 'video/mp4',
  'avi': 'video/x-msvideo',
  'mov': 'video/quicktime',
  'wmv': 'video/x-ms-wmv',
  'flv': 'video/x-flv',
  'mkv': 'video/x-matroska',
  'webm': 'video/webm',
  // Audio
  'mp3': 'audio/mpeg',
  'wav': 'audio/wav',
  'aac': 'audio/aac',
  'flac': 'audio/flac',
  'm4a': 'audio/mp4',
  'ogg': 'audio/ogg',
  'wma': 'audio/x-ms-wma',
  // Documents
  'pdf': 'application/pdf',
  'doc': 'application/msword',
  'docx':
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'txt': 'text/plain',
  'rtf': 'application/rtf',
  'odt': 'application/vnd.oasis.opendocument.text',
  // Spreadsheets
  'xls': 'application/vnd.ms-excel',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'csv': 'text/csv',
  'ods': 'application/vnd.oasis.opendocument.spreadsheet',
  // Presentations
  'ppt': 'application/vnd.ms-powerpoint',
  'pptx':
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'odp': 'application/vnd.oasis.opendocument.presentation',
  // Archives
  'zip': 'application/zip',
  'rar': 'application/x-rar-compressed',
  '7z': 'application/x-7z-compressed',
  'tar': 'application/x-tar',
  'gz': 'application/gzip',
  'bz2': 'application/x-bzip2',
};

const _typeMap = <String, SupportedFileType>{
  // Images
  'jpg': SupportedFileType.image,
  'jpeg': SupportedFileType.image,
  'png': SupportedFileType.image,
  'gif': SupportedFileType.image,
  'bmp': SupportedFileType.image,
  'webp': SupportedFileType.image,
  'svg': SupportedFileType.image,
  // Video
  'mp4': SupportedFileType.video,
  'avi': SupportedFileType.video,
  'mov': SupportedFileType.video,
  'wmv': SupportedFileType.video,
  'flv': SupportedFileType.video,
  'mkv': SupportedFileType.video,
  'webm': SupportedFileType.video,
  // Audio
  'mp3': SupportedFileType.audio,
  'wav': SupportedFileType.audio,
  'aac': SupportedFileType.audio,
  'flac': SupportedFileType.audio,
  'm4a': SupportedFileType.audio,
  'ogg': SupportedFileType.audio,
  'wma': SupportedFileType.audio,
  // Documents
  'pdf': SupportedFileType.document,
  'doc': SupportedFileType.document,
  'docx': SupportedFileType.document,
  'txt': SupportedFileType.document,
  'rtf': SupportedFileType.document,
  'odt': SupportedFileType.document,
  // Spreadsheets
  'xls': SupportedFileType.spreadsheet,
  'xlsx': SupportedFileType.spreadsheet,
  'csv': SupportedFileType.spreadsheet,
  'ods': SupportedFileType.spreadsheet,
  // Presentations
  'ppt': SupportedFileType.presentation,
  'pptx': SupportedFileType.presentation,
  'odp': SupportedFileType.presentation,
  // Archives
  'zip': SupportedFileType.archive,
  'rar': SupportedFileType.archive,
  '7z': SupportedFileType.archive,
  'tar': SupportedFileType.archive,
  'gz': SupportedFileType.archive,
  'bz2': SupportedFileType.archive,
  // Code
  'dart': SupportedFileType.code,
  'java': SupportedFileType.code,
  'kt': SupportedFileType.code,
  'swift': SupportedFileType.code,
  'js': SupportedFileType.code,
  'ts': SupportedFileType.code,
  'py': SupportedFileType.code,
  'cpp': SupportedFileType.code,
  'c': SupportedFileType.code,
  'h': SupportedFileType.code,
  'cs': SupportedFileType.code,
  'go': SupportedFileType.code,
  'rs': SupportedFileType.code,
  'php': SupportedFileType.code,
  'rb': SupportedFileType.code,
  'xml': SupportedFileType.code,
  'json': SupportedFileType.code,
  'yaml': SupportedFileType.code,
  'yml': SupportedFileType.code,
  'html': SupportedFileType.code,
  'css': SupportedFileType.code,
  'scss': SupportedFileType.code,
  'sass': SupportedFileType.code,
  'sql': SupportedFileType.code,
  'sh': SupportedFileType.code,
  'bat': SupportedFileType.code,
  'gradle': SupportedFileType.code,
  'md': SupportedFileType.code,
};
