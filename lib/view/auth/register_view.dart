import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/CustomButton.dart';
import '../../widgets/CustomTextField.dart';
import '../../widgets/CustomDropdownField.dart';

class SignUpView extends GetView<AuthController> {
  const SignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo
              _buildLogo(),

              // Title
              _buildTitle(),

              const SizedBox(height: 32),

              // Sign up form
              _buildSignUpForm(),

              const SizedBox(height: 16),

              // Terms and conditions
              _buildTermsAndConditions(),

              const SizedBox(height: 32),

              // Sign up button
              _buildSignUpButton(),

              const SizedBox(height: 24),

              // Login link
              _buildLoginLink(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/icons/khabir_logo.png',
      width: 230,
      height: 230,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTitle() {
    return Text(
      'create_an_account'.tr,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFFEF4444),
        letterSpacing: -0.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        // Full name field
        CustomTextField(
          controller: controller.nameController,
          hintText: 'enter_full_name'.tr,
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),

        const SizedBox(height: 16),

        // Email field
        CustomTextField(
          controller: controller.signupEmailController,
          hintText: 'enter_email_address'.tr,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        // Mobile number field
        CustomTextField(
          controller: controller.phoneController,
          hintText: 'enter_mobile_number'.tr,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 16),

        // State dropdown
        Obx(() => CustomDropdownField(
          hintText: 'choose_your_state'.tr,
          prefixIcon: Icons.public,
          items: controller.states,
          selectedValue: controller.selectedState.value,
          onChanged: controller.onStateChanged,
        )),

        const SizedBox(height: 16),

        // City dropdown
        Obx(() => CustomDropdownField(
          hintText: 'choose_your_city'.tr,
          prefixIcon: Icons.location_city,
          items: controller.availableCities,
          selectedValue: controller.selectedCity.value,
          onChanged: controller.onCityChanged,
          enabled: controller.selectedState.value != null,
        )),

        const SizedBox(height: 16),

        // Services dropdown
        // Obx(() => CustomDropdownField(
        //   hintText: 'choose_your_services'.tr,
        //   prefixIcon: Icons.build_outlined,
        //   items: controller.services,
        //   selectedValue: controller.selectedService.value,
        //   onChanged: controller.onServiceChanged,
        // )),

        const SizedBox(height: 16),

        // Password field
        Obx(() => CustomTextField(
          controller: controller.signupPasswordController,
          hintText: 'enter_password'.tr,
          prefixIcon: Icons.lock_outline,
          suffixIcon: controller.isPasswordVisible.value
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixTap: controller.togglePasswordVisibility,
          isPassword: !controller.isPasswordVisible.value,
        )),

        const SizedBox(height: 16),

        // Confirm password field
        Obx(() => CustomTextField(
          controller: controller.confirmPasswordController,
          hintText: 'confirm_your_password'.tr,
          prefixIcon: Icons.lock_outline,
          suffixIcon: controller.isConfirmPasswordVisible.value
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixTap: controller.toggleConfirmPasswordVisibility,
          isPassword: !controller.isConfirmPasswordVisible.value,
        )),

        const SizedBox(height: 16),

        // Description field
        CustomTextField(
          controller: controller.descriptionController,
          hintText: 'enter_description'.tr,
          prefixIcon: Icons.description_outlined,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
        ),

        const SizedBox(height: 16),

        // Photo upload field
        _buildPhotoUploadField(),
      ],
    );
  }

  Widget _buildPhotoUploadField() {
    return GestureDetector(
      onTap: () => controller.pickImage(type: 'profile'),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ),
            Expanded(
              child: Obx(() => Text(
                controller.selectedProfileImage.value != null
                    ? 'photo_selected'.tr
                    : 'choose_photo_upload'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: controller.selectedProfileImage.value != null
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              )),
            ),
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.upload_outlined,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Obx(() => Row(
      children: [
        GestureDetector(
          onTap: controller.toggleTermsAccepted,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: controller.isTermsAccepted.value
                  ? AppColors.primary
                  : Colors.transparent,
              border: Border.all(
                color: controller.isTermsAccepted.value
                    ? AppColors.primary
                    : const Color(0xFF9CA3AF),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: controller.isTermsAccepted.value
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF374151),
              ),
              children: [
                TextSpan(text: 'agree_terms_conditions'.tr),
                TextSpan(
                  text: 'terms'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                TextSpan(text: 'and'.tr),
                TextSpan(
                  text: 'conditions'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildSignUpButton() {
    return Obx(() => CustomButton(
      text: 'sign_up'.tr.toUpperCase(),
      onPressed: controller.register,
      isLoading: controller.isLoading.value,
      enabled: controller.isTermsAccepted.value,
      width: double.infinity,
      height: 56,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      borderRadius: 12,
    ));
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'have_account_already'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.LOGIN),
          child: Text(
            'log_in_link'.tr,
            style: AppTextStyles.linkText.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}