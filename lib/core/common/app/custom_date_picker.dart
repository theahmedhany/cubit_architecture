import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helpers/date_formatter_helper.dart';
import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_language.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/theme_manager/theme_extensions.dart';
import 'app_button.dart';

enum DatePickerDisplayMode { bottomSheet, dialog }

class CustomDatePicker {
  const CustomDatePicker._();

  static Future<DateTime?> pick({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DatePickerDisplayMode displayMode = DatePickerDisplayMode.bottomSheet,
    String? title,
    String? confirmTitle,
    String? cancelTitle,
    Color? primaryColor,
    Color? backgroundColor,
    Color? textColor,
    ValueChanged<DateTime>? onDateSelected,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    final now = DateTime.now();
    final resolvedFirstDate = firstDate ?? DateTime(now.year - 50, 1, 1);
    final resolvedLastDate = lastDate ?? DateTime(now.year + 50, 12, 31);
    final themeColors = context.customAppColors;

    final selectedDate = (initialDate ?? now).clamp(
      min: resolvedFirstDate,
      max: resolvedLastDate,
    );

    final content = CustomCalendarView(
      initialDate: selectedDate,
      firstDate: resolvedFirstDate,
      lastDate: resolvedLastDate,
      displayMode: displayMode,
      title: title,
      confirmTitle: confirmTitle,
      cancelTitle: cancelTitle,
      primaryColor: primaryColor ?? themeColors.primary900,
      backgroundColor: backgroundColor ?? themeColors.neutral0,
      textColor: textColor ?? themeColors.neutral900,
      onDateSelected: (date) =>
          Navigator.of(context, rootNavigator: true).pop(date),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
    );

    DateTime? pickedDate;

    if (displayMode == DatePickerDisplayMode.bottomSheet) {
      pickedDate = await showModalBottomSheet<DateTime>(
        context: context,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: themeColors.black.withValues(alpha: 0.54),
        builder: (_) => content,
      );
    } else {
      pickedDate = await showDialog<DateTime>(
        context: context,
        barrierDismissible: isDismissible,
        barrierColor: themeColors.black.withValues(alpha: 0.54),
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

    if (pickedDate != null) {
      onDateSelected?.call(pickedDate);
    }

    return pickedDate;
  }
}

enum _CalendarMode { days, yearMonth }

class CustomCalendarView extends StatefulWidget {
  const CustomCalendarView({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.displayMode = DatePickerDisplayMode.bottomSheet,
    this.title,
    this.confirmTitle,
    this.cancelTitle,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.onDateSelected,
    required this.onCancel,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DatePickerDisplayMode displayMode;
  final String? title;
  final String? confirmTitle;
  final String? cancelTitle;
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
  _CalendarMode _mode = _CalendarMode.days;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
    _selectedYear = _currentMonth.year;
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
    HapticFeedback.selectionClick();

    final next = DateTime(_currentMonth.year, _currentMonth.month + direction);

    setState(() {
      _slideDirection = direction;
      _currentMonth = next;
      _selectedYear = next.year;
      _gridKey = _monthKey(next);
    });
  }

  void _selectYearAndMonth(int year, int month) {
    HapticFeedback.selectionClick();
    final target = DateTime(year, month);
    final clamped = target.isBefore(widget.firstDate)
        ? widget.firstDate
        : (target.isAfter(widget.lastDate) ? widget.lastDate : target);

    setState(() {
      _currentMonth = DateTime(clamped.year, clamped.month);
      _selectedYear = clamped.year;
      _gridKey = _monthKey(_currentMonth);
      _mode = _CalendarMode.days;
    });
  }

  String _formattedMonth(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return DateFormatterHelper.format(
      _currentMonth.toString(),
      type: DateFormatType.monthLong,
      locale: locale,
    );
  }

  List<String> _weekdayLabels(BuildContext context) {
    final isArabic =
        AppLanguage.isAR ||
        Localizations.localeOf(context).toString().startsWith('ar');

    if (isArabic) {
      return [
        context.tr('days_of_week.saturday_short'),
        context.tr('days_of_week.sunday_short'),
        context.tr('days_of_week.monday_short'),
        context.tr('days_of_week.tuesday_short'),
        context.tr('days_of_week.wednesday_short'),
        context.tr('days_of_week.thursday_short'),
        context.tr('days_of_week.friday_short'),
      ];
    }

    return [
      context.tr('days_of_week.monday_short'),
      context.tr('days_of_week.tuesday_short'),
      context.tr('days_of_week.wednesday_short'),
      context.tr('days_of_week.thursday_short'),
      context.tr('days_of_week.friday_short'),
      context.tr('days_of_week.saturday_short'),
      context.tr('days_of_week.sunday_short'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.customAppColors;
    final primary = widget.primaryColor;
    final text = widget.textColor;
    final bg = widget.backgroundColor;
    final isBottomSheet =
        widget.displayMode == DatePickerDisplayMode.bottomSheet;
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
                    widget.title ?? context.tr('select_date'),
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
                      color: primary.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    DateFormatterHelper.format(
                      _selectedDate.toString(),
                      type: DateFormatType.weekdayLong,
                      locale: Localizations.localeOf(context).toString(),
                    ),
                    style: context.f12sb.copyWith(color: primary),
                  ),
                ),
              ],
            ),

            verticalGap(16),

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

            verticalGap(16),

            _Header(
              monthName: _formattedMonth(context),
              year: _currentMonth.year.toString(),
              canPrev: _mode == _CalendarMode.days && _canGoPrev,
              canNext: _mode == _CalendarMode.days && _canGoNext,
              isYearMonthMode: _mode == _CalendarMode.yearMonth,
              onToggleMode: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _mode = _mode == _CalendarMode.days
                      ? _CalendarMode.yearMonth
                      : _CalendarMode.days;
                });
              },
              onPrev: () => _changeMonth(-1),
              onNext: () => _changeMonth(1),
              primary: primary,
              text: text,
            ),

            verticalGap(12),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _mode == _CalendarMode.days
                  ? Column(
                      key: const ValueKey('days_view'),
                      children: [
                        _WeekdayRow(
                          labels: _weekdayLabels(context),
                          text: text,
                        ),

                        verticalGap(8),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
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
                            onDayTap: (date) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedDate = date);
                            },
                            isSameDay: _isSameDay,
                            daysInMonth: _daysInMonth,
                          ),
                        ),
                      ],
                    )
                  : _YearMonthPicker(
                      key: const ValueKey('year_month_view'),
                      currentMonth: _currentMonth.month,
                      selectedYear: _selectedYear,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      primary: primary,
                      text: text,
                      backgroundColor: bg,
                      onYearSelected: (year) {
                        setState(() => _selectedYear = year);
                      },
                      onMonthSelected: (month) {
                        _selectYearAndMonth(_selectedYear, month);
                      },
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

            _ActionRow(
              primary: primary,
              text: text,
              confirmText: widget.confirmTitle ?? context.tr('done'),
              cancelText: widget.cancelTitle ?? context.tr('cancel'),
              onConfirm: () {
                HapticFeedback.mediumImpact();
                widget.onDateSelected(_selectedDate);
              },
              onCancel: widget.onCancel,
            ),
          ],
        ),
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
    required this.isYearMonthMode,
    required this.onToggleMode,
    required this.onPrev,
    required this.onNext,
    required this.primary,
    required this.text,
  });

  final String monthName;
  final String year;
  final bool canPrev;
  final bool canNext;
  final bool isYearMonthMode;
  final VoidCallback onToggleMode;
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
          child: GestureDetector(
            onTap: onToggleMode,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 4.radius,
                horizontal: 8.radius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '$monthName $year',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.f18sb.copyWith(
                        color: isYearMonthMode ? primary : text,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  horizontalGap(6),

                  AnimatedRotation(
                    turns: isYearMonthMode ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.radius,
                      color: isYearMonthMode
                          ? primary
                          : text.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
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
              letterSpacing: 0.4,
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
    final isArabic =
        AppLanguage.isAR ||
        Localizations.localeOf(context).toString().startsWith('ar');
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final startOffset = isArabic
        ? (firstDay.weekday + 1) % 7
        : (firstDay.weekday + 6) % 7;
    final totalDays = daysInMonth(currentMonth);
    final today = DateTime.now();
    final rows = _rowsForMonth(startOffset, totalDays);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
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
    final themeColors = context.customAppColors;

    final Color labelColor;

    if (isDisabled) {
      labelColor = text.withValues(alpha: 0.22);
    } else if (isSelected) {
      labelColor = themeColors.white;
    } else if (isToday) {
      labelColor = primary;
    } else {
      labelColor = text;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? primary : Colors.transparent,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
          border: isToday && !isSelected
              ? Border.all(color: primary, width: 1.6)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: context.f14r.copyWith(
              color: labelColor,
              fontWeight: (isSelected || isToday)
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _YearMonthPicker extends StatefulWidget {
  const _YearMonthPicker({
    super.key,
    required this.currentMonth,
    required this.selectedYear,
    required this.firstDate,
    required this.lastDate,
    required this.primary,
    required this.text,
    required this.backgroundColor,
    required this.onYearSelected,
    required this.onMonthSelected,
  });

  final int currentMonth;
  final int selectedYear;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color primary;
  final Color text;
  final Color backgroundColor;
  final ValueChanged<int> onYearSelected;
  final ValueChanged<int> onMonthSelected;

  @override
  State<_YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<_YearMonthPicker> {
  late final ScrollController _yearScrollController;
  static const double _yearItemWidth = 72.0;

  @override
  void initState() {
    super.initState();
    final yearOffsetIndex = (widget.selectedYear - widget.firstDate.year).clamp(
      0,
      500,
    );
    _yearScrollController = ScrollController(
      initialScrollOffset: (yearOffsetIndex * _yearItemWidth) - 100,
    );
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  List<String> _monthsShort(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final base = DateTime(2024, 1, 1);
    return List.generate(12, (i) {
      final d = DateTime(base.year, i + 1, 1);
      return DateFormatterHelper.format(
        d.toString(),
        type: DateFormatType.monthShort,
        locale: locale,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.customAppColors;

    final years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    );

    final monthNames = _monthsShort(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42.radius,
          child: Stack(
            children: [
              ListView.separated(
                controller: _yearScrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.radius),
                itemCount: years.length,
                separatorBuilder: (_, _) => horizontalGap(8),
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = year == widget.selectedYear;
                  return GestureDetector(
                    onTap: () => widget.onYearSelected(year),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(horizontal: 16.radius),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.primary
                            : widget.text.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10.radius),
                        border: isSelected
                            ? Border.all(color: widget.primary, width: 1.2)
                            : Border.all(
                                color: widget.text.withValues(alpha: 0.12),
                                width: 1.0,
                              ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$year',
                        style: context.f14sb.copyWith(
                          color: isSelected ? themeColors.white : widget.text,
                        ),
                      ),
                    ),
                  );
                },
              ),

              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 24.radius,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 24.radius,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        verticalGap(16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final month = index + 1;
            final isCurrentMonth =
                month == widget.currentMonth &&
                widget.selectedYear == DateTime.now().year;
            final isMonthInRange =
                !(DateTime(widget.selectedYear, month).isBefore(
                      DateTime(widget.firstDate.year, widget.firstDate.month),
                    ) ||
                    DateTime(widget.selectedYear, month).isAfter(
                      DateTime(widget.lastDate.year, widget.lastDate.month),
                    ));

            return GestureDetector(
              onTap: isMonthInRange
                  ? () => widget.onMonthSelected(month)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isCurrentMonth
                      ? widget.primary.withValues(alpha: 0.12)
                      : widget.text.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10.radius),
                  border: isCurrentMonth
                      ? Border.all(color: widget.primary, width: 1.2)
                      : Border.all(
                          color: widget.text.withValues(alpha: 0.12),
                          width: 1.0,
                        ),
                ),
                alignment: Alignment.center,
                child: Text(
                  monthNames[index],
                  style: context.f14sb.copyWith(
                    color: !isMonthInRange
                        ? widget.text.withValues(alpha: 0.25)
                        : (isCurrentMonth ? widget.primary : widget.text),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.primary,
    required this.text,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  });

  final Color primary;
  final Color text;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final themeColors = context.customAppColors;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: AppButton(
            title: confirmText,
            buttonHeight: 48.radius,
            buttonColor: primary,
            titleColor: themeColors.neutral0,
            buttonRadius: 12.radius,
            buttonBorder: Border.all(color: primary, width: 1.2.radius),
            onPressed: onConfirm,
          ),
        ),

        horizontalGap(10),

        Expanded(
          flex: 2,
          child: AppButton(
            title: cancelText,
            buttonHeight: 48.radius,
            buttonColor: Colors.transparent,
            titleColor: text.withValues(alpha: 0.6),
            buttonRadius: 12.radius,
            buttonBorder: Border.all(
              color: text.withValues(alpha: 0.2),
              width: 1.2.radius,
            ),
            onPressed: onCancel,
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
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      icon: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: active ? 1.0 : 0.3,
        child: Container(
          padding: EdgeInsets.all(7.radius),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            color: color.withValues(alpha: active ? 0.75 : 0.25),
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
