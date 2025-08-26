import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khabir/services/auth_service.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/dio_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storageService = Get.find<StorageService>();
  final DioService _dioService = DioService();

  // متحكمات النصوص
  final emailController = TextEditingController();
  final signupEmailController = TextEditingController();

  final passwordController = TextEditingController();
  final signupPasswordController = TextEditingController();


  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final descriptionController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // حالات التحكم
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs;
  var isConfirmNewPasswordVisible = false.obs;
  var rememberMe = false.obs;
  var isTermsAccepted = false.obs;
  var otpTimer = 0.obs;
  var canResendOtp = true.obs;
  var isAccountVerified = false.obs;
  var showSuccessDialog = false.obs;

  // القوائم المنسدلة
  final selectedState = Rx<String?>(null);
  // final selectedService = Rx<String?>(null);
  final selectedCity = Rx<String?>(null);

  // رفع الصور
  final ImagePicker _picker = ImagePicker();
  final selectedImage = Rx<XFile?>(null);
  final selectedProfileImage = Rx<XFile?>(null);
  final selectedIDImage = Rx<XFile?>(null);
  final selectedLicenseImage = Rx<XFile?>(null);

  // بيانات المستخدم
  var currentUser = Rxn<UserModel>();

  // متغير لتخزين بيانات التسجيل المؤقتة
  Map<String, dynamic> _registrationData = {};

  // قائمة المحافظات العمانية
  final List<String> states = [
    'مسقط',
    'شمال الباطنة',
    'جنوب الباطنة',
    'شمال الشرقية',
    'جنوب الشرقية',
    'الداخلية',
    'الظاهرة',
    'البريمي',
    'الوسطى',
    'ظفار',
    'مسندم',
  ];

  // قائمة المدن لكل محافظة في سلطنة عمان
  final Map<String, List<String>> citiesByState = {
    'مسقط': [
      'مسقط',
      'مطرح',
      'السيب',
      'بوشر',
      'العامرات',
      'قريات',
    ],
    'شمال الباطنة': [
      'صحار',
      'لوى',
      'شناص',
      'السويق',
      'الخابورة',
      'صحم',
    ],
    'جنوب الباطنة': [
      'الرستاق',
      'بركاء',
      'المصنعة',
      'العوابي',
      'وادي المعاول',
      'نخل',
    ],
    'شمال الشرقية': [
      'إبراء',
      'المضيبي',
      'القابل',
      'بدية',
      'وادي بني خالد',
      'دماء والطائيين',
    ],
    'جنوب الشرقية': [
      'صور',
      'الكامل والوافي',
      'جعلان بني بوحسن',
      'جعلان بني بوعلي',
      'مصيرة',
    ],
    'الداخلية': [
      'نزوى',
      'بهلاء',
      'الحمراء',
      'آدم',
      'منح',
      'سمائل',
      'إزكي',
      'بدبد',
    ],
    'الظاهرة': [
      'عبري',
      'ينقل',
      'ضنك',
    ],
    'البريمي': [
      'البريمي',
      'محضة',
      'السنينة',
    ],
    'الوسطى': [
      'هيما',
      'الجعلة',
      'الركبية',
      'الدقم',
      'محوت',
    ],
    'ظفار': [
      'صلالة',
      'مرباط',
      'طاقة',
      'سدح',
      'رخيوت',
      'ضلكوت',
      'مقشن',
      'ثمريت',
      'شليم وجزر الحلانيات',
    ],
    'مسندم': [
      'خصب',
      'دبا',
      'بخاء',
      'مدحاء',
    ],
  };

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  // تحقق من حالة تسجيل الدخول
  void _checkLoginStatus() {
    if (_storageService.isLoggedIn) {
      _loadUserData();
    }
  }

  // تحميل بيانات المستخدم
  void _loadUserData() {
    try {
      final userData = _storageService.userData;
      if (userData.isNotEmpty) {
        currentUser.value = UserModel.fromJson(userData);
        // تحديث الـ token في DioService
        _dioService.updateToken(_storageService.userToken);
      }
    } catch (e) {
      print('Error loading user data: $e');
      _storageService.clearUserSession();
    }
  }

  // تسجيل الدخول
  Future<void> login() async {
    if (!_validateLoginForm()) return;


    try {
      isLoading.value = true;

      // الحصول على FCM Token من التخزين المحلي
      final fcmToken = _storageService.getFCMToken();
      print('FCM Token for login: ${fcmToken.isNotEmpty ? fcmToken.substring(0, 20) + "..." : "Empty"}');

      // التحقق من حالة الحساب أولاً
      try {
        final statusResponse = await _authService.checkAccountStatus(
          email: emailController.text.trim(),
        );

        if (statusResponse['exists'] == false) {
          Get.snackbar(
            'خطأ',
            'الحساب غير موجود',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      } catch (e) {
        print('Check status error (continuing): $e');
      }

      // محاولة تسجيل الدخول مع FCM Token
      final response = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
        fcmToken: fcmToken.isNotEmpty ? fcmToken : null,
      );

      // حفظ البيانات
      final token = response['access_token'];
      final userData = response['user'];

      await _storageService.saveUserSession(
        token: token,
        user: userData,
        type: userData['role'] ?? 'PROVIDER',
        fcmToken: fcmToken,
      );

      // تحديث التوكن في DioService
      _dioService.updateToken(token);

      // تحديث المستخدم الحالي
      currentUser.value = UserModel.fromJson(userData);

      Get.snackbar(
        'تم بنجاح',
        'تم تسجيل الدخول بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      _clearForms();
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // التسجيل - الخطوة الأولى (إرسال البيانات وطلب OTP)
  Future<void> register() async {
    if (!_validateSignUpForm()) return;

    try {
      isLoading.value = true;

      // الحصول على FCM Token من التخزين المحلي
      final fcmToken = _storageService.getFCMToken();
      print('FCM Token for registration: ${fcmToken.isNotEmpty ? fcmToken.substring(0, 20) + "..." : "Empty"}');

      // تحضير بيانات التسجيل
      _registrationData = {
        'name': nameController.text.trim(),
        'email': signupEmailController.text.trim(),
        'password': signupPasswordController.text,
        'phoneNumber': _formatPhoneNumber(phoneController.text.trim()),
        'role': 'PROVIDER',
        'description': descriptionController.text.trim(),
        'address': '${selectedCity.value}, ${selectedState.value}',
        'state': selectedState.value ?? '',
        'city': selectedCity.value,
        // 'serviceType': selectedService.value,
        'fcmToken': fcmToken, // إضافة FCM Token للبيانات المؤقتة
      };

      // إرسال طلب بدء التسجيل مع FCM Token
      final response = await _authService.initiateRegistration(
        name: _registrationData['name'],
        email: _registrationData['email'],
        password: _registrationData['password'],
        phoneNumber: _registrationData['phoneNumber'],
        role: _registrationData['role'],
        description: _registrationData['description'],
        address: _registrationData['address'],
        state: _registrationData['state'],
        city: _registrationData['city'],
        // serviceType: _registrationData['serviceType'],
        fcmToken: fcmToken.isNotEmpty ? fcmToken : null,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'تم الإرسال',
          response['message'] ?? 'تم إرسال رمز التحقق',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _startAccountVerificationTimer();
        Get.toNamed(AppRoutes.VERIFY_ACCOUNT);
      } else {
        throw response['message'] ?? 'فشل في إرسال البيانات';
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // تأكيد الحساب - الخطوة الثانية
  Future<void> verifyAccount() async {
    if (!_validateOtp()) return;

    try {
      isLoading.value = true;

      final response = await _authService.completeRegistration(
        name: _registrationData['name'],
        email: _registrationData['email'],
        password: _registrationData['password'],
        phoneNumber: _registrationData['phoneNumber'],
        otp: otpController.text.trim(),
        role: _registrationData['role'],
        description: _registrationData['description'],
        address: _registrationData['address'],
        state: _registrationData['state'],
        city: _registrationData['city'],
        // serviceType: _registrationData['serviceType'],
        // fcmToken: _registrationData['fcmToken'], // إرسال FCM Token
      );

      // ✅ التحقق من كود الحالة (201 يعني تم إنشاء الحساب بنجاح)
      if (response['id'] != null) {
        isAccountVerified.value = true;

        Get.snackbar(
          'تم التحقق',
          response['message'] ?? 'تم إنشاء حسابك بنجاح، بانتظار موافقة الإدارة',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _clearForms();
        // ⚠️ بما أن الحساب بحاجة موافقة الإدارة، ما رح نعمل Login مباشر
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        throw response['message'] ?? 'حصل خطأ غير متوقع أثناء إنشاء الحساب';
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إرسال رمز إعادة تعيين كلمة المرور
  Future<void> sendResetCode() async {
    if (!_validatePhone()) return;

    try {
      isLoading.value = true;

      final response = await _authService.sendPasswordResetOtp(
        phoneNumber: _formatPhoneNumber(phoneController.text.trim()),
      );

      if (response['success'] == true) {
        Get.snackbar(
          'تم الإرسال',
          response['message'] ?? 'تم إرسال رمز التحقق',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _startOtpTimer();
        Get.toNamed(AppRoutes.VERIFY_OTP);
      } else {
        throw response['message'] ?? 'فشل في إرسال الرمز';
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // التحقق من رمز OTP
  Future<void> verifyOtpCode() async {
    if (!_validateOtp()) return;

    // للتطوير - الانتقال مباشرة لصفحة إعادة التعيين
    Get.toNamed(AppRoutes.RESET_PASSWORD);
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword() async {
    if (!_validateResetPassword()) return;

    try {
      isLoading.value = true;

      final response = await _authService.resetPassword(
        phoneNumber: _formatPhoneNumber(phoneController.text.trim()),
        otp: otpController.text.trim(),
        newPassword: newPasswordController.text,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'تم بنجاح',
          response['message'] ?? 'تم تغيير كلمة المرور بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _clearResetPasswordForms();
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        throw response['message'] ?? 'فشل في تغيير كلمة المرور';
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة إرسال رمز التحقق للتسجيل
  Future<void> resendAccountVerificationOtp() async {
    if (!canResendOtp.value || _registrationData.isEmpty) return;

    try {
      isLoading.value = true;

      final fcmToken = _storageService.getFCMToken();
      _registrationData['fcmToken'] = fcmToken;


      final response = await _authService.initiateRegistration(
        name: _registrationData['name'],
        email: _registrationData['email'],
        password: _registrationData['password'],
        phoneNumber: _registrationData['phoneNumber'],
        role: _registrationData['role'],
        description: _registrationData['description'],
        address: _registrationData['address'],
        state: _registrationData['state'],
        city: _registrationData['city'],
        serviceType: _registrationData['serviceType'],
        fcmToken: fcmToken.isNotEmpty ? fcmToken : null,

      );

      if (response['success'] == true) {
        Get.snackbar(
          'تم الإرسال',
          'تم إعادة إرسال رمز التحقق',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _startAccountVerificationTimer();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة إرسال OTP لإعادة تعيين كلمة المرور
  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    await sendResetCode();
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // مسح البيانات المحلية
      await _storageService.clearUserSession();
      _dioService.clearToken();
      currentUser.value = null;
      _clearForms();

      Get.snackbar(
        'تم',
        'تم تسجيل الخروج بنجاح',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed(AppRoutes.LOGIN);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper Methods
  String _formatPhoneNumber(String phone) {
    // تنسيق رقم الهاتف ليبدأ بـ +966 للسعودية أو +963 لسوريا
    if (phone.startsWith('0')) {
      return '+963${phone.substring(1)}';
    } else if (phone.startsWith('5') && phone.length == 9) {
      return '+966$phone';
    } else if (!phone.startsWith('+')) {
      return '+963$phone';
    }
    return phone;
  }

  // Validation Methods
  bool _validateLoginForm() {
    if (emailController.text.trim().isEmpty) {
      _showError('يرجى إدخال البريد الإلكتروني أو رقم الهاتف');
      return false;
    }

    String input = emailController.text.trim();
    bool isEmail = GetUtils.isEmail(input);
    bool isPhone = GetUtils.isPhoneNumber(input) && input.length >= 10;

    if (!isEmail && !isPhone) {
      _showError('يرجى إدخال بريد إلكتروني صحيح أو رقم هاتف صحيح');
      return false;
    }

    if (passwordController.text.isEmpty) {
      _showError('يرجى إدخال كلمة المرور');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return false;
    }

    return true;
  }

  bool _validateSignUpForm() {
    if (nameController.text.trim().isEmpty) {
      _showError('يرجى إدخال الاسم الكامل');
      return false;
    }

    if (nameController.text.trim().length < 2) {
      _showError('الاسم يجب أن يكون حرفين على الأقل');
      return false;
    }

    if (signupEmailController.text.trim().isEmpty) {
      _showError('يرجى إدخال البريد الإلكتروني');
      return false;
    }

    if (!GetUtils.isEmail(signupEmailController.text.trim())) {
      _showError('يرجى إدخال بريد إلكتروني صحيح');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      _showError('يرجى إدخال رقم الهاتف');
      return false;
    }

    if (phoneController.text.trim().length < 10) {
      _showError('رقم الهاتف يجب أن يكون 10 أرقام على الأقل');
      return false;
    }

    if (selectedState.value == null) {
      _showError('يرجى اختيار المنطقة');
      return false;
    }

    if (selectedCity.value == null) {
      _showError('يرجى اختيار المدينة');
      return false;
    }

    // if (selectedService.value == null) {
    //   _showError('يرجى اختيار نوع الخدمة');
    //   return false;
    // }

    if (signupPasswordController.text.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return false;
    }

    if (signupPasswordController.text != confirmPasswordController.text) {
      _showError('كلمة المرور غير متطابقة');
      return false;
    }

    if (!isTermsAccepted.value) {
      _showError('يرجى الموافقة على الشروط والأحكام');
      return false;
    }

    return true;
  }

  bool _validateOtp() {
    if (otpController.text.trim().isEmpty) {
      _showError('يرجى إدخال رمز التحقق');
      return false;
    }

    if (otpController.text.trim().length != 6) {
      _showError('رمز التحقق يجب أن يكون 6 أرقام');
      return false;
    }

    return true;
  }

  bool _validatePhone() {
    if (phoneController.text.trim().isEmpty) {
      _showError('يرجى إدخال رقم الهاتف');
      return false;
    }

    if (phoneController.text.trim().length < 10) {
      _showError('يرجى إدخال رقم هاتف صحيح');
      return false;
    }

    return true;
  }

  bool _validateResetPassword() {
    if (newPasswordController.text.isEmpty) {
      _showError('يرجى إدخال كلمة المرور الجديدة');
      return false;
    }

    if (newPasswordController.text.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return false;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      _showError('كلمة المرور غير متطابقة');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Timer Methods
  void _startAccountVerificationTimer() {
    canResendOtp.value = false;
    otpTimer.value = 120; // دقيقتان

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  void _startOtpTimer() {
    canResendOtp.value = false;
    otpTimer.value = 60; // دقيقة واحدة

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  // Form Management
  void _clearForms() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
    descriptionController.clear();
    otpController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    selectedState.value = null;
    selectedCity.value = null;
    // selectedService.value = null;
    selectedImage.value = null;
    selectedProfileImage.value = null;
    selectedIDImage.value = null;
    selectedLicenseImage.value = null;
    isTermsAccepted.value = false;
    isAccountVerified.value = false;
    otpTimer.value = 0;
    canResendOtp.value = true;
    _registrationData.clear();
  }

  void _clearResetPasswordForms() {
    phoneController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    isNewPasswordVisible.value = false;
    isConfirmNewPasswordVisible.value = false;
    otpTimer.value = 0;
    canResendOtp.value = true;
  }

  // Image Management
  Future<void> pickImage({String type = 'profile'}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        switch (type) {
          case 'profile':
            selectedProfileImage.value = image;
            break;
          case 'id':
            selectedIDImage.value = image;
            break;
          case 'license':
            selectedLicenseImage.value = image;
            break;
          default:
            selectedImage.value = image;
        }

        Get.snackbar(
          'تم اختيار الصورة',
          'تم اختيار الصورة بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء اختيار الصورة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Dropdown Management
  void onStateChanged(String? value) {
    selectedState.value = value;
    selectedCity.value = null;
  }

  void onCityChanged(String? value) {
    selectedCity.value = value;
  }

  // void onServiceChanged(String? value) {
  //   selectedService.value = value;
  // }

  List<String> get availableCities {
    if (selectedState.value == null) return [];
    return citiesByState[selectedState.value] ?? [];
  }

  // UI State Management
  void toggleTermsAccepted() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmNewPasswordVisibility() {
    isConfirmNewPasswordVisible.value = !isConfirmNewPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Utility Methods
  bool get isTokenValid {
    final token = _storageService.userToken;
    if (token.isEmpty) return false;
    return true;
  }

  Future<void> updateUserData(Map<String, dynamic> newData) async {
    try {
      final currentData = _storageService.userData;
      final updatedData = {...currentData, ...newData};

      _storageService.userData = updatedData;
      currentUser.value = UserModel.fromJson(updatedData);
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    signupPasswordController.dispose();

    nameController.dispose();
    signupEmailController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    descriptionController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }
}
