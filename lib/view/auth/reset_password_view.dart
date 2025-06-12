import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/CustomButton.dart';
import '../../widgets/CustomTextField.dart';

class ResetPasswordView extends GetView<AuthController> {
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
          'Reset password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Description
              const Text(
                'Enter a new password and\ndon\'t forget it',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // New password field
              Obx(() => CustomTextField(
                controller: controller.newPasswordController,
                hintText: 'Enter new password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: controller.isNewPasswordVisible.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                onSuffixTap: controller.toggleNewPasswordVisibility,
                isPassword: !controller.isNewPasswordVisible.value,
              )),

              const SizedBox(height: 16),

              // Confirm new password field
              Obx(() => CustomTextField(
                controller: controller.confirmNewPasswordController,
                hintText: 'Confirm new password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: controller.isConfirmNewPasswordVisible.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                onSuffixTap: controller.toggleConfirmNewPasswordVisibility,
                isPassword: !controller.isConfirmNewPasswordVisible.value,
              )),

              const SizedBox(height: 40),

              // Submit button
              Obx(() => CustomButton(
                text: 'Submit',
                onPressed: controller.resetPassword,
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
}