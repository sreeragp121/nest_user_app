import 'package:flutter/material.dart';
import 'package:nest_user_app/constants/colors.dart';
import 'package:nest_user_app/controllers/auth_provider/auth_provider.dart';
import 'package:nest_user_app/utils/textformfield_utils/textformfield_utils.dart';
import 'package:nest_user_app/widgets/my_button.dart';
import 'package:nest_user_app/widgets/my_custom_text_field.dart';
import 'package:provider/provider.dart';

class LoginPagePhoneAuth extends StatelessWidget {
  const LoginPagePhoneAuth({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneNumController = TextEditingController();
    final TextEditingController otpController = TextEditingController();

    return Consumer<MyAuthProviders>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            authProvider.showOtpField
                ? Column(
                  children: [
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyCustomTextFormField(
                      controller: otpController,
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'OTP',
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: ValidationUtils.validateOTP,
                    ),
                    const SizedBox(height: 20),
                    MyCustomButton(
                      backgroundcolor: AppColors.primary,
                      textcolor: AppColors.white,
                      text: 'Submit',
                      onPressed: () {
                        authProvider.verifyOTP(context, otpController);
                      },
                    ),
                  ],
                )
                : Column(
                  children: [
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyCustomTextFormField(
                      controller: phoneNumController,
                      prefixIcon: const Icon(Icons.phone_android),
                      labelText: 'Phone',
                      keyboardType: TextInputType.phone,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: ValidationUtils.validatePhoneNumber,
                    ),
                    const SizedBox(height: 20),
                    MyCustomButton(
                      backgroundcolor: AppColors.primary,
                      textcolor: AppColors.white,
                      text: 'Get OTP',
                      onPressed: () {
                        authProvider.sendOTP(context, phoneNumController);
                      },
                    ),
                  ],
                ),
          ],
        );
      },
    );
  }
}
