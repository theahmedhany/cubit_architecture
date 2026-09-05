import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../localization/locale_keys.g.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_button.dart';

enum TimePickerDisplayMode { bottomSheet, dialog }

class CustomTimePicker {
  const CustomTimePicker._();

  static Future<TimeOfDay?> pick({
    required BuildContext context,
    TimeOfDay? initialTime,
    DateTime? selectedDate,
    TimePickerDisplayMode displayMode = TimePickerDisplayMode.bottomSheet,
    bool use24HourFormat = false,
    String? title,
    String? confirmTitle,
    String? cancelTitle,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    ValueChanged<TimeOfDay>? onTimeSelected,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    final now = TimeOfDay.now();
    final resolvedInitial = initialTime ?? now;
    final resolvedDate = selectedDate ?? DateTime.now();
    final themeColors = context.customAppColors;

    final content = _TimePickerContent(
      initialTime: resolvedInitial,
      selectedDate: resolvedDate,
      displayMode: displayMode,
      use24HourFormat: use24HourFormat,
      title: title,
      confirmTitle: confirmTitle,
      cancelTitle: cancelTitle,
      primaryColor: primaryColor ?? themeColors.primary900,
      backgroundColor: backgroundColor ?? themeColors.neutral0,
      textColor: textColor ?? themeColors.neutral900,
      onTimeSelected: (time) =>
          Navigator.of(context, rootNavigator: true).pop(time),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
    );

    TimeOfDay? pickedTime;

    if (displayMode == TimePickerDisplayMode.bottomSheet) {
      pickedTime = await showModalBottomSheet<TimeOfDay>(
        context: context,
        isScrollControlled: true,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: Colors.transparent,
        barrierColor: themeColors.neutral950.withValues(alpha: 0.54),
        builder: (_) => content,
      );
    } else {
      pickedTime = await showDialog<TimeOfDay>(
        context: context,
        barrierDismissible: isDismissible,
        barrierColor: themeColors.neutral950.withValues(alpha: 0.54),
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: 20.radius,
            vertical: 24.radius,
          ),
          child: content,
        ),
      );
    }

    if (pickedTime != null) {
      onTimeSelected?.call(pickedTime);
    }

    return pickedTime;
  }
}

class _TimePickerContent extends StatefulWidget {
  const _TimePickerContent({
    required this.initialTime,
    required this.selectedDate,
    required this.displayMode,
    required this.use24HourFormat,
    this.title,
    this.confirmTitle,
    this.cancelTitle,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.onTimeSelected,
    required this.onCancel,
  });

  final TimeOfDay initialTime;
  final DateTime selectedDate;
  final TimePickerDisplayMode displayMode;
  final bool use24HourFormat;
  final String? title;
  final String? confirmTitle;
  final String? cancelTitle;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final VoidCallback onCancel;

  @override
  State<_TimePickerContent> createState() => _TimePickerContentState();
}

class _TimePickerContentState extends State<_TimePickerContent> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  late int _hour;
  late int _minute;
  late bool _isAm;

  static const double _itemExtent = 56.0;

  @override
  void initState() {
    super.initState();

    final h = widget.initialTime.hour;
    final m = widget.initialTime.minute;

    _isAm = h < 12;
    _minute = m;

    if (widget.use24HourFormat) {
      _hour = h;
      _hourController = FixedExtentScrollController(initialItem: _hour);
    } else {
      _hour = (h % 12 == 0) ? 12 : (h % 12);
      _hourController = FixedExtentScrollController(initialItem: _hour - 1);
    }

    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay _toTimeOfDay() {
    if (widget.use24HourFormat) {
      return TimeOfDay(hour: _hour, minute: _minute);
    }

    int hour = _hour;

    if (_isAm) {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }

    return TimeOfDay(hour: hour, minute: _minute);
  }

  String _formattedPreview() {
    final mStr = _minute.toString().padLeft(2, '0');

    if (widget.use24HourFormat) {
      final hStr = _hour.toString().padLeft(2, '0');

      return '$hStr : $mStr';
    } else {
      final hStr = _hour.toString().padLeft(2, '0');

      final period = _isAm
          ? LocaleKeys.custom_time_picker_am_short.tr()
          : LocaleKeys.custom_time_picker_pm_short.tr();

      return '$hStr : $mStr  $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.customAppColors;
    final primary = widget.primaryColor;
    final bg = widget.backgroundColor;
    final text = widget.textColor;
    final isBottomSheet =
        widget.displayMode == TimePickerDisplayMode.bottomSheet;
    final bottomInset = isBottomSheet
        ? MediaQuery.of(context).viewInsets.bottom
        : 0.0;
    final bottomPadding = isBottomSheet
        ? MediaQuery.of(context).padding.bottom
        : 0.0;

    final decoration = BoxDecoration(
      color: bg,
      borderRadius: isBottomSheet
          ? BorderRadius.vertical(top: Radius.circular(28.radius))
          : BorderRadius.circular(24.radius),
      boxShadow: [
        BoxShadow(
          color: themeColors.black.withValues(alpha: 0.12),
          blurRadius: 32,
          offset: isBottomSheet ? const Offset(0, -6) : const Offset(0, 10),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isBottomSheet ? double.infinity : 400.radius,
      ),
      child: Container(
        decoration: decoration,
        padding: EdgeInsets.fromLTRB(
          20.radius,
          isBottomSheet ? 12.radius : 20.radius,
          20.radius,
          (isBottomSheet ? 20.radius : 20.radius) + bottomInset + bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isBottomSheet) ...[
              Center(
                child: Container(
                  width: 50.radius,
                  height: 4.radius,
                  margin: EdgeInsets.only(bottom: 16.radius),
                  decoration: BoxDecoration(
                    color: text.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2.radius),
                  ),
                ),
              ),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.title ??
                        LocaleKeys.custom_time_picker_select_time.tr(),
                    style: context.f18sb.copyWith(color: text),
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.radius,
                    vertical: 5.radius,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.radius),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      _formattedPreview(),
                      style: context.f14sb.copyWith(
                        color: primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            verticalGap(18),

            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    primary.withValues(alpha: 0.0),
                    primary.withValues(alpha: 0.15),
                    primary.withValues(alpha: 0.25),
                    primary.withValues(alpha: 0.15),
                    primary.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),

            verticalGap(18),

            if (!widget.use24HourFormat) ...[
              _AmPmSwitcher(
                isAm: _isAm,
                primary: primary,
                text: text,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _isAm = val);
                },
              ),

              verticalGap(16),
            ],

            Container(
              height: 180.radius,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20.radius),
                border: Border.all(
                  color: primary.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 20.radius,
                    right: 20.radius,
                    height: _itemExtent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.radius),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RulerPainter(
                        color: text,
                        itemHeight: _itemExtent,
                      ),
                    ),
                  ),

                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80.radius,
                          child: _buildScrollWheel(
                            controller: _hourController,
                            itemCount: widget.use24HourFormat ? 24 : 12,
                            selectedIndex: widget.use24HourFormat
                                ? _hour
                                : _hour - 1,
                            labelBuilder: (i) {
                              final val = widget.use24HourFormat ? i : (i + 1);
                              return val.toString().padLeft(2, '0');
                            },
                            onSelectedItemChanged: (i) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _hour = widget.use24HourFormat ? i : (i + 1);
                              });
                            },
                            primaryColor: primary,
                            textColor: text,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.radius),
                          child: Text(
                            ':',
                            style: context.f28b.copyWith(
                              color: primary,
                              height: 0.9,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 80.radius,
                          child: _buildScrollWheel(
                            controller: _minuteController,
                            itemCount: 60,
                            selectedIndex: _minute,
                            labelBuilder: (i) => i.toString().padLeft(2, '0'),
                            onSelectedItemChanged: (i) {
                              HapticFeedback.selectionClick();
                              setState(() => _minute = i);
                            },
                            primaryColor: primary,
                            textColor: text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            verticalGap(20),

            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    primary.withValues(alpha: 0.0),
                    primary.withValues(alpha: 0.15),
                    primary.withValues(alpha: 0.25),
                    primary.withValues(alpha: 0.15),
                    primary.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),

            verticalGap(20),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppButton(
                    title:
                        widget.confirmTitle ??
                        LocaleKeys.custom_time_picker_done.tr(),
                    buttonHeight: 48.radius,
                    buttonColor: primary,
                    titleColor: themeColors.neutral0,
                    buttonRadius: 12.radius,
                    buttonBorder: Border.all(color: primary, width: 1.2.radius),
                    onPressed: () {
                      widget.onTimeSelected(_toTimeOfDay());
                    },
                  ),
                ),

                horizontalGap(10),

                Expanded(
                  flex: 2,
                  child: AppButton(
                    title:
                        widget.cancelTitle ??
                        LocaleKeys.custom_time_picker_cancel.tr(),
                    buttonHeight: 48.radius,
                    buttonColor: Colors.transparent,
                    titleColor: text.withValues(alpha: 0.6),
                    buttonRadius: 12.radius,
                    buttonBorder: Border.all(
                      color: text.withValues(alpha: 0.2),
                      width: 1.2.radius,
                    ),
                    onPressed: widget.onCancel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
    required Color primaryColor,
    required Color textColor,
    required String Function(int) labelBuilder,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _itemExtent,
      onSelectedItemChanged: onSelectedItemChanged,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.003,
      diameterRatio: 1.1,
      squeeze: 0.95,
      useMagnifier: true,
      magnification: 1.15,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          if (index < 0 || index >= itemCount) return null;
          final isSelected = index == selectedIndex;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: isSelected
                  ? context.f24b.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    )
                  : context.f20b.copyWith(
                      color: textColor.withValues(alpha: 0.28),
                      fontWeight: FontWeight.w500,
                    ),
              child: Text(labelBuilder(index)),
            ),
          );
        },
      ),
    );
  }
}

class _AmPmSwitcher extends StatelessWidget {
  const _AmPmSwitcher({
    required this.isAm,
    required this.primary,
    required this.text,
    required this.onChanged,
  });

  final bool isAm;
  final Color primary;
  final Color text;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final themeColors = context.customAppColors;
    return Container(
      padding: EdgeInsets.all(4.radius),
      decoration: BoxDecoration(
        color: text.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.radius),
        border: Border.all(color: text.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 8.radius),
                decoration: BoxDecoration(
                  color: isAm ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.radius),
                  boxShadow: isAm
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  LocaleKeys.custom_time_picker_am.tr(),
                  style: context.f14sb.copyWith(
                    color: isAm
                        ? themeColors.white
                        : text.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 8.radius),
                decoration: BoxDecoration(
                  color: !isAm ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.radius),
                  boxShadow: !isAm
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  LocaleKeys.custom_time_picker_pm.tr(),
                  style: context.f14sb.copyWith(
                    color: !isAm
                        ? themeColors.white
                        : text.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({required this.color, required this.itemHeight});

  final Color color;
  final double itemHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final maxDistance = size.height / 2;
    final longDashWidth = 28.width;
    final shortDashWidth = 12.width;

    paint.color = color.withValues(alpha: 0.25);

    canvas.drawLine(Offset(0, centerY), Offset(longDashWidth, centerY), paint);
    canvas.drawLine(
      Offset(size.width, centerY),
      Offset(size.width - longDashWidth, centerY),
      paint,
    );

    final count = (maxDistance / (itemHeight / 3)).ceil();

    for (int i = 1; i <= count; i++) {
      final offset = i * (itemHeight / 3);
      final t = (offset / maxDistance).clamp(0.0, 1.0);
      final opacity = (1 - t) * 0.2;

      paint.color = color.withValues(alpha: opacity);

      if (centerY - offset > 0) {
        canvas.drawLine(
          Offset(0, centerY - offset),
          Offset(shortDashWidth, centerY - offset),
          paint,
        );
        canvas.drawLine(
          Offset(size.width, centerY - offset),
          Offset(size.width - shortDashWidth, centerY - offset),
          paint,
        );
      }

      if (centerY + offset < size.height) {
        canvas.drawLine(
          Offset(0, centerY + offset),
          Offset(shortDashWidth, centerY + offset),
          paint,
        );
        canvas.drawLine(
          Offset(size.width, centerY + offset),
          Offset(size.width - shortDashWidth, centerY + offset),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
