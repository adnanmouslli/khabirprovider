import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/CustomButton.dart';
import '../../widgets/CustomTextField.dart';

class LoginView extends GetView<AuthController> {
  final AuthController controller = Get.put(AuthController());

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
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEF4444), // Red color matching the design
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Login to continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFEF4444), // Red color matching the design
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Mobile number field
        CustomTextField(
          controller: controller.emailController,
          hintText: 'Enter your mobile number',
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 20),

        // Password field
        Obx(() => CustomTextField(
          controller: controller.passwordController,
          hintText: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          suffixIcon: controller.isPasswordVisible.value
              ? Icons.visibility_off
              : Icons.visibility,
          // onSuffixTap: controller.togglePasswordVisibility,
          isPassword: !controller.isPasswordVisible.value,
        )),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Get.toNamed(AppRoutes.FORGOT_PASSWORD);
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFEF4444), // Red color matching the design
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444), // Red color matching the design
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
            : const Text(
          'LOG IN',
          style: TextStyle(
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
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.REGISTER),
          child: const Text(
            'Sign up now',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEF4444), // Red color matching the design
            ),
          ),
        ),
      ],
    );
  }
}