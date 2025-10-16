import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ForgotPasswordController.dart';
import '../../utils/colors.dart';
import '../../widgets/CustomButton.dart';
import '../../widgets/PhoneField.dart'; // استيراد القالب الجديد

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

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
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // أيقونة الهاتف
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Icon(
                          Icons.smartphone_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'forgot_your_password'.tr,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'forgot_password_description'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Phone number field using the new PhoneField widget
                      Obx(() => PhoneField(
                        controller: controller.phoneController,
                        hintText: 'enter_mobile_number'.tr,
                        errorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
                        onChanged: (value) {
                          // سيتم التعامل مع التغيير في ForgotPasswordController
                          // controller.onPhoneChanged() يتم استدعاؤه تلقائياً من خلال listener
                        },
                        showValidIcon: true,
                        enabled: !controller.isLoading.value,
                      )),

                      const SizedBox(height: 16),

                      // Debug info (يمكنك إزالة هذا القسم في الإنتاج)
                      if (controller.formattedPhoneNumber.value.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Obx(() => Text(
                            'Formatted: ${controller.formattedPhoneNumber.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          )),
                        ),

                      const SizedBox(height: 16),

                      // Send button
                      Obx(() => CustomButton(
                        text: 'send'.tr,
                        onPressed: controller.sendResetCode,
                        isLoading: controller.isLoading.value,
                        width: double.infinity,
                        height: 56,
                        backgroundColor: AppColors.primary,
                        textColor: Colors.white,
                        borderRadius: 12,
                        icon: Icons.send_rounded,
                      )),

                      const SizedBox(height: 16),
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
}