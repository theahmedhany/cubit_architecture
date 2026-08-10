import 'package:flutter/cupertino.dart';

import '../../helpers/dimensions_helper.dart';
import '../../helpers/spacing.dart';
import '../../theme/app_texts/app_text_styles.dart';
import '../../theme/app_texts/font_weight_helper.dart';
import '../../theme/theme_manager/theme_extensions.dart';

class CustomAppTab extends StatelessWidget {
  const CustomAppTab({
    super.key,
    required this.titles,
    required this.contents,
    required this.selectedIndex,
    required this.onTabChanged,
    this.width,
    this.tabStyle = TabStyle.bottomBorder,
    this.selectedTabColor,
    this.selectedTextColor,
    this.unselectedTabColor,
    this.unselectedTextColor,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeInOut,
  }) : assert(titles.length == contents.length),
       assert(titles.length >= 2 && titles.length <= 5),
       assert(selectedIndex >= 0 && selectedIndex < titles.length);

  final List<String> titles;
  final List<Widget> contents;
  final double? width;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final TabStyle tabStyle;
  final Color? selectedTabColor;
  final Color? selectedTextColor;
  final Color? unselectedTabColor;
  final Color? unselectedTextColor;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    final tabBar = switch (tabStyle) {
      TabStyle.filled => _FilledTabBar(
        titles: titles,
        selectedIndex: selectedIndex,
        onTabChanged: onTabChanged,
        selectedTabColor: selectedTabColor,
        selectedTextColor: selectedTextColor,
        unselectedTabColor: unselectedTabColor,
        unselectedTextColor: unselectedTextColor,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
      ),
      TabStyle.bottomBorder => _BottomBorderTabBar(
        titles: titles,
        selectedIndex: selectedIndex,
        onTabChanged: onTabChanged,
        selectedTabColor: selectedTabColor,
        selectedTextColor: selectedTextColor,
        unselectedTabColor: unselectedTabColor,
        unselectedTextColor: unselectedTextColor,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
      ),
      TabStyle.slidingUnderline => _SlidingUnderlineTabBar(
        titles: titles,
        selectedIndex: selectedIndex,
        onTabChanged: onTabChanged,
        selectedTabColor: selectedTabColor,
        selectedTextColor: selectedTextColor,
        unselectedTabColor: unselectedTabColor,
        unselectedTextColor: unselectedTextColor,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: width, child: tabBar),

        verticalGap(20),

        Expanded(
          child: AnimatedSwitcher(
            duration: animationDuration,
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.topCenter,
              children: [...previousChildren, ?currentChild],
            ),
            switchInCurve: animationCurve,
            switchOutCurve: animationCurve,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey<int>(selectedIndex),
              child: contents[selectedIndex],
            ),
          ),
        ),
      ],
    );
  }
}

class _SlidingUnderlineTabBar extends StatelessWidget {
  final List<String> titles;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Color? selectedTabColor;
  final Color? selectedTextColor;
  final Color? unselectedTabColor;
  final Color? unselectedTextColor;
  final Duration animationDuration;
  final Curve animationCurve;

  const _SlidingUnderlineTabBar({
    required this.titles,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.selectedTabColor,
    required this.selectedTextColor,
    required this.unselectedTabColor,
    required this.unselectedTextColor,
    required this.animationDuration,
    required this.animationCurve,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.customAppColors.primary500;

    final selectedColor = selectedTabColor ?? primary;
    final selectedText = selectedTextColor ?? primary;
    final unselectedText =
        unselectedTextColor ?? context.customAppColors.neutral400;
    final trackColor = unselectedTabColor ?? context.customAppColors.neutral200;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / titles.length;

        return SizedBox(
          height: 48.height,
          child: Stack(
            children: [
              Row(
                children: List.generate(titles.length, (index) {
                  final isSelected = index == selectedIndex;

                  return Expanded(
                    child: CupertinoButton(
                      onPressed: () => onTabChanged(index),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: animationDuration,
                          curve: animationCurve,
                          style: context.f14sb.copyWith(
                            color: isSelected ? selectedText : unselectedText,
                          ),
                          child: Text(
                            titles[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              AnimatedPositionedDirectional(
                duration: animationDuration,
                curve: animationCurve,
                start: selectedIndex * tabWidth,
                bottom: 0,
                child: Container(
                  width: tabWidth,
                  height: 3,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilledTabBar extends StatelessWidget {
  final List<String> titles;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Color? selectedTabColor;
  final Color? selectedTextColor;
  final Color? unselectedTabColor;
  final Color? unselectedTextColor;
  final Duration animationDuration;
  final Curve animationCurve;

  const _FilledTabBar({
    required this.titles,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.animationDuration,
    required this.animationCurve,
    this.selectedTabColor,
    this.selectedTextColor,
    this.unselectedTabColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    final selectedBg = selectedTabColor ?? colors.primary500;
    final selectedText = selectedTextColor ?? colors.neutral0;
    final unselectedText = unselectedTextColor ?? colors.neutral500;

    return Container(
      height: 54.height,
      decoration: BoxDecoration(
        color: unselectedTabColor ?? colors.neutral100,
        borderRadius: BorderRadius.circular(14.radius),
        border: Border.all(color: selectedBg.withValues(alpha: 0.2)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / titles.length;

          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                start: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedBg,
                    borderRadius: BorderRadius.circular(12.radius),
                  ),
                ),
              ),
              Row(
                children: List.generate(titles.length, (index) {
                  final isSelected = index == selectedIndex;

                  return Expanded(
                    child: CupertinoButton(
                      onPressed: () => onTabChanged(index),
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: animationDuration,
                          style: context.f14m.copyWith(
                            fontWeight: isSelected
                                ? FontWeightHelper.bold
                                : FontWeightHelper.medium,
                            color: isSelected ? selectedText : unselectedText,
                          ),
                          child: Text(titles[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomBorderTabBar extends StatelessWidget {
  final List<String> titles;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Color? selectedTabColor;
  final Color? selectedTextColor;
  final Color? unselectedTabColor;
  final Color? unselectedTextColor;
  final Duration animationDuration;
  final Curve animationCurve;

  const _BottomBorderTabBar({
    required this.titles,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.animationDuration,
    required this.animationCurve,
    this.selectedTabColor,
    this.selectedTextColor,
    this.unselectedTabColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.height,
      child: Row(
        children: List.generate(
          titles.length,
          (index) => _BottomBorderTabItem(
            title: titles[index],
            index: index,
            isSelected: selectedIndex == index,
            isCompact: titles.length >= 5,
            onTap: onTabChanged,
            selectedTabColor: selectedTabColor,
            selectedTextColor: selectedTextColor,
            unselectedTabColor: unselectedTabColor,
            unselectedTextColor: unselectedTextColor,
            animationDuration: animationDuration,
            animationCurve: animationCurve,
          ),
        ),
      ),
    );
  }
}

class _BottomBorderTabItem extends StatelessWidget {
  final String title;
  final int index;
  final bool isSelected;
  final bool isCompact;
  final ValueChanged<int> onTap;
  final Color? selectedTabColor;
  final Color? selectedTextColor;
  final Color? unselectedTabColor;
  final Color? unselectedTextColor;
  final Duration animationDuration;
  final Curve animationCurve;

  const _BottomBorderTabItem({
    required this.title,
    required this.index,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
    required this.animationDuration,
    required this.animationCurve,
    this.selectedTabColor,
    this.selectedTextColor,
    this.unselectedTabColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.customAppColors.primary500;

    final indicatorColor = selectedTabColor ?? primary;

    final textColor = isSelected
        ? (selectedTextColor ?? primary)
        : (unselectedTextColor ?? context.customAppColors.neutral400);

    return Expanded(
      child: CupertinoButton(
        onPressed: () => onTap(index),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        child: SizedBox.expand(
          child: AnimatedContainer(
            duration: animationDuration,
            curve: animationCurve,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 4.width : 8.width,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.96,
                  duration: animationDuration,
                  curve: animationCurve,
                  child: AnimatedDefaultTextStyle(
                    duration: animationDuration,
                    curve: animationCurve,
                    style: context.f14sb.copyWith(color: textColor),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                verticalGap(8),

                AnimatedContainer(
                  duration: animationDuration,
                  curve: animationCurve,
                  height: 3,
                  width: isSelected ? 32.width : 0,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum TabStyle { bottomBorder, slidingUnderline, filled }
