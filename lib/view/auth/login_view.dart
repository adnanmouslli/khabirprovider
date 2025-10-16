import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/controllers/LoginController.dart';
import '../../utils/colors.dart';
import '../../widgets/CustomTextField.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

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
              const SizedBox(height: 60),

              // Logo
              _buildLogo(),

              const SizedBox(height: 10),

              // Welcome text
              _buildWelcomeText(),

              const SizedBox(height: 40),

              // Login form
              _buildLoginForm(),

              const SizedBox(height: 16),

              // Forgot password
              _buildForgotPassword(),

              const SizedBox(height: 40),

              // Login button
              _buildLoginButton(),

              const SizedBox(height: 24),

              // Sign up link
              _buildSignUpLink(),

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

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'welcome_back'.tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEF4444),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'login_to_continue'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFEF4444),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          // Phone field
          _buildPhoneField(),

          const SizedBox(height: 20),

          // Password field
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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

                // Phone number input
                Expanded(
                  child: TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    maxLength: 8,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => controller.onPhoneFieldSubmitted(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'enter_mobile_number'.tr,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Error message
        Obx(() {
          if (controller.phoneError.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8, right: 4, left: 4),
            child: Text(
              controller.phoneError.value,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => CustomTextField(
          controller: controller.passwordController,
          hintText: 'enter_password'.tr,
          prefixIcon: Icons.lock_outline,
          suffixIcon: controller.isPasswordVisible.value 
              ? Icons.visibility_off
              : Icons.visibility,
          onSuffixTap: controller.togglePasswordVisibility,
          isPassword: !controller.isPasswordVisible.value,
          onSubmitted: (_) => controller.onPasswordFieldSubmitted(),
        )),
        
        // Error message
        Obx(() {
          if (controller.passwordError.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8, right: 4, left: 4),
            child: Text(
              controller.passwordError.value,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: controller.goToForgotPassword,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'forgot_password'.tr,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFEF4444),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFFEF4444).withOpacity(0.6),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          'log_in'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      )),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'dont_have_account'.tr + ' ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        GestureDetector(
          onTap: controller.goToRegister,
          child: Text(
            'sign_up_now'.tr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }
}