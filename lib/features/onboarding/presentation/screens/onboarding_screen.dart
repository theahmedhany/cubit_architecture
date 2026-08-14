import 'package:flutter/material.dart';

import '../../../../core/common/app/app_button.dart';
import '../../../../core/common/app/app_snack_bar.dart';
import '../../../../core/common/app/app_text_form_field.dart';
import '../../../../core/common/app/custom_app_bar.dart';
import '../../../../core/helpers/dimensions_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/route_manager.dart';
import '../../../../core/theme/theme_manager/theme_extensions.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customAppColors.neutral100,
      appBar: CustomAppBar(
        title: 'Settings',
        subtitle: 'Online',
        centerTitle: false,
        forceMaterialTransparency: false,
        showDivider: true,
        showBackButton: false,
        toolbarHeight: 72,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          SizedBox(width: 8.radius),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextFormField(
              hintText: 'Enter your name',
              title: 'Name',
              isRequired: true,
              isPassword: true,
              // focusedBackgroundColor: context.customAppColors.neutral200,
              onChanged: (value) {
                // Handle text change
              },
            ),

            verticalGap(6),

            AppButton(
              title: 'Next',
              onPressed: () {
                AppSnackBar.show(
                  context: context,
                  message: 'Next button long pressed',
                  type: AppSnackBarType.error,
                  position: AppSnackBarPosition.bottom,
                );

                RouteManager.navigateTo(const LoginScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Login',
        centerTitle: true,
        showBackButton: true,
        onBackPressed: () {
          RouteManager.pop();
        },
      ),
      body: const Center(child: Text('Login Screen')),
    );
  }
}
