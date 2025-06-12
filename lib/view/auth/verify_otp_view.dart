import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/CustomButton.dart';

class VerifyOtpView extends GetView<AuthController> {
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dialog container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      const Text(
                        'Forgot your Password?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'We sent you a 4 digit code to verify\nyour mobile number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Enter in the field below.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // OTP Input Fields
                      _buildOtpInput(),

                      const SizedBox(height: 24),

                      // Resend section
                      _buildResendSection(),

                      const SizedBox(height: 32),

                      // Confirmation button
                      Obx(() => CustomButton(
                        text: 'Confirmation',
                        onPressed: controller.verifyOtpCode,
                        isLoading: controller.isLoading.value,
                        width: double.infinity,
                        height: 56,
                        backgroundColor: AppColors.primary,
                        textColor: Colors.white,
                        borderRadius: 12,
                        icon: Icons.check,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textSecondary,
              width: 1.5,
            ),
          ),
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // تحديث الرمز في المتحكم
                _updateOtpCode(index, value);

                // الانتقال للحقل التالي
                if (index < 3) {
                  FocusScope.of(Get.context!).nextFocus();
                }
              } else {
                // إذا تم حذف الرقم، انتقل للحقل السابق
                if (index > 0) {
                  FocusScope.of(Get.context!).previousFocus();
                }
                _updateOtpCode(index, '');
              }
            },
          ),
        );
      }),
    );
  }

  void _updateOtpCode(int index, String digit) {
    String currentOtp = controller.otpController.text.padRight(4, ' ');
    List<String> otpDigits = currentOtp.split('');

    if (index < otpDigits.length) {
      otpDigits[index] = digit;
    }

    controller.otpController.text = otpDigits.join('').trim();
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Didn't get the code? ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Obx(() => GestureDetector(
          onTap: controller.canResendOtp.value ? controller.resendOtp : null,
          child: Text(
            'Resend',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color:  Colors.black ,

            ),
          ),
        )),
        const SizedBox(width: 8),
        Obx(() => controller.otpTimer.value > 0
            ? Text(
          'Expires in ${(controller.otpTimer.value ~/ 60).toString().padLeft(1, '0')}:${(controller.otpTimer.value % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFEF4444),
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }
}