import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/colors.dart';
import '../../widgets/CustomButton.dart';

class VerifyAccountView extends GetView<AuthController> {
  const VerifyAccountView({Key? key}) : super(key: key);

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
        title: Text(
          'verify_mobile_number'.tr,
          style: const TextStyle(
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

              // وصف
              Text(
                'verification_code_sent'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111827),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'enter_field_below'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // حقل OTP باستخدام pin_code_fields
              _buildPinCodeField(),

              const SizedBox(height: 16),

              // رسالة الخطأ - تحديث للاستخدام المتحكمات المنفصلة
              Obx(() => controller.hasVerifyOtpError.value // تغيير هنا
                  ? Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  controller.verifyOtpErrorText.value, // تغيير هنا
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : const SizedBox.shrink()),

              const SizedBox(height: 32),

              // قسم إعادة الإرسال
              _buildResendSection(),

              const SizedBox(height: 40),

              // زر الإرسال - تحديث لاستخدام حالة التحميل المنفصلة
              Obx(() => CustomButton(
                text: 'submit'.tr,
                onPressed: controller.verifyAccount,
                isLoading: controller.isVerifyLoading.value, // تغيير هنا
                width: double.infinity,
                height: 56,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                borderRadius: 12,
              )),

              const SizedBox(height: 20),

              // زر مسح الرمز - تحديث لاستخدام دالة المسح المنفصلة
              TextButton(
                onPressed: controller.clearVerifyOtp, // تغيير هنا
                child: Text(
                  'مسح الرمز',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinCodeField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: PinCodeTextField(
          appContext: Get.context!,
          length: 6,
          controller: controller.verifyOtpController, // تغيير هنا
          errorAnimationController: controller.verifyOtpErrorController, // تغيير هنا
          animationType: AnimationType.fade,
          keyboardType: TextInputType.number,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),

          // تخصيص شكل الحقول
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 56,
            fieldWidth: 48,

            // الحالة العادية
            inactiveColor: const Color(0xFFE5E7EB),
            inactiveFillColor: Colors.white,

            // الحالة النشطة (عند التركيز)
            activeColor: AppColors.primary,
            activeFillColor: Colors.white,

            // الحالة المحددة (عند الكتابة)
            selectedColor: AppColors.primary,
            selectedFillColor: const Color(0xFFF3F4F6),

            // حالة الخطأ
            errorBorderColor: const Color(0xFFEF4444),

            borderWidth: 1.5,
          ),

          // تفعيل التعبئة
          enableActiveFill: true,

          // تفعيل التبديل التلقائي بين الحقول
          autoFocus: true,

          // إعدادات الكيبورد
          enablePinAutofill: true,
          useHapticFeedback: true,
          hapticFeedbackTypes: HapticFeedbackTypes.light,

          // الأنيميشن عند إدخال الرقم
          animationDuration: const Duration(milliseconds: 200),

          // تخصيص لون المؤشر
          cursorColor: AppColors.primary,
          cursorWidth: 2,

          // عند تغيير النص - استخدام الدالة المنفصلة
          onChanged: (value) {
            controller.onVerifyOtpChanged(value); // تغيير هنا
          },

          // عند إكمال الإدخال
          onCompleted: (value) {
            print("OTP مكتمل: $value");
            // التحقق التلقائي عند الاكتمال
            controller.verifyAccount();
          },

          // عند الضغط على الحقل
          onTap: () {
            print("تم الضغط على حقل OTP");
          },

          // إعدادات إضافية
          showCursor: true,
          blinkWhenObscuring: true,
          blinkDuration: const Duration(milliseconds: 500),
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'didnt_get_code'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        Obx(() => GestureDetector(
          onTap: controller.canResendOtp.value
              ? controller.resendAccountVerificationOtp
              : null,
          child: Text(
            'resend'.tr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: controller.canResendOtp.value
                  ? AppColors.primary
                  : const Color(0xFF9CA3AF),
              decoration: TextDecoration.underline,
            ),
          ),
        )),
        const SizedBox(width: 16),
        Obx(() => controller.otpTimer.value > 0
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFECACA),
              width: 1,
            ),
          ),
          child: Text(
            '${'expires_in'.tr} ${(controller.otpTimer.value ~/ 60).toString().padLeft(1, '0')}:${(controller.otpTimer.value % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFEF4444),
            ),
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }
}