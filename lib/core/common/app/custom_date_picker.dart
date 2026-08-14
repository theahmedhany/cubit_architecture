import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_button.dart';

class CustomDatePicker {
  const CustomDatePicker._();

  static Future<DateTime?> pick({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    ValueChanged<DateTime>? onDateSelected,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    final now = DateTime.now();

    final resolvedFirstDate = firstDate ?? DateTime(now.year - 5);
    final resolvedLastDate = lastDate ?? DateTime(now.year + 5);

    final selectedDate = (initialDate ?? now).clamp(
      min: resolvedFirstDate,
      max: resolvedLastDate,
    );

    final pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => CustomCalendarView(
        initialDate: selectedDate,
        firstDate: resolvedFirstDate,
        lastDate: resolvedLastDate,
        primaryColor: primaryColor ?? ctx.customAppColors.primary900,
        backgroundColor: backgroundColor ?? ctx.customAppColors.neutral0,
        textColor: textColor ?? ctx.customAppColors.neutral900,
        onDateSelected: (date) => Navigator.pop(ctx, date),
        onCancel: () => Navigator.pop(ctx),
      ),
    );

    if (pickedDate != null) {
      onDateSelected?.call(pickedDate);
    }

    return pickedDate;
  }
}

class CustomCalendarView extends StatefulWidget {
  const CustomCalendarView({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.onDateSelected,
    required this.onCancel,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onCancel;

  @override
  State<CustomCalendarView> createState() => _CustomCalendarViewState();
}

class _CustomCalendarViewState extends State<CustomCalendarView> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  int _slideDirection = 1;
  late ValueKey<String> _gridKey;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
    _gridKey = _monthKey(_currentMonth);
  }

  ValueKey<String> _monthKey(DateTime d) => ValueKey('${d.year}-${d.month}');

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  bool get _canGoPrev {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1);
    return !prev.isBefore(
      DateTime(widget.firstDate.year, widget.firstDate.month),
    );
  }

  bool get _canGoNext {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    return !next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  void _changeMonth(int direction) {
    final next = DateTime(_currentMonth.year, _currentMonth.month + direction);
    setState(() {
      _slideDirection = direction;
      _currentMonth = next;
      _gridKey = _monthKey(next);
    });
  }

  String _formattedMonth(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('MMMM', locale).format(_currentMonth);
  }

  List<String> _weekdayLabels(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final isArabic = locale.startsWith('ar');
    final base = DateTime(2024, 1, 1);

    return List.generate(7, (i) {
      final date = base.add(Duration(days: i));
      String name = DateFormat.E(locale).format(date);
      if (isArabic) {
        if (name.startsWith('ال')) name = name.substring(2);
        name = name.characters.take(3).toString();
      } else {
        name = name.length > 3 ? name.substring(0, 3) : name;
      }
      return name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor;
    final text = widget.textColor;
    final bg = widget.backgroundColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + bottomInset + bottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: text.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          _Header(
            monthName: _formattedMonth(context),
            year: _currentMonth.year.toString(),
            canPrev: _canGoPrev,
            canNext: _canGoNext,
            onPrev: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
            primary: primary,
            text: text,
          ),
          verticalGap(16),
          _WeekdayRow(labels: _weekdayLabels(context), text: text),
          verticalGap(8),
          Divider(color: text.withValues(alpha: 0.07), height: 1),
          verticalGap(12),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetTween = Tween<Offset>(
                begin: Offset(0.18 * _slideDirection, 0),
                end: Offset.zero,
              );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetTween.animate(animation),
                  child: child,
                ),
              );
            },
            child: _MonthGrid(
              key: _gridKey,
              currentMonth: _currentMonth,
              selectedDate: _selectedDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              primary: primary,
              text: text,
              onDayTap: (date) => setState(() => _selectedDate = date),
              isSameDay: _isSameDay,
              daysInMonth: _daysInMonth,
            ),
          ),

          verticalGap(20),

          _ActionRow(
            primary: primary,
            text: text,
            onConfirm: () => widget.onDateSelected(_selectedDate),
            onCancel: widget.onCancel,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.monthName,
    required this.year,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.primary,
    required this.text,
  });

  final String monthName;
  final String year;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Color primary;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          onTap: canPrev ? onPrev : null,
          color: text,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  monthName,
                  key: ValueKey(monthName),
                  style: context.f20sb.copyWith(color: text),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                year,
                style: context.f14r.copyWith(
                  color: text.withValues(alpha: 0.45),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onTap: canNext ? onNext : null,
          color: text,
        ),
      ],
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow({required this.labels, required this.text});

  final List<String> labels;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: labels.map((label) {
        return SizedBox(
          width: 36.radius,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.f12sb.copyWith(
              color: text.withValues(alpha: 0.45),
              letterSpacing: 0.6,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.primary,
    required this.text,
    required this.onDayTap,
    required this.isSameDay,
    required this.daysInMonth,
  });

  final DateTime currentMonth;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color primary;
  final Color text;
  final ValueChanged<DateTime> onDayTap;
  final bool Function(DateTime, DateTime) isSameDay;
  final int Function(DateTime) daysInMonth;

  static int _rowsForMonth(int startOffset, int totalDays) =>
      ((startOffset + totalDays) / 7).ceil();

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final startOffset = (firstDay.weekday + 6) % 7;
    final totalDays = daysInMonth(currentMonth);
    final today = DateTime.now();
    final rows = _rowsForMonth(startOffset, totalDays);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final day = index - startOffset + 1;
        if (day < 1 || day > totalDays) return const SizedBox.shrink();

        final date = DateTime(currentMonth.year, currentMonth.month, day);
        final isSelected = isSameDay(date, selectedDate);
        final isToday = isSameDay(date, today);
        final isDisabled = date.isBefore(firstDate) || date.isAfter(lastDate);

        return _DayCell(
          day: day,
          isSelected: isSelected,
          isToday: isToday,
          isDisabled: isDisabled,
          primary: primary,
          text: text,
          onTap: isDisabled ? null : () => onDayTap(date),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.primary,
    required this.text,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final Color primary;
  final Color text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color labelColor;
    if (isDisabled) {
      labelColor = text.withValues(alpha: 0.2);
    } else if (isSelected) {
      labelColor = Colors.white;
    } else if (isToday) {
      labelColor = primary;
    } else {
      labelColor = text;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? primary : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: primary, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: context.f14r.copyWith(
              color: labelColor,
              fontWeight: (isSelected || isToday)
                  ? FontWeight.w700
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.primary,
    required this.text,
    required this.onConfirm,
    required this.onCancel,
  });

  final Color primary;
  final Color text;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AppButton(
            title: context.tr('done'),
            buttonColor: primary,
            onPressed: onConfirm,
            buttonHeight: 54.radius,
            buttonRadius: 12.radius,
          ),
        ),
        horizontalGap(10),
        Expanded(
          flex: 2,
          child: AppButton(
            title: context.tr('cancel'),
            onPressed: onCancel,
            buttonColor: Colors.transparent,
            titleColor: text.withValues(alpha: 0.7),
            buttonBorder: Border.all(color: text.withValues(alpha: 0.12)),
            buttonHeight: 54.radius,
            buttonRadius: 12.radius,
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: active ? 1.0 : 0.3,
        child: Container(
          padding: EdgeInsets.all(8.radius),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.04),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: color.withValues(alpha: active ? 0.7 : 0.3),
            size: 20.radius,
          ),
        ),
      ),
    );
  }
}

extension _DateTimeClamp on DateTime {
  DateTime clamp({required DateTime min, required DateTime max}) {
    if (isBefore(min)) return min;
    if (isAfter(max)) return max;
    return this;
  }
}
