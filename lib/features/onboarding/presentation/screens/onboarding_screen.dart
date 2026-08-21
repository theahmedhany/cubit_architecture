import 'package:flutter/material.dart';

import '../../../../core/common/app/app_button.dart';
import '../../../../core/common/app/app_pin_code_field.dart';
import '../../../../core/common/app/app_snack_bar.dart';
import '../../../../core/common/app/app_text_form_field.dart';
import '../../../../core/common/app/custom_app_bar.dart';
import '../../../../core/helpers/dimensions_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/route_manager.dart';
import '../../../../core/theme/app_texts/app_text_styles.dart';
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
              onChanged: (value) {
                // Handle text change
              },
            ),

            verticalGap(16),

            AppButton(
              title: 'Go to OTP Verification',
              onPressed: () {
                RouteManager.navigateTo(const LoginScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _pinController;
  late final FocusNode _pinFocusNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _pinFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

        if (_pinController.text == '1234') {
          AppSnackBar.show(
            context: context,
            message: 'OTP Verified successfully!',
            type: AppSnackBarType.success,
            position: AppSnackBarPosition.top,
          );
        } else {
          AppSnackBar.show(
            context: context,
            message: 'Invalid code! Please enter 1234',
            type: AppSnackBarType.error,
            position: AppSnackBarPosition.top,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.customAppColors;

    return Scaffold(
      backgroundColor: colors.neutral50,
      appBar: CustomAppBar(
        title: 'OTP Verification',
        centerTitle: true,
        showBackButton: true,
        onBackPressed: () => RouteManager.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 20.width,
          vertical: 24.height,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              verticalGap(16),

              Text(
                'Enter Verification Code',
                style: context.f20b.copyWith(color: colors.neutral950),
              ),

              verticalGap(8),

              Text(
                'We have sent a 4-digit verification code to your registered mobile number.',
                textAlign: TextAlign.center,
                style: context.f14r.copyWith(color: colors.neutral500),
              ),

              verticalGap(32),

              AppPinCodeField(
                controller: _pinController,
                focusNode: _pinFocusNode,
                length: 6,
                withTitle: true,
                title: 'Security PIN',
                isRequired: true,
                helperText: 'Hint: Enter "1234" to test success',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the 4-digit code';
                  }
                  if (value.length < 6) {
                    return 'Code must be 4 digits';
                  }
                  return null;
                },
                onCompleted: (pin) {
                  _verifyOtp();
                },
              ),

              verticalGap(24),

              AppButton(
                title: 'Verify & Continue',
                isLoading: _isLoading,
                enableHapticFeedback: true,
                onPressed: _verifyOtp,
              ),

              verticalGap(20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: context.f14r.copyWith(color: colors.neutral500),
                  ),
                  GestureDetector(
                    onTap: () {
                      _pinController.clear();
                      AppSnackBar.show(
                        context: context,
                        message: 'A new code has been sent.',
                        type: AppSnackBarType.info,
                        position: AppSnackBarPosition.top,
                      );
                    },
                    child: Text(
                      'Resend Code',
                      style: context.f14sb.copyWith(color: colors.primary600),
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
}
