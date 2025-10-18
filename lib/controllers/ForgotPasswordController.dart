import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/PhoneHelper.dart';
import '../routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storageService = Get.find<StorageService>();

  // Controllers منفصلة تماماً
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  StreamController<ErrorAnimationType>? otpErrorController;

  // متغيرات reactive منفصلة تماماً
  var phoneText = ''.obs;
  var phoneError = ''.obs;
  var otpText = ''.obs;
  var newPasswordText = ''.obs;
  var confirmNewPasswordText = ''.obs;

  // حفظ رقم الهاتف المنسق للاستخدام في العمليات
  var formattedPhoneNumber = ''.obs;

  // حالات التحكم
  var isLoading = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmNewPasswordVisible = false.obs;
  var hasOtpError = false.obs;
  var otpErrorText = ''.obs;

  // Timer
  var otpTimer = 0.obs;
  var canResendOtp = true.obs;

  // حالة النموذج
  var isFormValid = false.obs;
  var isPhoneValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    otpErrorController = StreamController<ErrorAnimationType>();

    // Listeners منفصلة تماماً - استخدام الدالة العامة
    phoneController.addListener(onPhoneChanged);
    otpController.addListener(_onOtpChanged);
    newPasswordController.addListener(_onPasswordChanged);
    confirmNewPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void onClose() {
    super.onClose();
  }

  // معالجة تغيير رقم الهاتف - دالة عامة
  void onPhoneChanged() {
    String phone = phoneController.text;
    phoneText.value = phone;

    if (phone.isEmpty) {
      phoneError.value = '';
      isPhoneValid.value = false;
      formattedPhoneNumber.value = '';
      return;
    }

    // التحقق من صحة الرقم
    String? error = PhoneHelper.getPhoneErrorMessage(
        phone, Get.locale?.languageCode ?? 'ar');
    phoneError.value = error ?? '';
    isPhoneValid.value = error == null;

    // حفظ الرقم المنسق إذا كان صحيحاً
    if (error == null) {
      formattedPhoneNumber.value = _formatPhoneNumber(phone);
      print('Formatted phone number: ${formattedPhoneNumber.value}'); // للتتبع
    }

    // تحديث فوري للواجهة
    update();
  }

  // معالجة تغيير OTP
  void _onOtpChanged() {
    otpText.value = otpController.text;
    _validateForm();

    // مسح الخطأ عند بدء الكتابة
    if (hasOtpError.value) {
      hasOtpError.value = false;
      otpErrorText.value = '';
    }
  }

  // معالجة تغيير كلمة المرور
  void _onPasswordChanged() {
    newPasswordText.value = newPasswordController.text;
    confirmNewPasswordText.value = confirmNewPasswordController.text;
    _validateForm();
  }

  // التحقق من صحة النموذج
  void _validateForm() {
    isFormValid.value = otpText.value.length == 6 &&
        newPasswordText.value.length >= 6 &&
        confirmNewPasswordText.value.isNotEmpty &&
        newPasswordText.value == confirmNewPasswordText.value;
  }

  // إرسال رمز إعادة تعيين كلمة المرور
  Future<void> sendResetCode() async {
    if (!_validatePhone()) return;

    try {
      isLoading.value = true;

      // حفظ الرقم المنسق قبل الإرسال
      String phoneToSend = _formatPhoneNumber(phoneController.text.trim());
      formattedPhoneNumber.value = phoneToSend;

      print('Sending reset code to: $phoneToSend'); // للتتبع

      final response = await _authService.sendPasswordResetOtp(
        phoneNumber: phoneToSend,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'sent'.tr,
          'verification_code_sent'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _startOtpTimer();

        // حفظ رقم الهاتف في التخزين المؤقت للاستخدام في الصفحة التالية
        await _storageService.write('temp_phone_number', phoneToSend);

        Get.toNamed(AppRoutes.RESET_PASSWORD);
      } else {
        throw response['message'] ?? 'code_sending_failed'.tr;
      }
    } catch (e) {
      print('Error sending reset code: $e'); // للتتبع
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword() async {
    if (!_validateResetPassword()) return;

    try {
      isLoading.value = true;

      // التأكد من وجود رقم الهاتف المحفوظ
      String phoneToUse = formattedPhoneNumber.value;
      if (phoneToUse.isEmpty) {
        phoneToUse = await _storageService.read('temp_phone_number') ?? '';
      }

      if (phoneToUse.isEmpty) {
        throw 'phone_number_missing'.tr;
      }

      print('Reset password for: $phoneToUse with OTP: ${otpController.text.trim()}'); // للتتبع

      final response = await _authService.resetPassword(
        phoneNumber: phoneToUse,
        otp: otpController.text.trim(),
        newPassword: newPasswordController.text,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'success'.tr,
          'password_reset_success'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // مسح رقم الهاتف المؤقت
        await _storageService.remove('temp_phone_number');

        clearAllForms();
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        throw response['message'] ?? 'password_reset_failed'.tr;
      }
    } catch (e) {
      print('Error resetting password: $e'); // للتتبع
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة إرسال OTP
  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    try {
      isLoading.value = true;

      // الحصول على رقم الهاتف المحفوظ
      String phoneToUse = formattedPhoneNumber.value;
      if (phoneToUse.isEmpty) {
        phoneToUse = await _storageService.read('temp_phone_number') ?? '';
      }

      if (phoneToUse.isEmpty) {
        Get.snackbar(
          'error'.tr,
          'phone_number_missing_please_go_back'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      print('Resending OTP to: $phoneToUse'); // للتتبع

      final response = await _authService.sendPasswordResetOtp(
        phoneNumber: phoneToUse,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'sent'.tr,
          'verification_code_sent'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _startOtpTimer();
        clearOtp(); // مسح OTP السابق
      } else {
        throw response['message'] ?? 'code_sending_failed'.tr;
      }
    } catch (e) {
      print('Error resending OTP: $e'); // للتتبع
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // التحقق من OTP للانتقال (إذا كنت تريد صفحة منفصلة)
  void onOtpChanged(String value) {
    _onOtpChanged();

    // إظهار تأثير بصري عند اكتمال الرمز
    if (value.length == 6) {
      _showCompletionFeedback();
    }
  }

  // تحميل رقم الهاتف المحفوظ عند فتح صفحة إعادة التعيين
  Future<void> loadSavedPhoneNumber() async {
    if (formattedPhoneNumber.value.isEmpty) {
      String? savedPhone = await _storageService.read('temp_phone_number');
      if (savedPhone != null && savedPhone.isNotEmpty) {
        formattedPhoneNumber.value = savedPhone;
        print('Loaded saved phone number: $savedPhone'); // للتتبع
      }
    }
  }

  // التحقق من صحة الهاتف
  bool _validatePhone() {
    if (phoneController.text.trim().isEmpty) {
      _showError('please_enter_phone'.tr);
      return false;
    }

    String? error = PhoneHelper.getPhoneErrorMessage(
        phoneController.text, Get.locale?.languageCode ?? 'ar');

    if (error != null) {
      phoneError.value = error;
      _showError(error);
      return false;
    }

    return true;
  }

  // التحقق من صحة إعادة التعيين
  bool _validateResetPassword() {
    if (!_validateOtp()) return false;

    if (newPasswordController.text.isEmpty) {
      _showError('please_enter_new_password'.tr);
      return false;
    }

    if (newPasswordController.text.length < 6) {
      _showError('password_min_length'.tr);
      return false;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      _showError('password_mismatch'.tr);
      return false;
    }

    return true;
  }

  // التحقق من صحة OTP
  bool _validateOtp() {
    String otpValue = otpController.text.trim();

    hasOtpError.value = false;
    otpErrorText.value = '';

    if (otpValue.isEmpty) {
      _showOtpError('please_enter_verification_code'.tr);
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otpValue)) {
      _showOtpError('verification_code_numbers_only'.tr);
      return false;
    }

    if (otpValue.length != 6) {
      _showOtpError('verification_code_six_digits'.tr);
      return false;
    }

    return true;
  }

  // عرض خطأ OTP
  void _showOtpError(String message) {
    hasOtpError.value = true;
    otpErrorText.value = message;

    otpErrorController?.add(ErrorAnimationType.shake);

    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // عرض رسالة خطأ عامة
  void _showError(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // إظهار تأثير الإكمال
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

  // تشغيل Timer
  void _startOtpTimer() {
    canResendOtp.value = false;
    otpTimer.value = 60;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  // مسح الحقول
  void clearAllForms() {
    phoneController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();

    phoneText.value = '';
    phoneError.value = '';
    otpText.value = '';
    newPasswordText.value = '';
    confirmNewPasswordText.value = '';

    hasOtpError.value = false;
    otpErrorText.value = '';
    isFormValid.value = false;
    isPhoneValid.value = false;

    isNewPasswordVisible.value = false;
    isConfirmNewPasswordVisible.value = false;
    otpTimer.value = 0;
    canResendOtp.value = true;

    // لا نمسح formattedPhoneNumber هنا لأننا قد نحتاجه
  }

  // مسح OTP فقط
  void clearOtp() {
    otpController.clear();
    otpText.value = '';
    hasOtpError.value = false;
    otpErrorText.value = '';
    _validateForm();
  }

  // إدارة كلمات المرور
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmNewPasswordVisibility() {
    isConfirmNewPasswordVisible.value = !isConfirmNewPasswordVisible.value;
  }

  // تنسيق رقم الهاتف - محسن
  String _formatPhoneNumber(String phone) {
    // إزالة جميع المسافات والرموز
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    print('Original phone input: $phone'); // للتتبع

    // التحقق من الأنماط المختلفة وتنسيقها
    if (phone.startsWith('00968')) {
      // من 00968xxxxxxxx إلى +968xxxxxxxx
      return '+${phone.substring(2)}';
    } else if (phone.startsWith('968')) {
      // من 968xxxxxxxx إلى +968xxxxxxxx
      return '+$phone';
    } else if (phone.startsWith('9') && phone.length == 8) {
      // من 9xxxxxxx إلى +9689xxxxxxx
      return '+968$phone';
    } else if (phone.startsWith('0') && phone.length == 9) {
      // من 09xxxxxxxx إلى +9689xxxxxxx
      return '+968${phone.substring(1)}';
    } else if (phone.startsWith('+968') && phone.length == 12) {
      // الرقم صحيح بالفعل
      return phone;
    } else if (phone.length == 8 && phone.startsWith('7')) {
      // للأرقام التي تبدأ بـ 7 (نوع آخر من أرقام عُمان)
      return '+968$phone';
    } else if (!phone.startsWith('+')) {
      // إضافة كود البلد إذا لم يكن موجوداً
      return '+968$phone';
    }

    return phone;
  }
}