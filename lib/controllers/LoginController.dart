import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/dio_service.dart';
import '../routes/app_routes.dart';

class LoginController extends GetxController {
  // Services
    final AuthService _authService = AuthService();
  final StorageService _storageService = Get.find<StorageService>();
  final DioService _dioService = DioService();

  // Text Controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable Variables
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }

  @override
  void onClose() {

    super.onClose();
  }

  /// إعداد المستمعين للحقول لإزالة رسائل الخطأ عند الكتابة
  void _setupListeners() {
    phoneController.addListener(() {
      if (phoneError.value.isNotEmpty) {
        phoneError.value = '';
      }
    });

    passwordController.addListener(() {
      if (passwordError.value.isNotEmpty) {
        passwordError.value = '';
      }
    });
  }

  /// تبديل إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// التحقق من رقم الهاتف
  bool _validatePhone() {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      phoneError.value = 'phone_required'.tr;
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      phoneError.value = 'phone_numbers_only'.tr;
      return false;
    }

    if (phone.length < 8) {
      phoneError.value = 'phone_invalid_length'.tr;
      return false;
    }

    if (phone.length > 8) {
      phoneError.value = 'phone_max_length'.tr;
      return false;
    }

    phoneError.value = '';
    return true;
  }

  /// التحقق من كلمة المرور
  bool _validatePassword() {
    final password = passwordController.text;

    if (password.isEmpty) {
      passwordError.value = 'password_required'.tr;
      return false;
    }

    if (password.length < 6) {
      passwordError.value = 'password_min_length'.tr;
      return false;
    }

    passwordError.value = '';
    return true;
  }

  /// التحقق من جميع الحقول
  bool validateForm() {
    final isPhoneValid = _validatePhone();
    final isPasswordValid = _validatePassword();

    return isPhoneValid && isPasswordValid;
  }

  /// تنسيق رقم الهاتف
  String _formatPhoneNumber(String phone) {
    // إزالة أي مسافات أو رموز
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // إضافة رمز الدولة إذا لم يكن موجوداً
    if (!phone.startsWith('968')) {
      phone = '968$phone';
    }
    
    return phone;
  }

  /// تسجيل الدخول
  Future<void> login() async {
    // إخفاء لوحة المفاتيح
    FocusManager.instance.primaryFocus?.unfocus();

    // التحقق من صحة البيانات
    if (!validateForm()) {
      return;
    }

    try {
      isLoading.value = true;

      // الحصول على FCM Token
      final fcmToken = _storageService.getFCMToken();
      
      if (fcmToken.isNotEmpty) {
        print('FCM Token: ${fcmToken.substring(0, 20)}...');
      } else {
        print('Warning: FCM Token is empty');
      }

      // تنسيق رقم الهاتف
      final phone = _formatPhoneNumber(phoneController.text.trim());
      final password = passwordController.text;

      print('Attempting login with phone: $phone');

      // إرسال طلب تسجيل الدخول
      final response = await _authService.login(
        phone: phone,
        password: password,
        fcmToken: fcmToken.isNotEmpty ? fcmToken : null,
      );

      // التحقق من الاستجابة
      if (response == null) {
        throw Exception('empty_response'.tr);
      }

      // استخراج البيانات
      final token = response['access_token'] ?? response['token'];
      final userData = response['user'] ?? response['data'];

      if (token == null || token.isEmpty) {
        throw Exception('invalid_token'.tr);
      }

      if (userData == null) {
        throw Exception('invalid_user_data'.tr);
      }

      print('Login successful - Token received');

      // حفظ بيانات الجلسة
      await _storageService.saveUserSession(
        token: token,
        user: userData,
        type: userData['role'] ?? 'PROVIDER',
        fcmToken: fcmToken,
      );

      // تحديث Token في DioService
      _dioService.updateToken(token);

      // عرض رسالة النجاح
      _showSuccessMessage('login_success'.tr);

      // مسح الحقول
      _clearForm();

      // الانتقال إلى الصفحة الرئيسية
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.HOME);

    } on Exception catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(Exception(e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  /// معالجة الأخطاء
  void _handleError(Exception error) {
    String errorMessage;
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('invalid credentials') || 
        errorString.contains('wrong password') ||
        errorString.contains('incorrect password')) {
      errorMessage = 'invalid_credentials'.tr;
    } else if (errorString.contains('user not found') || 
               errorString.contains('account not found')) {
      errorMessage = 'account_not_found'.tr;
    } else if (errorString.contains('network') || 
               errorString.contains('connection')) {
      errorMessage = 'network_error'.tr;
    } else if (errorString.contains('timeout')) {
      errorMessage = 'connection_timeout'.tr;
    } else if (errorString.contains('server error') || 
               errorString.contains('500')) {
      errorMessage = 'server_error'.tr;
    } else if (errorString.contains('account disabled') || 
               errorString.contains('account suspended')) {
      errorMessage = 'account_disabled'.tr;
    } else {
      errorMessage = error.toString().replaceAll('Exception: ', '');
    }

    _showErrorMessage(errorMessage);
  }

  /// عرض رسالة خطأ
  void _showErrorMessage(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  /// عرض رسالة نجاح
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  /// مسح النموذج
  void _clearForm() {
    phoneController.clear();
    passwordController.clear();
    phoneError.value = '';
    passwordError.value = '';
    isPasswordVisible.value = false;
  }

  /// الانتقال إلى صفحة نسيت كلمة المرور
  void goToForgotPassword() {
    Get.toNamed(AppRoutes.FORGOT_PASSWORD);
  }

  /// الانتقال إلى صفحة التسجيل
  void goToRegister() {
    Get.toNamed(AppRoutes.REGISTER);
  }

  /// التحقق التلقائي عند الضغط على حقل آخر
  void onPhoneFieldSubmitted() {
    _validatePhone();
  }

  void onPasswordFieldSubmitted() {
    _validatePassword();
    if (validateForm()) {
      login();
    }
  }
}