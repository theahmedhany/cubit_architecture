import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_button.dart';

class CustomTimePicker {
  const CustomTimePicker._();

  static Future<TimeOfDay?> pick({
    required BuildContext context,
    TimeOfDay? initialTime,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    ValueChanged<TimeOfDay>? onTimeSelected,
    bool isDismissible = true,
  }) async {
    final now = TimeOfDay.now();
    final resolvedInitial = initialTime ?? now;

    final pickedTime = await showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (_) => _TimePickerBottomSheet(
        initialTime: resolvedInitial,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
    );

    if (pickedTime != null) {
      onTimeSelected?.call(pickedTime);
    }

    return pickedTime;
  }
}

class _TimePickerBottomSheet extends StatefulWidget {
  const _TimePickerBottomSheet({
    required this.initialTime,
    this.primaryColor,
    this.backgroundColor,
    this.textColor,
  });

  final TimeOfDay initialTime;
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  State<_TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<_TimePickerBottomSheet> {
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  late int _hour12;
  late int _minute;
  late bool _isAm;

  static const double _itemExtent = 60.0;

  @override
  void initState() {
    super.initState();

    final h = widget.initialTime.hour;
    final m = widget.initialTime.minute;

    _isAm = h < 12;
    _hour12 = (h % 12 == 0) ? 12 : (h % 12);
    _minute = m;

    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);

    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay _to24Hour() {
    int hour = _hour12;

    if (_isAm) {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }

    return TimeOfDay(hour: hour, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;
    final primary = widget.primaryColor ?? colors.primary900;
    final background = widget.backgroundColor ?? colors.neutral0;
    final text = widget.textColor ?? colors.neutral900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.radius)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.radius,
            vertical: 16.radius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.width,
                height: 4.height,
                decoration: BoxDecoration(
                  color: text.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.radius),
                ),
              ),
              verticalGap(16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr('select_time'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.f20sb.copyWith(color: text),
                    ),
                  ),
                ],
              ),
              verticalGap(24),
              Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: context.tr('am'),
                      isSelected: _isAm,
                      onTap: () => setState(() => _isAm = true),
                      activeColor: primary,
                      selectedTextColor: background,
                      unSelectedTextColor: text,
                      unActiveColor: text.withValues(alpha: 0.15),
                    ),
                  ),
                  horizontalGap(16),
                  Expanded(
                    child: _buildToggleButton(
                      label: context.tr('pm'),
                      isSelected: !_isAm,
                      onTap: () => setState(() => _isAm = false),
                      activeColor: primary,
                      selectedTextColor: background,
                      unSelectedTextColor: text,
                      unActiveColor: text.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
              verticalGap(24),
              Container(
                height: 180.height,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24.radius),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RulerPainter(
                          color: text,
                          itemHeight: _itemExtent,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        horizontalGap(40),
                        SizedBox(
                          width: 80.width,
                          child: _buildScrollPicker(
                            controller: _hourController,
                            itemCount: 12,
                            labelBuilder: (i) => (i + 1).toString(),
                            onSelectedItemChanged: (i) =>
                                setState(() => _hour12 = i + 1),
                            textColor: text,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.radius),
                          child: Text(
                            ':',
                            style: context.f32sb.copyWith(
                              color: text.withValues(alpha: 0.4),
                              fontSize: 36.font,
                              height: 0.8,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80.width,
                          child: _buildScrollPicker(
                            controller: _minuteController,
                            itemCount: 60,
                            labelBuilder: (i) => i.toString().padLeft(2, '0'),
                            onSelectedItemChanged: (i) =>
                                setState(() => _minute = i),
                            textColor: text,
                          ),
                        ),
                        horizontalGap(40),
                      ],
                    ),
                  ],
                ),
              ),
              verticalGap(32),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppButton(
                      title: context.tr('done'),
                      buttonHeight: 54.radius,
                      buttonColor: primary,
                      titleColor: background,
                      buttonRadius: 12.radius,
                      onPressed: () {
                        Navigator.of(context).pop(_to24Hour());
                      },
                    ),
                  ),

                  horizontalGap(12),

                  Expanded(
                    flex: 2,
                    child: AppButton(
                      title: context.tr('cancel'),
                      buttonHeight: 54.radius,
                      buttonColor: Colors.transparent,
                      titleColor: text,
                      buttonRadius: 12.radius,
                      buttonBorder: Border.all(
                        color: text.withValues(alpha: 0.15),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color unActiveColor,
    required Color selectedTextColor,
    required Color unSelectedTextColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: 14.radius,
          horizontal: 6.radius,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(
            color: isSelected ? activeColor : unActiveColor,
            width: 1.5.radius,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.radius),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? selectedTextColor : unSelectedTextColor,
                fontSize: 16.font,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onSelectedItemChanged,
    required Color textColor,
    required String Function(int) labelBuilder,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: _itemExtent,
      onSelectedItemChanged: onSelectedItemChanged,
      backgroundColor: Colors.transparent,
      selectionOverlay: const SizedBox.shrink(),
      useMagnifier: true,
      magnification: 1.2,
      diameterRatio: 1.2,
      squeeze: 0.9,
      children: List.generate(
        itemCount,
        (index) => Center(
          child: Text(
            labelBuilder(index),
            style: TextStyle(
              color: textColor,
              fontSize: 34.font,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final maxDistance = size.height / 2;
    final longDashWidth = 34.width;
    final shortDashWidth = 14.width;

    paint.color = color;

    canvas.drawLine(Offset(0, centerY), Offset(longDashWidth, centerY), paint);

    canvas.drawLine(
      Offset(size.width, centerY),
      Offset(size.width - longDashWidth, centerY),
      paint,
    );

    final count = (maxDistance / (itemHeight / 4)).ceil();

    for (int i = 1; i <= count; i++) {
      final offset = i * (itemHeight / 4);
      final t = (offset / maxDistance).clamp(0.0, 1.0);
      final opacity = (1 - t) * 0.35;

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
