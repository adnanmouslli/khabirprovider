import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/widgets/CustomMultiSelectDropdown.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Widget _buildPhoneField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            // Country code section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/oman_flag.png',
                    width: 30,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 20,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Center(
                          child: Text(
                            'OM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '+968',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),

            // Phone number input section
            Expanded(
              child: TextField(
                controller: controller.signupPhoneController, // تغيير هنا
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w400,
                ),
                onChanged: (value) {
                  // التعامل مع التغيير سيتم في AuthController تلقائياً
                },
                decoration: InputDecoration(
                  hintText: 'enter_mobile_number'.tr,
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: controller.signupPhoneController.text.isNotEmpty &&
                      controller.phoneError.value.isEmpty
                      ? const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 20,
                  )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      children: [
        // Full name field
        CustomTextField(
          controller: controller.signupNameController, // تغيير هنا
          hintText: 'enter_full_name'.tr,
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),

        const SizedBox(height: 16),

        // Mobile number field
        Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhoneField(),
            if (controller.phoneError.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: Text(
                  controller.phoneError.value,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        )),

        const SizedBox(height: 16),

        // Governorate dropdown
        Obx(() => CustomDropdownField(
          hintText:
          controller.isArabic ? 'اختر المحافظة' : 'Choose Governorate',
          prefixIcon: Icons.location_city_outlined,
          items: controller.availableGovernorates,
          selectedValue: controller.selectedGovernorate.value != null
              ? (controller.isArabic
              ? controller.omanStates.firstWhere((gov) =>
          gov['value'] ==
              controller
                  .selectedGovernorate.value)['governorate']['ar']
              : controller.omanStates.firstWhere((gov) =>
          gov['value'] ==
              controller
                  .selectedGovernorate.value)['governorate']['en'])
              : null,
          onChanged: (value) {
            if (value != null) {
              final governorateValue =
              controller.getGovernorateValueFromLabel(value);
              controller.onGovernorateChanged(governorateValue);
            }
          },
        )),

        const SizedBox(height: 16),

        // State dropdown
        Obx(() => CustomDropdownField(
          hintText: controller.isArabic ? 'اختر الولاية' : 'Choose State',
          prefixIcon: Icons.location_on_outlined,
          items: controller.availableStates,
          selectedValue: controller.selectedState.value != null &&
              controller.selectedGovernorate.value != null
              ? (controller.isArabic
              ? controller.omanStates
              .firstWhere((gov) =>
          gov['value'] ==
              controller.selectedGovernorate.value)['states']
              .firstWhere((state) =>
          state['value'] == controller.selectedState.value)['label']
          ['ar']
              : controller.omanStates
              .firstWhere((gov) => gov['value'] == controller.selectedGovernorate.value)['states']
              .firstWhere((state) => state['value'] == controller.selectedState.value)['label']['en'])
              : null,
          onChanged: (value) {
            if (value != null) {
              final stateValue = controller.getStateValueFromLabel(value);
              controller.onStateChanged(stateValue);
            }
          },
          enabled: controller.selectedGovernorate.value != null,
        )),

        const SizedBox(height: 16),

        // Categories selection
        _buildCategoriesSection(),

        const SizedBox(height: 16),

        // Password field - تحديث للمتحكمات الجديدة
        Obx(() => CustomTextField(
          controller: controller.signupPasswordController, // تغيير هنا
          hintText: 'enter_password'.tr,
          prefixIcon: Icons.lock_outline,
          suffixIcon: controller.isSignupPasswordVisible.value // تغيير هنا
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixTap: controller.toggleSignupPasswordVisibility, // تغيير هنا
          isPassword: !controller.isSignupPasswordVisible.value, // تغيير هنا
        )),

        const SizedBox(height: 16),

        // Confirm password field - تحديث للمتحكمات الجديدة
        Obx(() => CustomTextField(
          controller: controller.signupConfirmPasswordController, // تغيير هنا
          hintText: 'confirm_your_password'.tr,
          prefixIcon: Icons.lock_outline,
          suffixIcon: controller.isSignupConfirmPasswordVisible.value // تغيير هنا
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixTap: controller.toggleSignupConfirmPasswordVisibility, // تغيير هنا
          isPassword: !controller.isSignupConfirmPasswordVisible.value, // تغيير هنا
        )),

        const SizedBox(height: 16),

        // Description field
        CustomTextField(
          controller: controller.signupDescriptionController, // تغيير هنا
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

  Widget _buildCategoriesSection() {
    return Obx(() {
      // If no governorate is selected
      if (controller.selectedGovernorate.value == null) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.isArabic
                      ? 'يرجى اختيار المحافظة والولاية أولاً لعرض الفئات المتاحة'
                      : 'Please select governorate and state first to view available categories',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // If governorate is selected but no state
      if (controller.selectedState.value == null) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.isArabic
                      ? 'يرجى اختيار الولاية لعرض الفئات المتاحة'
                      : 'Please select a state to view available categories',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // If no categories are available in the selected state
      if (controller.filteredCategories.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_outlined,
                    color: Colors.orange[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      controller.isArabic
                          ? 'لا توجد فئات متاحة في هذه الولاية حالياً'
                          : 'No categories available in this state currently',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                controller.isArabic
                    ? 'يرجى اختيار ولاية أخرى أو المحاولة لاحقاً'
                    : 'Please select another state or try again later',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }

      // Display categories using CustomMultiSelectDropdown
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                color: const Color(0xFFEF4444),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                controller.isArabic
                    ? 'اختر الفئات التي تقدمها'
                    : 'Select categories you provide',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: const Color(0xFFEF4444),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // CustomMultiSelectDropdown for categories
          CustomMultiSelectDropdown(
            hintText: controller.isArabic
                ? 'اختر الفئات المطلوبة'
                : 'Select required categories',
            prefixIcon: Icons.category_outlined,
            items: controller.filteredCategories,
            selectedItems: controller.selectedCategories.toList(),
            onChanged: (selectedItems) {
              controller.updateSelectedCategories(
                  List<Map<String, dynamic>>.from(selectedItems));
              controller.selectedCategories.refresh();
            },
            enabled: controller.filteredCategories.isNotEmpty,
            itemBuilder: (category) {
              final isArabic = controller.isArabic;
              return isArabic
                  ? (category['titleAr'] ?? category['titleEn'] ?? 'غير محدد')
                  : (category['titleEn'] ??
                  category['titleAr'] ??
                  'Not specified');
            },
          ),
        ],
      );
    });
  }

  Widget _buildSignUpButton() {
    return Obx(() => CustomButton(
      text: 'sign_up'.tr.toUpperCase(),
      onPressed: controller.register,
      isLoading: controller.isSignupLoading.value, // تغيير هنا
      enabled: controller.isTermsAccepted.value &&
          controller.selectedCategories.isNotEmpty,
      width: double.infinity,
      height: 56,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      borderRadius: 12,
    ));
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                TextSpan(text: 'agree_to'.tr),
                const TextSpan(text: ' '),

                // رابط الشروط والأحكام
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => controller.openTermsAndConditions(),
                    child: Obx(() => Text(
                      controller.termsStatusText,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: controller.hasTermsUrl
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF9CA3AF),
                        decoration: controller.hasTermsUrl
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    )),
                  ),
                ),

                TextSpan(text: ' ${'and'.tr} '),

                // رابط سياسة الخصوصية
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => controller.openPrivacyPolicy(),
                    child: Obx(() => Text(
                      controller.privacyStatusText,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: controller.hasPrivacyUrl
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF9CA3AF),
                        decoration: controller.hasPrivacyUrl
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
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