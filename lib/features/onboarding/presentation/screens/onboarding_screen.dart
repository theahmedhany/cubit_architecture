import 'package:flutter/material.dart';

import '../../../../core/common/app/custom_app_bar.dart';
import '../../../../core/common/app/custom_app_tab.dart';
import '../../../../core/helpers/app_logger.dart';
import '../../../../core/helpers/dimensions_helper.dart';
import '../../../../core/theme/theme_manager/theme_extensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _selectedTabIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    AppLogger.log('Selected Tab: $index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customAppColors.neutral100,
      appBar: CustomAppBar(title: 'Onboarding', centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(20.radius),
        child: CustomAppTab(
          titles: const ['Documents', 'Lectures'],
          contents: const [
            Center(child: Text('Content for Tab 1')),
            Center(child: Text('Content for Tab 2')),
          ],
          selectedIndex: _selectedTabIndex,
          tabStyle: TabStyle.bottomBorder,
          selectedTabColor: context.customAppColors.danger600,
          selectedTextColor: context.customAppColors.danger600,
          unselectedTabColor: context.customAppColors.neutral300,
          unselectedTextColor: context.customAppColors.neutral400,
          onTabChanged: _onTabChanged,
        ),
      ),
    );
  }
}
