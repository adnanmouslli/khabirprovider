import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../controllers/ForgotPasswordController.dart';
import '../../utils/colors.dart';
import '../../widgets/CustomButton.dart';
import '../../widgets/CustomTextField.dart';

class ResetPasswordView extends GetView<ForgotPasswordController> {
  final ForgotPasswordController controller = Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    // تحميل رقم الهاتف المحفوظ عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSavedPhoneNumber();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF374151),
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
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
                      // أيقونة القفل
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // العنوان
                      Text(
                        'reset_password'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // الوصف
                      Text(
                        'enter_otp_and_new_password'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // عرض رقم الهاتف المرسل إليه (اختياري)
                      const SizedBox(height: 8),
                      Obx(() => controller.formattedPhoneNumber.value.isNotEmpty
                          ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${'sent_to'.tr}: ${controller.formattedPhoneNumber.value}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                          : const SizedBox.shrink()),

                      const SizedBox(height: 32),

                      // قسم رمز التحقق
                      _buildOtpSection(),

                      const SizedBox(height: 24),

                      // قسم كلمة المرور الجديدة
                      _buildPasswordSection(),

                      const SizedBox(height: 24),

                      // قسم إعادة الإرسال
                      _buildResendSection(),

                      const SizedBox(height: 32),

                      // زر إعادة تعيين كلمة المرور
                      Obx(() => CustomButton(
                        text: 'reset_password'.tr,
                        onPressed: controller.isFormValid.value && !controller.isLoading.value
                            ? controller.resetPassword
                            : null,
                        isLoading: controller.isLoading.value,
                        width: double.infinity,
                        height: 56,
                        backgroundColor: controller.isFormValid.value && !controller.isLoading.value
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.3),
                        textColor: Colors.white,
                        borderRadius: 12,
                        icon: Icons.check_circle_outline_rounded,
                      )),

                      const SizedBox(height: 16),

                      // زر مسح النموذج
                      TextButton.icon(
                        onPressed: _clearForm,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'clear_form'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
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

  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'verification_code'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // حقل OTP
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PinCodeTextField(
              appContext: Get.context!,
              length: 6,
              controller: controller.otpController,
              errorAnimationController: controller.otpErrorController,
              animationType: AnimationType.scale,
              keyboardType: TextInputType.number,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),

              // تخصيص شكل الحقول
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
                fieldHeight: 56,
                fieldWidth: 42,

                // الحالة العادية
                inactiveColor: AppColors.textSecondary.withOpacity(0.3),
                inactiveFillColor: const Color(0xFFF9FAFB),

                // الحالة النشطة (عند التركيز)
                activeColor: AppColors.primary,
                activeFillColor: AppColors.primary.withOpacity(0.05),

                // الحالة المحددة (عند الكتابة)
                selectedColor: AppColors.primary,
                selectedFillColor: AppColors.primary.withOpacity(0.1),

                // حالة الخطأ
                errorBorderColor: const Color(0xFFEF4444),

                borderWidth: 2,
                disabledColor: AppColors.textSecondary.withOpacity(0.2),
              ),

              // تفعيل التعبئة
              enableActiveFill: true,

              // تفعيل التبديل التلقائي بين الحقول
              autoFocus: true,

              // إعدادات الكيبورد
              enablePinAutofill: true,
              useHapticFeedback: true,
              hapticFeedbackTypes: HapticFeedbackTypes.medium,

              // الأنيميشن عند إدخال الرقم
              animationDuration: const Duration(milliseconds: 300),

              // تخصيص لون المؤشر
              cursorColor: AppColors.primary,
              cursorWidth: 2,
              cursorHeight: 20,

              // عند تغيير النص
              onChanged: (value) {
                controller.onOtpChanged(value);
              },

              // عند إكمال الإدخال
              onCompleted: (value) {
                print("OTP مكتمل: $value");
                _showCompletionFeedback();
              },

              // قبل إدخال النص (للتحقق من صحة الإدخال)
              beforeTextPaste: (text) {
                if (text != null && text.length == 6) {
                  return RegExp(r'^[0-9]+$').hasMatch(text);
                }
                return false;
              },

              // إعدادات إضافية
              showCursor: true,
              blinkWhenObscuring: true,
              blinkDuration: const Duration(milliseconds: 600),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // رسالة الخطأ للـ OTP
        Obx(() => controller.hasOtpError.value
            ? Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFECACA),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.otpErrorText.value,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'new_password'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // حقل كلمة المرور الجديدة
        Obx(() => CustomTextField(
          controller: controller.newPasswordController,
          hintText: 'enter_new_password'.tr,
          prefixIcon: Icons.lock_outline,
          suffixIcon: controller.isNewPasswordVisible.value
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixTap: controller.toggleNewPasswordVisibility,
          isPassword: !controller.isNewPasswordVisible.value,
        )),

        const SizedBox(height: 16),

        // حقل تأكيد كلمة المرور
        Obx(() => CustomTextField(
          controller: controller.confirmNewPasswordController,
          hintText: 'confirm_new_password'.tr,
          prefixIcon: Icons.lock_outline,
          suffixIcon: controller.isConfirmNewPasswordVisible.value
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixTap: controller.toggleConfirmNewPasswordVisibility,
          isPassword: !controller.isConfirmNewPasswordVisible.value,
        )),

        const SizedBox(height: 8),

      ],
    );
  }

  Widget _buildResendSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'didnt_get_code'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => GestureDetector(
                onTap: controller.canResendOtp.value && !controller.isLoading.value
                    ? controller.resendOtp
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: controller.canResendOtp.value && !controller.isLoading.value
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'resend'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: controller.canResendOtp.value && !controller.isLoading.value
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => controller.otpTimer.value > 0
              ? Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFECACA),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: Color(0xFFEF4444),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${'expires_in'.tr} ${(controller.otpTimer.value ~/ 60).toString().padLeft(1, '0')}:${(controller.otpTimer.value % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  void _showCompletionFeedback() {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'otp_entered_completely'.tr,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.withOpacity(0.1),
      borderColor: Colors.green.withOpacity(0.3),
      borderWidth: 1,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  void _clearForm() {
    controller.clearAllForms();

    Get.snackbar(
      'form_cleared'.tr,
      'form_has_been_cleared'.tr,
      backgroundColor: Colors.blue.withOpacity(0.1),
      colorText: Colors.blue,
      snackPosition: SnackPosition.TOP,
    );
  }
}