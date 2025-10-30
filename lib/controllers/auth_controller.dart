import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khabir/services/auth_service.dart';
import 'package:khabir/services/language_service.dart';
import 'package:khabir/utils/openPrivacyPolicyUrl.dart';
import 'package:khabir/widgets/AccountPendingApprovalDialog.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/dio_service.dart';
import '../routes/app_routes.dart';
import '../utils/PhoneHelper.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storageService = Get.find<StorageService>();
  final DioService _dioService = DioService();

  // === متحكمات النصوص منفصلة لكل صفحة ===

  // متحكمات تسجيل الدخول
  final loginPhoneController = TextEditingController();
  final loginPasswordController = TextEditingController();

  // متحكمات التسجيل
  final signupNameController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();
  final signupDescriptionController = TextEditingController();

  // متحكمات إعادة تعيين كلمة المرور
  final resetPhoneController = TextEditingController();
  final resetOtpController = TextEditingController();
  final resetNewPasswordController = TextEditingController();
  final resetConfirmPasswordController = TextEditingController();

  // متحكمات تأكيد الحساب
  final verifyOtpController = TextEditingController();

  // === متحكمات OTP منفصلة ===
  StreamController<ErrorAnimationType>? verifyOtpErrorController;
  StreamController<ErrorAnimationType>? resetOtpErrorController;

  // === حالات التحكم منفصلة لكل صفحة ===

  // حالات تسجيل الدخول
  var isLoginLoading = false.obs;
  var isLoginPasswordVisible = false.obs;

  // حالات التسجيل
  var isSignupLoading = false.obs;
  var isSignupPasswordVisible = false.obs;
  var isSignupConfirmPasswordVisible = false.obs;
  var isTermsAccepted = false.obs;

  // حالات إعادة تعيين كلمة المرور
  var isResetLoading = false.obs;
  var isResetNewPasswordVisible = false.obs;
  var isResetConfirmPasswordVisible = false.obs;

  // حالات تأكيد الحساب
  var isVerifyLoading = false.obs;
  var hasVerifyOtpError = false.obs;
  var verifyOtpErrorText = ''.obs;
  var hasResetOtpError = false.obs;
  var resetOtpErrorText = ''.obs;

  // حالات عامة
  var rememberMe = false.obs;
  var otpTimer = 0.obs;
  var canResendOtp = true.obs;
  var isAccountVerified = false.obs;
  var showSuccessDialog = false.obs;

  // متغيرات روابط الشروط والأحكام
  var termsUrls = <String, String?>{}.obs;
  var isLoadingTerms = false.obs;
  var currentTermsUrl = ''.obs;

  final LanguageService _languageService = Get.find<LanguageService>();

  String get selectedLanguage => _languageService.getCurrentLanguage;
  bool get isArabic => _languageService.isArabic;
  bool get isEnglish => _languageService.isEnglish;

  // التحقق من توفر روابط الشروط والأحكام
  bool get hasTermsUrl => getTermsUrl()?.isNotEmpty ?? false;
  bool get hasPrivacyUrl => getPrivacyUrl()?.isNotEmpty ?? false;

  // متغير لتخزين رقم الهاتف المنسق
  RxString formattedPhone = ''.obs;
  RxString phoneError = ''.obs;

  // القوائم المنسدلة
  final selectedGovernorate = Rx<String?>(null);
  final selectedState = Rx<String?>(null);

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

  // الفئات والخدمات
  var allCategories = <Map<String, dynamic>>[].obs;
  var filteredCategories = <Map<String, dynamic>>[].obs;
  var selectedCategories = <Map<String, dynamic>>[].obs;
  var allServices = <Map<String, dynamic>>[].obs;
  var filteredServices = <Map<String, dynamic>>[].obs;
  var selectedServices = <Map<String, dynamic>>[].obs;
  var servicePrices = <int, double>{}.obs;

  // قائمة المحافظات العمانية المحدثة
  final List<Map<String, dynamic>> omanStates = [
    {
      "governorate": {"en": "Muscat Governorate", "ar": "محافظة مسقط"},
      "value": "Muscat",
      "states": [
        {
          "value": "Muscat",
          "label": {"en": "Muscat", "ar": "مسقط"}
        },
        {
          "value": "Muttrah",
          "label": {"en": "Muttrah", "ar": "مطرح"}
        },
        {
          "value": "Al Amrat",
          "label": {"en": "Al Amrat", "ar": "العامرات"}
        },
        {
          "value": "Bawshar",
          "label": {"en": "Bawshar", "ar": "بوشر"}
        },
        {
          "value": "Al Seeb",
          "label": {"en": "Al Seeb", "ar": "السيب"}
        },
        {
          "value": "Qurayyat",
          "label": {"en": "Qurayyat", "ar": "القريات"}
        }
      ]
    },
    {
      "governorate": {"en": "Dhofar Governorate", "ar": "محافظة ظفار"},
      "value": "Dhofar",
      "states": [
        {
          "value": "Salalah",
          "label": {"en": "Salalah", "ar": "صلالة"}
        },
        {
          "value": "Taqah",
          "label": {"en": "Taqah", "ar": "طاقة"}
        },
        {
          "value": "Mirbat",
          "label": {"en": "Mirbat", "ar": "مرباط"}
        },
        {
          "value": "Rakhyut",
          "label": {"en": "Rakhyut", "ar": "رخيوت"}
        },
        {
          "value": "Thumrait",
          "label": {"en": "Thumrait", "ar": "ثمريت"}
        },
        {
          "value": "Dhalkut",
          "label": {"en": "Dhalkut", "ar": "ضلكوت"}
        },
        {
          "value": "Al Mazyunah",
          "label": {"en": "Al Mazyunah", "ar": "المزيونة"}
        },
        {
          "value": "Maqshan",
          "label": {"en": "Maqshan", "ar": "مقشن"}
        },
        {
          "value": "Shalim and the Hallaniyat Islands",
          "label": {
            "en": "Shalim and the Hallaniyat Islands",
            "ar": "شليم وجزر الحلانيات"
          }
        },
        {
          "value": "Sadah",
          "label": {"en": "Sadah", "ar": "سدح"}
        }
      ]
    },
    {
      "governorate": {"en": "Musandam Governorate", "ar": "محافظة مسندم"},
      "value": "Musandam",
      "states": [
        {
          "value": "Khasab",
          "label": {"en": "Khasab", "ar": "خصب"}
        },
        {
          "value": "Dibba",
          "label": {"en": "Dibba", "ar": "دبا"}
        },
        {
          "value": "Bukha",
          "label": {"en": "Bukha", "ar": "بخا"}
        },
        {
          "value": "Madha",
          "label": {"en": "Madha", "ar": "مدحاء"}
        }
      ]
    },
    {
      "governorate": {"en": "Al Buraimi Governorate", "ar": "محافظة البريمي"},
      "value": "Al Buraimi",
      "states": [
        {
          "value": "Al Buraimi",
          "label": {"en": "Al Buraimi", "ar": "البريمي"}
        },
        {
          "value": "Mahdah",
          "label": {"en": "Mahdah", "ar": "محضة"}
        },
        {
          "value": "Al Sinainah",
          "label": {"en": "Al Sinainah", "ar": "السنينة"}
        }
      ]
    },
    {
      "governorate": {
        "en": "Ad Dakhiliyah Governorate",
        "ar": "محافظة الداخلية"
      },
      "value": "Ad Dakhiliyah",
      "states": [
        {
          "value": "Nizwa",
          "label": {"en": "Nizwa", "ar": "نزوى"}
        },
        {
          "value": "Bahla",
          "label": {"en": "Bahla", "ar": "بهلا"}
        },
        {
          "value": "Manah",
          "label": {"en": "Manah", "ar": "منح"}
        },
        {
          "value": "Al Hamra",
          "label": {"en": "Al Hamra", "ar": "الحمراء"}
        },
        {
          "value": "Adam",
          "label": {"en": "Adam", "ar": "أدم"}
        },
        {
          "value": "Izki",
          "label": {"en": "Izki", "ar": "إزكي"}
        },
        {
          "value": "Samail",
          "label": {"en": "Samail", "ar": "سمائل"}
        },
        {
          "value": "Bidbid",
          "label": {"en": "Bidbid", "ar": "بدبد"}
        },
        {
          "value": "Al Jabal Al Akhdar",
          "label": {"en": "Al Jabal Al Akhdar", "ar": "الجبل الأخضر"}
        }
      ]
    },
    {
      "governorate": {
        "en": "North Al Batinah Governorate",
        "ar": "محافظة شمال الباطنة"
      },
      "value": "North Al Batinah",
      "states": [
        {
          "value": "Sohar",
          "label": {"en": "Sohar", "ar": "صحار"}
        },
        {
          "value": "Liwa",
          "label": {"en": "Liwa", "ar": "لوى"}
        },
        {
          "value": "Shinas",
          "label": {"en": "Shinas", "ar": "شناص"}
        },
        {
          "value": "Saham",
          "label": {"en": "Saham", "ar": "صحم"}
        },
        {
          "value": "Al Khaboura",
          "label": {"en": "Al Khaboura", "ar": "الخابورة"}
        },
        {
          "value": "Al Suwaiq",
          "label": {"en": "Al Suwaiq", "ar": "السويق"}
        }
      ]
    },
    {
      "governorate": {
        "en": "South Al Batinah Governorate",
        "ar": "محافظة جنوب الباطنة"
      },
      "value": "South Al Batinah",
      "states": [
        {
          "value": "Rustaq",
          "label": {"en": "Rustaq", "ar": "الرستاق"}
        },
        {
          "value": "Al Awabi",
          "label": {"en": "Al Awabi", "ar": "العوابي"}
        },
        {
          "value": "Nakhal",
          "label": {"en": "Nakhal", "ar": "نخل"}
        },
        {
          "value": "Wadi Al Maawil",
          "label": {"en": "Wadi Al Maawil", "ar": "وادي المعاول"}
        },
        {
          "value": "Barka",
          "label": {"en": "Barka", "ar": "بركاء"}
        },
        {
          "value": "Al Musannah",
          "label": {"en": "Al Musannah", "ar": "المصنعة"}
        }
      ]
    },
    {
      "governorate": {
        "en": "South Ash Sharqiyah Governorate",
        "ar": "محافظة جنوب الشرقية"
      },
      "value": "South Ash Sharqiyah",
      "states": [
        {
          "value": "Sur",
          "label": {"en": "Sur", "ar": "صور"}
        },
        {
          "value": "Al Kamil Wal Wafi",
          "label": {"en": "Al Kamil Wal Wafi", "ar": "الكامل والوافي"}
        },
        {
          "value": "Jaalan Bani Bu Hassan",
          "label": {"en": "Jaalan Bani Bu Hassan", "ar": "جعلان بني بوحسن"}
        },
        {
          "value": "Jaalan Bani Bu Ali",
          "label": {"en": "Jaalan Bani Bu Ali", "ar": "جعلان بني بو علي"}
        },
        {
          "value": "Masirah",
          "label": {"en": "Masirah", "ar": "مصيرة"}
        }
      ]
    },
    {
      "governorate": {
        "en": "North Ash Sharqiyah Governorate",
        "ar": "محافظة شمال الشرقية"
      },
      "value": "North Ash Sharqiyah",
      "states": [
        {
          "value": "Ibra",
          "label": {"en": "Ibra", "ar": "إبراء"}
        },
        {
          "value": "Al Mudhaibi",
          "label": {"en": "Al Mudhaibi", "ar": "المضيبي"}
        },
        {
          "value": "Bidiyah",
          "label": {"en": "Bidiyah", "ar": "بدية"}
        },
        {
          "value": "Al Qabil",
          "label": {"en": "Al Qabil", "ar": "القابل"}
        },
        {
          "value": "Wadi Bani Khalid",
          "label": {"en": "Wadi Bani Khalid", "ar": "وادي بني خالد"}
        },
        {
          "value": "Dema Wa Thaieen",
          "label": {"en": "Dema Wa Thaieen", "ar": "دماء الطائيين"}
        },
        {
          "value": "Sinaw",
          "label": {"en": "Sinaw", "ar": "سناو"}
        }
      ]
    },
    {
      "governorate": {"en": "Ad Dhahirah Governorate", "ar": "محافظة الظاهرة"},
      "value": "Ad Dhahirah",
      "states": [
        {
          "value": "Ibri",
          "label": {"en": "Ibri", "ar": "عبري"}
        },
        {
          "value": "Yanqul",
          "label": {"en": "Yanqul", "ar": "ينقل"}
        },
        {
          "value": "Dhank",
          "label": {"en": "Dhank", "ar": "ضنك"}
        }
      ]
    },
    {
      "governorate": {"en": "Al Wusta Governorate", "ar": "محافظة الوسطى"},
      "value": "Al Wusta",
      "states": [
        {
          "value": "Haima",
          "label": {"en": "Haima", "ar": "هيما"}
        },
        {
          "value": "Mahout",
          "label": {"en": "Mahout", "ar": "محوت"}
        },
        {
          "value": "Duqm",
          "label": {"en": "Duqm", "ar": "الدقم"}
        },
        {
          "value": "Al Jazer",
          "label": {"en": "Al Jazer", "ar": "الجازر"}
        }
      ]
    }
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _checkLoginStatus();
    _loadCategories();
    _loadTermsAndConditions(); // تحميل الشروط عند بداية التطبيق
  }

  void _initializeControllers() {
    // تهيئة متحكمات OTP منفصلة
    verifyOtpErrorController = StreamController<ErrorAnimationType>();
    resetOtpErrorController = StreamController<ErrorAnimationType>();

    // إضافة listeners منفصلة
    signupPhoneController.addListener(_onSignupPhoneChanged);
    resetPhoneController.addListener(_onResetPhoneChanged);
  }

  // === دوال تحميل البيانات ===

  Future<void> _loadTermsAndConditions() async {
    try {
      isLoadingTerms.value = true;
      final terms = await _authService.getTermsAndConditions();
      termsUrls.value = terms;
      print('Terms loaded successfully during app initialization');
    } catch (e) {
      print('Error loading terms and conditions: $e');
      termsUrls.value = {
        'terms_ar': null,
        'terms_en': null,
        'privacy_en': null,
        'privacy_ar': null
      };
    } finally {
      isLoadingTerms.value = false;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await _authService.getPublicCategories();
      allCategories.value = response;
      _filterCategoriesByState();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  // === دوال تسجيل الدخول ===

  Future<void> login() async {
    if (!_validateLoginForm()) return;

    try {
      isLoginLoading.value = true;

      final fcmToken = _storageService.getFCMToken();
      print(
          'FCM Token for login: ${fcmToken.isNotEmpty ? fcmToken.substring(0, 20) + "..." : "Empty"}');

      final phone = _formatPhoneNumber(loginPhoneController.text.trim());

      final response = await _authService.login(
        phone: phone,
        password: loginPasswordController.text,
        fcmToken: fcmToken.isNotEmpty ? fcmToken : null,
      );

      final token = response['access_token'];
      final userData = response['user'];

      await _storageService.saveUserSession(
        token: token,
        user: userData,
        type: userData['role'] ?? 'PROVIDER',
        fcmToken: fcmToken,
      );

      _dioService.updateToken(token);
      currentUser.value = UserModel.fromJson(userData);

      Get.snackbar(
        'success'.tr,
        'login_success'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      _clearLoginForms();
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      String errorMessage;

      if (e.toString().contains("Invalid credentials")) {
        errorMessage = "invalid_credentials".tr;
      } else {
        errorMessage = e.toString();
      }

      Get.snackbar(
        'error'.tr,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoginLoading.value = false;
    }
  }

  bool _validateLoginForm() {
    if (loginPhoneController.text.trim().isEmpty) {
      _showError('please_enter_email_phone'.tr);
      return false;
    }

    String input = loginPhoneController.text.trim();
    bool isPhone = PhoneHelper.isValidOmanPhone(input);

    if (!isPhone) {
      _showError('please_enter_valid_email_phone'.tr);
      return false;
    }

    if (loginPasswordController.text.isEmpty) {
      _showError('please_enter_password'.tr);
      return false;
    }

    if (loginPasswordController.text.length < 6) {
      _showError('password_min_length'.tr);
      return false;
    }

    return true;
  }

  // === دوال التسجيل ===

  Future<void> register() async {
    if (!_validateRegistrationData()) {
      Get.snackbar(
        'error'.tr,
        'please_correct_data'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSignupLoading.value = true;

      final fcmToken = _storageService.getFCMToken();
      final categoryIds =
          selectedCategories.map((category) => category['id'] as int).toList();
      String finalPhone =
          PhoneHelper.formatOmanPhone(signupPhoneController.text);

      File? profileImageFile;
      if (selectedProfileImage.value != null) {
        profileImageFile = File(selectedProfileImage.value!.path);
        print('✓ Profile image ready: ${profileImageFile.path}');
        print('✓ Image size: ${await profileImageFile.length()} bytes');
      } else {
        print('✗ No profile image selected');
      }

      _registrationData = {
        'name': signupNameController.text.trim(),
        'password': signupPasswordController.text,
        'phoneNumber': finalPhone,
        'role': 'PROVIDER',
        'description': signupDescriptionController.text.trim(),
        'state': selectedState.value ?? '',
        'categoryIds': categoryIds,
        'fcmToken': fcmToken,
        'profileImage': profileImageFile, // حفظ الصورة
      };

      final response = await _authService.initiateRegistration(
        name: _registrationData['name'],
        password: _registrationData['password'],
        phoneNumber: _registrationData['phoneNumber'],
        role: _registrationData['role'],
        description: _registrationData['description'],
        state: _registrationData['state'],
        categoryIds: _registrationData['categoryIds'],
        fcmToken: fcmToken.isNotEmpty ? fcmToken : null,
        profileImage: profileImageFile, // إرسال الصورة
      );

      if (response['success'] == true) {
        Get.snackbar(
          'sent'.tr,
          'verification_code_sent'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _startAccountVerificationTimer();
        Get.toNamed(AppRoutes.VERIFY_ACCOUNT);
      } else {
        throw 'registration_failed'.tr;
      }
    } catch (e) {
      String errorMessage;

      if (e.toString().contains("Invalid credentials")) {
        errorMessage = "invalid_credentials".tr;
      } else if (e.toString().contains("Phone number is already registered")) {
        errorMessage = "phone_already_registered".tr;
      } else {
        errorMessage = e.toString();
      }

      Get.snackbar(
        'error'.tr,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSignupLoading.value = false;
    }
  }

  bool _validateRegistrationData() {
    bool isValid = true;

    if (signupNameController.text.trim().isEmpty) {
      _showError('يرجى إدخال الاسم الكامل');
      isValid = false;
    }

    if (signupNameController.text.trim().length < 2) {
      _showError('الاسم يجب أن يكون حرفين على الأقل');
      isValid = false;
    }

    String? phoneErrorMsg = PhoneHelper.getPhoneErrorMessage(
        signupPhoneController.text, Get.locale?.languageCode ?? 'ar');

    if (phoneErrorMsg != null) {
      phoneError.value = phoneErrorMsg;
      isValid = false;
    } else {
      phoneError.value = '';
    }

    if (signupPasswordController.text.length < 6) {
      _showError('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      isValid = false;
    }

    if (signupPasswordController.text != signupConfirmPasswordController.text) {
      _showError('كلمة المرور غير متطابقة');
      isValid = false;
    }

    if (selectedGovernorate.value == null) {
      _showError('يرجى اختيار المحافظة');
      isValid = false;
    }

    if (selectedState.value == null) {
      _showError('يرجى اختيار الولاية');
      isValid = false;
    }

    if (selectedCategories.isEmpty) {
      _showError('يرجى اختيار فئة واحدة على الأقل');
      isValid = false;
    }

    if (!isTermsAccepted.value) {
      _showError('يرجى الموافقة على الشروط والأحكام');
      isValid = false;
    }

    return isValid;
  }

  // === دوال تأكيد الحساب ===

  Future<void> verifyAccount() async {
    if (!_validateVerifyOtp()) return;

    try {
      isVerifyLoading.value = true;

      final response = await _authService.completeRegistration(
        name: _registrationData['name'],
        password: _registrationData['password'],
        phoneNumber: _registrationData['phoneNumber'],
        otp: verifyOtpController.text.trim(),
        role: _registrationData['role'],
        description: _registrationData['description'],
        state: _registrationData['state'],
        categoryIds: _registrationData['categoryIds'],
      );

      if (response['id'] != null) {
        isAccountVerified.value = true;
        _clearAllForms();
        AccountPendingApprovalDialog.show();
      } else {
        throw 'account_creation_error'.tr;
      }
    } catch (e) {
      String errorMessage;

      if (e.toString().contains("Invalid OTP")) {
        errorMessage = "invalid_otp".tr;
      } else {
        errorMessage = e.toString();
      }

      Get.snackbar(
        'error'.tr,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isVerifyLoading.value = false;
    }
  }

  bool _validateVerifyOtp() {
    String otpValue = verifyOtpController.text.trim();

    hasVerifyOtpError.value = false;
    verifyOtpErrorText.value = '';

    if (otpValue.isEmpty) {
      _showVerifyOtpError('please_enter_verification_code'.tr);
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(otpValue)) {
      _showVerifyOtpError('verification_code_numbers_only'.tr);
      return false;
    }

    if (otpValue.length != 6) {
      _showVerifyOtpError('verification_code_six_digits'.tr);
      return false;
    }

    return true;
  }

  void _showVerifyOtpError(String message) {
    hasVerifyOtpError.value = true;
    verifyOtpErrorText.value = message;
    verifyOtpErrorController?.add(ErrorAnimationType.shake);

    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // === دوال إعادة تعيين كلمة المرور ===

  Future<void> resetPassword() async {
    if (!_validateResetPassword()) return;

    try {
      isResetLoading.value = true;

      // منطق إعادة تعيين كلمة المرور
      // await _authService.resetPassword(...);

      Get.snackbar(
        'success'.tr,
        'password_reset_success'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      _clearResetPasswordForms();
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isResetLoading.value = false;
    }
  }

  bool _validateResetPassword() {
    if (resetNewPasswordController.text.isEmpty) {
      _showError('please_enter_new_password'.tr);
      return false;
    }

    if (resetNewPasswordController.text.length < 6) {
      _showError('password_min_length'.tr);
      return false;
    }

    if (resetNewPasswordController.text !=
        resetConfirmPasswordController.text) {
      _showError('password_mismatch'.tr);
      return false;
    }

    return true;
  }

  // === دوال UI State Management منفصلة ===

  // تسجيل الدخول
  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  // التسجيل
  void toggleSignupPasswordVisibility() {
    isSignupPasswordVisible.value = !isSignupPasswordVisible.value;
  }

  void toggleSignupConfirmPasswordVisibility() {
    isSignupConfirmPasswordVisible.value =
        !isSignupConfirmPasswordVisible.value;
  }

  // إعادة تعيين كلمة المرور
  void toggleResetNewPasswordVisibility() {
    isResetNewPasswordVisible.value = !isResetNewPasswordVisible.value;
  }

  void toggleResetConfirmPasswordVisibility() {
    isResetConfirmPasswordVisible.value = !isResetConfirmPasswordVisible.value;
  }

  void toggleTermsAccepted() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // === دوال مساعدة للهاتف ===

  void _onSignupPhoneChanged() {
    String phone = signupPhoneController.text;

    if (phone.isEmpty) {
      formattedPhone.value = '';
      phoneError.value = '';
      return;
    }

    String formatted = PhoneHelper.formatOmanPhone(phone);
    formattedPhone.value = formatted;

    String? error = PhoneHelper.getPhoneErrorMessage(
        phone, Get.locale?.languageCode ?? 'ar');
    phoneError.value = error ?? '';
  }

  void _onResetPhoneChanged() {
    String phone = resetPhoneController.text;
    if (phone.isNotEmpty) {
      String? error = PhoneHelper.getPhoneErrorMessage(
          phone, Get.locale?.languageCode ?? 'ar');
      phoneError.value = error ?? '';
    }
  }

  // === دوال OTP منفصلة ===

  void onVerifyOtpChanged(String value) {
    if (hasVerifyOtpError.value) {
      hasVerifyOtpError.value = false;
      verifyOtpErrorText.value = '';
    }
  }

  void onResetOtpChanged(String value) {
    if (hasResetOtpError.value) {
      hasResetOtpError.value = false;
      resetOtpErrorText.value = '';
    }
  }

  void clearVerifyOtp() {
    verifyOtpController.clear();
    hasVerifyOtpError.value = false;
    verifyOtpErrorText.value = '';
  }

  void clearResetOtp() {
    resetOtpController.clear();
    hasResetOtpError.value = false;
    resetOtpErrorText.value = '';
  }

  // === دوال مسح البيانات منفصلة ===

  void _clearLoginForms() {
    loginPhoneController.clear();
    loginPasswordController.clear();
    isLoginPasswordVisible.value = false;
    rememberMe.value = false;
  }

  void _clearSignupForms() {
    signupNameController.clear();
    signupPhoneController.clear();
    signupPasswordController.clear();
    signupConfirmPasswordController.clear();
    signupDescriptionController.clear();
    isSignupPasswordVisible.value = false;
    isSignupConfirmPasswordVisible.value = false;
    selectedState.value = null;
    selectedGovernorate.value = null;
    selectedCategories.clear();
    isTermsAccepted.value = false;
    formattedPhone.value = '';
    phoneError.value = '';
  }

  void _clearResetPasswordForms() {
    resetPhoneController.clear();
    resetOtpController.clear();
    resetNewPasswordController.clear();
    resetConfirmPasswordController.clear();
    isResetNewPasswordVisible.value = false;
    isResetConfirmPasswordVisible.value = false;
    hasResetOtpError.value = false;
    resetOtpErrorText.value = '';
    otpTimer.value = 0;
    canResendOtp.value = true;
  }

  void _clearVerifyForms() {
    verifyOtpController.clear();
    hasVerifyOtpError.value = false;
    verifyOtpErrorText.value = '';
    otpTimer.value = 0;
    canResendOtp.value = true;
  }

  void _clearAllForms() {
    _clearLoginForms();
    _clearSignupForms();
    _clearResetPasswordForms();
    _clearVerifyForms();
    _registrationData.clear();
  }

  // === باقي الدوال كما هي ===

  Future<void> logout() async {
    try {
      isLoginLoading.value = true;

      print('🔄 Starting logout process...');

      // 1. الحصول على FCM Token
      final fcmToken = _storageService.getFCMToken();
      print(
          'FCM Token: ${fcmToken.isNotEmpty ? fcmToken.substring(0, 20) + "..." : "Empty"}');

      // 2. محاولة تسجيل الخروج من السيرفر
      try {
        final serverResponse = await _logoutFromServer(fcmToken);
        print('✅ Server logout successful');
      } catch (serverError) {
        print('⚠️ Server logout failed: $serverError');
        // نكمل عملية تسجيل الخروج المحلي حتى لو فشل السيرفر
      }

      // 3. إلغاء الاشتراك من Firebase Topics
      try {
        await _unsubscribeFromFirebaseTopics();
        print('✅ Firebase topics unsubscribed');
      } catch (firebaseError) {
        print('⚠️ Firebase unsubscribe failed: $firebaseError');
      }

      // 4. تنظيف البيانات المحلية
      print('🔄 Clearing local data...');
      await _storageService.clearUserSession();
      _dioService.clearToken();
      currentUser.value = null;
      _clearAllForms();
      print('✅ Local data cleared');

      // 5. عرض رسالة النجاح
      Get.snackbar(
        'done'.tr,
        'logout_success'.tr,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // 6. الانتظار قليلاً ثم الانتقال لصفحة تسجيل الدخول
      await Future.delayed(const Duration(milliseconds: 500));

      // 7. التنقل إلى صفحة تسجيل الدخول وحذف كل الصفحات السابقة
      print('🔄 Navigating to login page...');
      Get.offAllNamed(AppRoutes.LOGIN);
      print('✅ Logout complete');
    } catch (e) {
      print('❌ Error during logout: $e');

      // في حالة حدوث أي خطأ، نحاول التنظيف والتنقل على أي حال
      try {
        await _storageService.clearUserSession();
        _dioService.clearToken();
        currentUser.value = null;
        _clearAllForms();

        Get.snackbar(
          'done'.tr,
          'logout_local_success'.tr,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.LOGIN);
      } catch (localError) {
        print('❌ Critical error during logout: $localError');

        Get.snackbar(
          'error'.tr,
          '${'logout_error'.tr}: $localError',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // محاولة أخيرة للتنقل
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } finally {
      isLoginLoading.value = false;
    }
  }

  // === دوال الشروط والأحكام ===

  String? getTermsUrl() {
    if (termsUrls.isEmpty) return null;
    return isArabic ? termsUrls['terms_ar'] : termsUrls['terms_en'];
  }

  String? getPrivacyUrl() {
    if (termsUrls.isEmpty) return null;
    return isArabic ? termsUrls['privacy_ar'] : termsUrls['privacy_en'];
  }

  Future<void> openTermsAndConditions() async {
    try {
      // تحقق من وجود الروابط المحملة مسبقاً
      if (termsUrls.isEmpty) {
        Get.snackbar(
          'error'.tr,
          isArabic
              ? 'رابط الشروط والأحكام غير متوفر حالياً'
              : 'Terms and conditions link is not available currently',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final termsUrl = getTermsUrl();

      if (termsUrl == null || termsUrl.isEmpty) {
        Get.snackbar(
          'error'.tr,
          isArabic
              ? 'رابط الشروط والأحكام غير متوفر حالياً'
              : 'Terms and conditions link is not available currently',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      final privacyTitle = isArabic ? 'الشروط والأحكام' : 'Privacy Policy';

      openPrivacyPolicyUrl(termsUrl, privacyTitle);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> openPrivacyPolicy() async {
    try {
      // تحقق من وجود الروابط المحملة مسبقاً
      if (termsUrls.isEmpty) {
        Get.snackbar(
          'error'.tr,
          isArabic
              ? 'رابط سياسة الخصوصية غير متوفر حالياً'
              : 'Privacy policy link is not available currently',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final privacyUrl = getPrivacyUrl();

      if (privacyUrl == null || privacyUrl.isEmpty) {
        Get.snackbar(
          'error'.tr,
          isArabic
              ? 'رابط الشروط والأحكام غير متوفر حالياً'
              : 'Privacy policy link is not available currently',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      final termsTitle = isArabic ? 'الشروط والأحكام' : 'Terms and Conditions';

      openPrivacyPolicyUrl(privacyUrl, termsTitle);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // === دوال مساعدة أخرى ===

  String get termsStatusText {
    if (isLoadingTerms.value) {
      return isArabic ? 'جاري التحميل...' : 'Loading...';
    }

    if (!hasTermsUrl) {
      return isArabic ? 'غير متوفر' : 'Not available';
    }

    return isArabic ? 'الشروط والأحكام' : 'Terms and Conditions';
  }

  String get privacyStatusText {
    if (isLoadingTerms.value) {
      return isArabic ? 'جاري التحميل...' : 'Loading...';
    }

    if (!hasPrivacyUrl) {
      return isArabic ? 'غير متوفر' : 'Not available';
    }

    return isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';
  }

  void _filterCategoriesByState() {
    if (selectedState.value == null) {
      filteredCategories.clear();
      return;
    }

    filteredCategories.value = allCategories.where((category) {
      final categoryState = category['state'];
      if (categoryState != null) {
        return categoryState == selectedState.value;
      }
      return false;
    }).toList();
  }

  void _checkLoginStatus() {
    if (_storageService.isLoggedIn) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    try {
      final userData = _storageService.userData;
      if (userData.isNotEmpty) {
        currentUser.value = UserModel.fromJson(userData);
        _dioService.updateToken(_storageService.userToken);
      }
    } catch (e) {
      print('Error loading user data: $e');
      _storageService.clearUserSession();
    }
  }

  Future<void> resendAccountVerificationOtp() async {
    if (!canResendOtp.value || _registrationData.isEmpty) return;

    try {
      isVerifyLoading.value = true;

      final fcmToken = _storageService.getFCMToken();
      _registrationData['fcmToken'] = fcmToken;

      final response = await _authService.initiateRegistration(
        name: _registrationData['name'],
        password: _registrationData['password'],
        phoneNumber: _registrationData['phoneNumber'],
        role: _registrationData['role'],
        description: _registrationData['description'],
        state: _registrationData['state'],
        categoryIds: _registrationData['categoryIds'],
        fcmToken: fcmToken.isNotEmpty ? fcmToken : null,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'sent'.tr,
          'verification_code_resent'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _startAccountVerificationTimer();
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isVerifyLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> _logoutFromServer(String fcmToken) async {
    try {
      print('🔄 Logging out from server...');

      final response = await _authService.logout(
        fcmToken: fcmToken.isNotEmpty ? fcmToken : null,
      );

      if (response['success'] == true) {
        print('✅ Successfully logged out from server');
        print('Server message: ${response['message']}');
        return response;
      } else {
        final errorMessage = 'server_unknown_error'.tr;
        print('❌ Server returned unsuccessful logout: $errorMessage');
        throw Exception('${'logout_failed'.tr}: $errorMessage');
      }
    } catch (e) {
      print('❌ Error logging out from server: $e');
      throw e;
    }
  }

  Future<void> _unsubscribeFromFirebaseTopics() async {
    try {
      print('🔄 Unsubscribing from Firebase topics...');

      final List<String> topicsToUnsubscribe = [
        'channel_providers',
      ];

      // for (String topic in topicsToUnsubscribe) {
        try {
          await FirebaseMessaging.instance.unsubscribeFromTopic("channel_providers");
          // print('✅ Successfully unsubscribed from topic: $topic');
        } catch (topicError) {
          print('❌ Failed to unsubscribe from topic channel_providers: $topicError');
        }
      // }

      await _storageService.write('subscribed_to_providers_topic', false);
      print('✅ Updated local subscription status');
    } catch (e) {
      print('❌ Error unsubscribing from Firebase topics: $e');
      throw e;
    }
  }

  void _startAccountVerificationTimer() {
    canResendOtp.value = false;
    otpTimer.value = 120;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer.value > 0) {
        otpTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  void _showError(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  String _formatPhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'[\s-]'), '');

    if (phone.startsWith('00968')) {
      return '+${phone.substring(2)}';
    } else if (phone.startsWith('968')) {
      return '+$phone';
    } else if (phone.startsWith('9') && phone.length == 8) {
      return '+968$phone';
    } else if (phone.startsWith('0') && phone.length == 9) {
      return '+968${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      return '+968$phone';
    }
    return phone;
  }

  // إدارة الفئات
  void toggleCategorySelection(Map<String, dynamic> category) {
    final categoryId = category['id'];
    final index = selectedCategories.indexWhere((c) => c['id'] == categoryId);

    if (index >= 0) {
      selectedCategories.removeAt(index);
    } else {
      selectedCategories.add(category);
    }
  }

  void updateSelectedCategories(
      List<Map<String, dynamic>> newSelectedCategories) {
    selectedCategories.value = newSelectedCategories;
  }

  bool isCategorySelected(Map<String, dynamic> category) {
    return selectedCategories.any((c) => c['id'] == category['id']);
  }

  // إدارة القوائم المنسدلة
  void onGovernorateChanged(String? value) {
    selectedGovernorate.value = value;
    selectedState.value = null;
    selectedCategories.clear();
    filteredCategories.clear();
  }

  void onStateChanged(String? value) {
    selectedState.value = value;
    selectedCategories.clear();
    _filterCategoriesByState();
  }

  List<String> get availableGovernorates {
    return omanStates.map((gov) {
      return isArabic
          ? gov['governorate']['ar'] as String
          : gov['governorate']['en'] as String;
    }).toList();
  }

  List<String> get availableStates {
    if (selectedGovernorate.value == null) return [];

    final selectedGov = omanStates.firstWhere(
      (gov) => gov['value'] == selectedGovernorate.value,
      orElse: () => {'states': []},
    );

    final states = selectedGov['states'] as List;
    return states.map((state) {
      return isArabic
          ? state['label']['ar'] as String
          : state['label']['en'] as String;
    }).toList();
  }

  String? getGovernorateValueFromLabel(String label) {
    for (var gov in omanStates) {
      if (gov['governorate']['ar'] == label ||
          gov['governorate']['en'] == label) {
        return gov['value'];
      }
    }
    return null;
  }

  String? getStateValueFromLabel(String label) {
    if (selectedGovernorate.value == null) return null;

    final selectedGov = omanStates.firstWhere(
      (gov) => gov['value'] == selectedGovernorate.value,
      orElse: () => {'states': []},
    );

    final states = selectedGov['states'] as List;
    for (var state in states) {
      if (state['label']['ar'] == label || state['label']['en'] == label) {
        return state['value'];
      }
    }
    return null;
  }

  // رفع الصور
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
          'image_selected'.tr,
          'image_selected_success'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'image_selection_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // فحص التحديث
  Future<bool> checkForAppUpdate() async {
    try {
      print('Checking for app update...');
      final hasUpdate = await _authService.checkForUpdate();
      print('Update check result: $hasUpdate');
      return hasUpdate;
    } catch (e) {
      print('Error checking for update: $e');
      return false;
    }
  }

  // خصائص للتحقق من الحالة
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
}
