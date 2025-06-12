import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/CustomButton.dart';

class VerifyAccountView extends GetView<AuthController> {
  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF111827),
            size: 20,
          ),
        ),
        title: const Text(
          'Verify your mobile number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Description
              const Text(
                'We sent you a 4 digit code to verify\nyour mobile number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              const Text(
                'Enter in the field below.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // OTP Input Fields
              _buildOtpInput(),

              const SizedBox(height: 32),

              // Resend section
              _buildResendSection(),

              const SizedBox(height: 40),

              // Submit button
              Obx(() => CustomButton(
                text: 'Submit',
                onPressed: controller.verifyAccount,
                isLoading: controller.isLoading.value,
                width: double.infinity,
                height: 56,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                borderRadius: 12,
              )),
            ],
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
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
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
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        Obx(() => GestureDetector(
          onTap: controller.canResendOtp.value ? controller.resendAccountVerificationOtp : null,
          child: Text(
            'Resend',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: controller.canResendOtp.value
                  ? AppColors.primary
                  : const Color(0xFF9CA3AF),
            ),
          ),
        )),
        const SizedBox(width: 16),
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