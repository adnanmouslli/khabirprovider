import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // متحكمات النصوص
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final descriptionController = TextEditingController(); // جديد
  final otpController = TextEditingController(); // جديد لرمز التحقق
  final newPasswordController = TextEditingController(); // جديد لكلمة المرور الجديدة
  final confirmNewPasswordController = TextEditingController(); // جديد لتأكيد كلمة المرور الجديدة


  // حالات التحكم
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs; // جديد
  var isConfirmNewPasswordVisible = false.obs; // جديد
  var rememberMe = false.obs;
  var isTermsAccepted = false.obs; // جديد
  var otpTimer = 0.obs; // جديد لمؤقت OTP
  var canResendOtp = true.obs; // جديد لحالة إعادة الإرسال
  var isAccountVerified = false.obs; // جديد لحالة تأكيد الحساب
  var showSuccessDialog = false.obs; // جديد لإظهار dialog النجاح


  // القوائم المنسدلة - جديد
  final selectedState = Rx<String?>(null);
  final selectedService = Rx<String?>(null);
  final selectedCity = Rx<String?>(null); // إضافة المدينة

  // رفع الصور - جديد
  final ImagePicker _picker = ImagePicker();
  final selectedImage = Rx<XFile?>(null);
  final selectedProfileImage = Rx<XFile?>(null);
  final selectedIDImage = Rx<XFile?>(null);
  final selectedLicenseImage = Rx<XFile?>(null);

  // بيانات المستخدم
  var currentUser = Rxn<UserModel>();

  // قوائم البيانات - المحافظات السورية
  final List<String> states = [
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'إدلب',
    'الحسكة',
    'دير الزور',
    'الرقة',
    'درعا',
    'السويداء',
    'القنيطرة',
    'طرطوس',
  ];

  final List<String> services = [
    'صيانة السيارات العامة',
    'كهربائي سيارات',
    'ميكانيكي محركات',
    'فني تكييف سيارات',
    'فني فرامل',
    'فني إطارات',
    'فني بطاريات',
    'فني زيوت ومشحمات',
    'غسيل وتنظيف سيارات',
    'دهان وصبغ سيارات',
    'تصليح جلد وقماش',
    'فني زجاج سيارات',
    'خدمات طوارئ',
    'نقل وسحب سيارات',
    'فحص دوري',
    'أخرى',
  ];

  // قائمة المدن لكل محافظة سورية
  final Map<String, List<String>> citiesByState = {
    'دمشق': ['دمشق', 'باب توما', 'القصاع', 'المزة', 'كفر سوسة', 'جرمانا', 'عربين', 'حرستا', 'سقبا', 'زملكا'],
    'ريف دمشق': ['دوما', 'داريا', 'الزبداني', 'يبرود', 'التل', 'صيدنايا', 'معلولا', 'النبك', 'قطنا', 'قدسيا', 'عرطوز', 'بلودان', 'مضايا'],
    'حلب': ['حلب', 'أعزاز', 'جرابلس', 'الباب', 'منبج', 'عفرين', 'عين العرب', 'تل رفعت', 'مارع', 'اخترين', 'الراعي'],
    'حمص': ['حمص', 'تدمر', 'القريتين', 'الرستن', 'تلبيسة', 'المخرم', 'تلدو', 'الفرقلس', 'صدد', 'الحولة'],
    'حماة': ['حماة', 'السلمية', 'مصياف', 'محردة', 'كفر زيتا', 'سقيلبية', 'خان شيخون', 'السقيلبية', 'قلعة المضيق'],
    'اللاذقية': ['اللاذقية', 'جبلة', 'القرداحة', 'الحفة', 'كسب', 'صلنفة', 'بانياس', 'عين البيضا'],
    'إدلب': ['إدلب', 'جسر الشغور', 'أريحا', 'معرة النعمان', 'سراقب', 'كفر نبل', 'خان شيخون', 'حارم', 'سلقين'],
    'الحسكة': ['الحسكة', 'القامشلي', 'رأس العين', 'المالكية', 'عامودا', 'تل تمر', 'المعبدة', 'الشدادة'],
    'دير الزور': ['دير الزور', 'البوكمال', 'الميادين', 'الأشارة', 'التيم', 'الصور', 'الجعفرة'],
    'الرقة': ['الرقة', 'تل أبيض', 'الثورة', 'الكرامة', 'صلوك', 'المعدان', 'الرصافة'],
    'درعا': ['درعا', 'الصنمين', 'إزرع', 'نوى', 'جاسم', 'طفس', 'الشيخ مسكين', 'بصرى الشام', 'انخل'],
    'السويداء': ['السويداء', 'شهبا', 'صلخد', 'الكرك الشرقي', 'عرى', 'ظهر الجبل', 'القريا', 'شقا'],
    'القنيطرة': ['القنيطرة', 'فيق', 'الخان الأحمر', 'جباتا الخشب', 'مسعدة', 'عين زيوان'],
    'طرطوس': ['طرطوس', 'بانياس', 'صافيتا', 'دريكيش', 'الشيخ بدر', 'قدموس', 'الحميدية', 'الصفصافة'],
  };

  @override
  void onInit() {
    super.onInit();
    // تحقق من حالة تسجيل الدخول
    _checkLoginStatus();
  }

  // تحقق من حالة تسجيل الدخول
  void _checkLoginStatus() {
    if (_storageService.isLoggedIn) {
      // إذا كان المستخدم مسجل دخول، حمل بياناته
      _loadUserData();
    }
  }

  // تحميل بيانات المستخدم
  void _loadUserData() {
    try {
      final userData = _storageService.userData;
      if (userData.isNotEmpty) {
        currentUser.value = UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user data: $e');
      // في حالة خطأ في تحميل البيانات، امسح الجلسة
      _storageService.clearUserSession();
    }
  }

  // تسجيل الدخول
  Future<void> login() async {
    if (!_validateLoginForm()) return;

    Get.offAllNamed(AppRoutes.HOME);

    return ;
    try {
      isLoading.value = true;

      final response = await _apiService.post(
        ApiService.LOGIN,
        body: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );

      if (response.body['success'] == true) {
        final userData = response.body['data'];
        final token = response.body['token'];

        // حفظ البيانات باستخدام دالة saveUserSession المحسنة
        await _storageService.saveUserSession(
          token: token,
          user: userData,
          type: userData['user_type'] ?? 'user', // افتراضي إذا لم يحدد
        );

        // تحديث المستخدم الحالي
        currentUser.value = UserModel.fromJson(userData);

        // إظهار رسالة نجاح
        Get.snackbar(
          'تم بنجاح',
          'تم تسجيل الدخول بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // مسح النماذج
        _clearForms();

        // الانتقال للصفحة الرئيسية
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        // في حالة عدم نجاح الاستجابة
        final message = response.body['message'] ?? 'فشل في تسجيل الدخول';
        Get.snackbar(
          'خطأ',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'خطأ',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Login error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // التسجيل المحدث مع الحقول الجديدة
  Future<void> register() async {
    if (!_validateSignUpForm()) return;

    try {
      isLoading.value = true;

      // إعداد بيانات التسجيل
      Map<String, dynamic> registerData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
        'user_type': _storageService.userType.isNotEmpty
            ? _storageService.userType
            : 'provider', // افتراضي مقدم خدمة
        'state': selectedState.value ?? '',
        'city': selectedCity.value ?? '',
        'service_type': selectedService.value ?? '',
        'description': descriptionController.text.trim(),
      };

      final response = await _apiService.post(
        ApiService.REGISTER,
        body: registerData,
        // files: _prepareImageFiles(),
      );

      if (response.body['success'] == true) {
        Get.snackbar(
          'تم بنجاح',
          'تم إنشاء الحساب بنجاح، يرجى تأكيد الحساب',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // بدء مؤقت OTP للتحقق من الحساب
        _startAccountVerificationTimer();

        // الانتقال لصفحة تأكيد الحساب
        Get.toNamed(AppRoutes.VERIFY_ACCOUNT);
      } else {
        final message = response.body['message'] ?? 'فشل في إنشاء الحساب';
        Get.snackbar(
          'خطأ',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'خطأ',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Register error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // تأكيد الحساب - دالة جديدة
  Future<void> verifyAccount() async {
    if (otpController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رمز التحقق',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (otpController.text.trim().length != 4) {
      Get.snackbar(
        'خطأ',
        'رمز التحقق يجب أن يكون 4 أرقام',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _apiService.post(
        ApiService.VERIFY_ACCOUNT,
        body: {
          'phone': phoneController.text.trim(),
          'otp': otpController.text.trim(),
        },
      );

      if (response.body['success'] == true) {
        isAccountVerified.value = true;

        Get.snackbar(
          'تم التحقق',
          'تم تأكيد حسابك بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // مسح النماذج
        _clearForms();

        // الانتقال لصفحة تسجيل الدخول
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        final message = response.body['message'] ?? 'رمز التحقق غير صحيح';
        Get.snackbar(
          'خطأ',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'خطأ',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Verify account error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة إرسال رمز تأكيد الحساب - دالة جديدة
  Future<void> resendAccountVerificationOtp() async {
    if (!canResendOtp.value) return;

    try {
      isLoading.value = true;

      final response = await _apiService.post(
        ApiService.RESEND_ACCOUNT_VERIFICATION,
        body: {
          'phone': phoneController.text.trim(),
        },
      );

      if (response.body['success'] == true) {
        Get.snackbar(
          'تم الإرسال',
          'تم إعادة إرسال رمز التحقق',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // بدء مؤقت إعادة الإرسال
        _startAccountVerificationTimer();
      } else {
        final message = response.body['message'] ?? 'فشل في إعادة إرسال الرمز';
        Get.snackbar(
          'خطأ',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('Resend account verification OTP error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في إعادة الإرسال',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // بدء مؤقت تأكيد الحساب - دالة جديدة
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

  // إعداد ملفات الصور للرفع
  Map<String, XFile> _prepareImageFiles() {
    Map<String, XFile> files = {};

    if (selectedProfileImage.value != null) {
      files['profile_image'] = selectedProfileImage.value!;
    }
    if (selectedIDImage.value != null) {
      files['id_image'] = selectedIDImage.value!;
    }
    if (selectedLicenseImage.value != null) {
      files['license_image'] = selectedLicenseImage.value!;
    }

    return files;
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // محاولة إرسال طلب تسجيل الخروج للسيرفر
      try {
        await _apiService.post(ApiService.LOGOUT);
      } catch (e) {
        print('Logout API error (ignoring): $e');
        // تجاهل الأخطاء في API تسجيل الخروج
      }
    } finally {
      // مسح البيانات المحلية (حتى لو فشل API)
      await _storageService.clearUserSession();
      currentUser.value = null;

      // مسح النماذج
      _clearForms();

      isLoading.value = false;

      // إظهار رسالة
      Get.snackbar(
        'تم',
        'تم تسجيل الخروج بنجاح',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      // الانتقال لصفحة تسجيل الدخول
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  // وظائف الصور الجديدة
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

  // وظائف القوائم المنسدلة الجديدة
  void onStateChanged(String? value) {
    selectedState.value = value;
    selectedCity.value = null; // إعادة تعيين المدينة عند تغيير المنطقة
  }

  void onCityChanged(String? value) {
    selectedCity.value = value;
  }

  void onServiceChanged(String? value) {
    selectedService.value = value;
  }

  // الحصول على قائمة المدن للمنطقة المختارة
  List<String> get availableCities {
    if (selectedState.value == null) return [];
    return citiesByState[selectedState.value] ?? [];
  }

  // تبديل الموافقة على الشروط
  void toggleTermsAccepted() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  // مسح النماذج
  void _clearForms() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
    descriptionController.clear();
    otpController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
    selectedState.value = null;
    selectedCity.value = null;
    selectedService.value = null;
    selectedImage.value = null;
    selectedProfileImage.value = null;
    selectedIDImage.value = null;
    selectedLicenseImage.value = null;
    isTermsAccepted.value = false;
    isAccountVerified.value = false;
    otpTimer.value = 0;
    canResendOtp.value = true;
  }

  // التحقق من صحة نموذج تسجيل الدخول
  bool _validateLoginForm() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال البريد الإلكتروني أو رقم الهاتف',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    // التحقق من البريد الإلكتروني أو رقم الهاتف
    String input = emailController.text.trim();
    bool isEmail = GetUtils.isEmail(input);
    bool isPhone = GetUtils.isPhoneNumber(input) && input.length >= 10;

    if (!isEmail && !isPhone) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال بريد إلكتروني صحيح أو رقم هاتف صحيح',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال كلمة المرور',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (passwordController.text.length < 3) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور قصيرة جداً',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    return true;
  }

  // التحقق من صحة نموذج التسجيل المحدث
  bool _validateSignUpForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال الاسم الكامل');
      return false;
    }

    if (nameController.text.trim().length < 2) {
      Get.snackbar('خطأ', 'الاسم يجب أن يكون حرفين على الأقل');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال رقم الهاتف');
      return false;
    }

    if (phoneController.text.trim().length < 10) {
      Get.snackbar('خطأ', 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل');
      return false;
    }

    if (selectedState.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار المنطقة');
      return false;
    }

    if (selectedCity.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار المدينة');
      return false;
    }

    if (selectedService.value == null) {
      Get.snackbar('خطأ', 'يرجى اختيار نوع الخدمة');
      return false;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar('خطأ', 'كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('خطأ', 'كلمة المرور غير متطابقة');
      return false;
    }

    if (!isTermsAccepted.value) {
      Get.snackbar('خطأ', 'يرجى الموافقة على الشروط والأحكام');
      return false;
    }

    return true;
  }

  // دالة مُحدثة للتحقق من صحة نموذج التسجيل العادي (للمستخدمين العاديين)
  bool _validateRegisterForm() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال الاسم',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (nameController.text.trim().length < 2) {
      Get.snackbar(
        'خطأ',
        'الاسم يجب أن يكون حرفين على الأقل',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال البريد الإلكتروني',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال بريد إلكتروني صحيح',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رقم الهاتف',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (phoneController.text.trim().length < 10) {
      Get.snackbar(
        'خطأ',
        'رقم الهاتف يجب أن يكون 10 أرقام على الأقل',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور غير متطابقة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    return true;
  }

  // نسيان كلمة المرور - إرسال رقم الهاتف
  Future<void> sendResetCode() async {
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رقم الهاتف',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (phoneController.text.trim().length < 10) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رقم هاتف صحيح',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Get.toNamed(AppRoutes.VERIFY_OTP);

    return ;

    try {
      isLoading.value = true;

      final response = await _apiService.post(
        ApiService.FORGOT_PASSWORD,
        body: {
          'phone': phoneController.text.trim(),
        },
      );

      if (response.body['success'] == true) {
        Get.snackbar(
          'تم الإرسال',
          'تم إرسال رمز التحقق إلى رقم هاتفك',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // بدء مؤقت إعادة الإرسال
        _startOtpTimer();

        // الانتقال لصفحة التحقق
        Get.toNamed(AppRoutes.VERIFY_OTP);
      } else {
        final message = response.body['message'] ?? 'فشل في إرسال الرمز';
        Get.snackbar(
          'خطأ',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'خطأ',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Send reset code error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
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
    if (otpController.text.trim().isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رمز التحقق',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (otpController.text.trim().length != 4) {
      Get.snackbar(
        'خطأ',
        'رمز التحقق يجب أن يكون 4 أرقام',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Get.toNamed(AppRoutes.RESET_PASSWORD);

    return ;
    try {
      isLoading.value = true;

      final response = await _apiService.post(
        ApiService.VERIFY_OTP,
        body: {
          'phone': phoneController.text.trim(),
          'otp': otpController.text.trim(),
        },
      );

      if (response.body['success'] == true) {
        Get.snackbar(
          'تم التحقق',
          'تم التحقق من الرمز بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // الانتقال لصفحة إعادة تعيين كلمة المرور
        Get.toNamed(AppRoutes.RESET_PASSWORD);
      } else {
        final message = response.body['message'] ?? 'رمز التحقق غير صحيح';
        Get.snackbar(
          'خطأ',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'خطأ',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Verify OTP error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
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
    if (newPasswordController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال كلمة المرور الجديدة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (newPasswordController.text.length < 6) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      Get.snackbar(
        'خطأ',
        'كلمة المرور غير متطابقة',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    Get.offAllNamed(AppRoutes.LOGIN);

    return ;

    try {
      isLoading.value = true;

      final response = await _apiService.post(
        ApiService.RESET_PASSWORD,
        body: {
          'phone': phoneController.text.trim(),
          'otp': otpController.text.trim(),
          'password': newPasswordController.text,
          'password_confirmation': confirmNewPasswordController.text,
        },
      );

      if (response.body['success'] == true) {
        Get.snackbar(
          'تم بنجاح',
          'تم تغيير كلمة المرور بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // مسح الحقول
        _clearResetPasswordForms();

        // الانتقال لصفحة تسجيل الدخول
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        final message = response.body['message'] ?? 'فشل في تغيير كلمة المرور';
        Get.snackbar(
          'خطأ',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'خطأ',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Reset password error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة إرسال رمز OTP
  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;

    _startOtpTimer();
    return ;

    try {
      isLoading.value = true;

      final response = await _apiService.post(
        ApiService.FORGOT_PASSWORD,
        body: {
          'phone': phoneController.text.trim(),
        },
      );

      if (response.body['success'] == true) {
        Get.snackbar(
          'تم الإرسال',
          'تم إعادة إرسال رمز التحقق',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // بدء مؤقت إعادة الإرسال
        _startOtpTimer();
      } else {
        final message = response.body['message'] ?? 'فشل في إعادة إرسال الرمز';
        Get.snackbar(
          'خطأ',
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('Resend OTP error: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في إعادة الإرسال',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // بدء مؤقت OTP
  void _startOtpTimer() {
    canResendOtp.value = false;
    otpTimer.value = 60; // 60 ثانية

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  // مسح نماذج إعادة تعيين كلمة المرور
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

  // تبديل رؤية كلمة المرور الجديدة
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmNewPasswordVisibility() {
    isConfirmNewPasswordVisible.value = !isConfirmNewPasswordVisible.value;
  }

  // تبديل تذكرني
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // دالة للتحقق من صحة الرمز المميز
  bool get isTokenValid {
    final token = _storageService.userToken;
    if (token.isEmpty) return false;

    // يمكنك إضافة منطق للتحقق من انتهاء صلاحية الرمز هنا
    // مثل فحص JWT token expiry

    return true;
  }

  // دالة لتحديث بيانات المستخدم
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
    nameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    descriptionController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }
}