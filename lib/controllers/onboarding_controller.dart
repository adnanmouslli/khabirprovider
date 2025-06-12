// controllers/onboarding_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/storage_service.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  // استخدام LanguageService للتعامل مع اللغة
  final LanguageService _languageService = Get.find<LanguageService>();

  // ربط اللغة المختارة مع LanguageService
  String get selectedLanguage => _languageService.getCurrentLanguage;

  final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      image: 'assets/images/onboarding/onboarding1.png',
      titleKey: 'welcome_to_khabir',
      subtitleKey: 'enjoy_perfect_experience',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding/onboarding2.png',
      titleKey: 'choose_your_service',
      subtitleKey: 'choose_or_serve',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding/onboarding3.png',
      titleKey: 'what_is_your_attribute',
      subtitleKey: 'select_your_role',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // الاستماع لتغييرات اللغة
    ever(_languageService.currentLanguage, (_) => update());
  }

  /// تغيير لغة التطبيق مع معالجة الأخطاء
  Future<void> changeLanguage(String language) async {
    try {
      await _languageService.changeLanguage(language);

    } catch (e) {
      print('Error changing language in controller: $e');
    }
  }

  /// الانتقال للصفحة التالية
  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      currentPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// تخطي عملية الـ onboarding
  void skipOnboarding() {
    // حفظ أن المستخدم أكمل الـ onboarding
    _saveOnboardingCompleted();
    Get.offAllNamed('/login');
  }

  /// اختيار Provider
  void selectProvider() {
    // حفظ نوع المستخدم
    _saveUserType('provider');
    _saveOnboardingCompleted();
    Get.offAllNamed('/login');
  }

  /// اختيار User
  void selectUser() {
    // حفظ نوع المستخدم
    _saveUserType('user');
    _saveOnboardingCompleted();
    Get.offAllNamed('/user-auth');
  }

  /// العودة للصفحة السابقة
  void goBack() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// حفظ أن المستخدم أكمل الـ onboarding
  void _saveOnboardingCompleted() {
    try {
      final storageService = Get.find<StorageService>();
      storageService.write('onboarding_shown', true);
      print('onboarding shown saved successfully');
    } catch (e) {
      print('Error saving onboarding shown: $e');
    }
  }

  /// حفظ نوع المستخدم
  void _saveUserType(String userType) {
    try {
      final storageService = Get.find<StorageService>();
      storageService.write('user_type', userType);
      print('User type saved successfully: $userType');
    } catch (e) {
      print('Error saving user type: $e');
    }
  }

  /// التحقق من كون اللغة الحالية عربية
  bool get isArabic => _languageService.isArabic;

  /// التحقق من كون اللغة الحالية إنجليزية
  bool get isEnglish => _languageService.isEnglish;

  /// الحصول على اتجاه النص
  TextDirection get textDirection => _languageService.textDirection;

  /// قائمة اللغات المدعومة
  List<Map<String, String>> get supportedLanguages => _languageService.supportedLanguages;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingModel {
  final String image;
  final String titleKey;
  final String subtitleKey;

  OnboardingModel({
    required this.image,
    required this.titleKey,
    required this.subtitleKey,
  });
}