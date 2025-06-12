// services/language_service.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'storage_service.dart';

class LanguageService extends GetxService {
  static const String _languageKey = 'language';

  late StorageService _storageService;
  final RxString currentLanguage = 'ar'.obs;
  final Rx<Locale> currentLocale = const Locale('ar', 'SA').obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    // التأكد من أن StorageService جاهزة
    _storageService = Get.find<StorageService>();

    // انتظار قصير للتأكد من اكتمال تهيئة التخزين
    await Future.delayed(Duration(milliseconds: 100));

    await loadSavedLanguage();
  }

  /// تحميل اللغة المحفوظة من التخزين المحلي
  Future<void> loadSavedLanguage() async {
    try {
      // التأكد من أن الخدمة جاهزة
      if (!Get.isRegistered<StorageService>()) {
        print('StorageService not ready, using default language');
        _setLanguage('ar');
        return;
      }

      final savedLanguage = _storageService.read(_languageKey);
      print('Loaded saved language: $savedLanguage');

      if (savedLanguage != null && (savedLanguage == 'ar' || savedLanguage == 'en')) {
        _setLanguage(savedLanguage);
        print('Language successfully set to: $savedLanguage');
      } else {
        // إذا لم توجد لغة محفوظة، احفظ العربية كافتراضية
        _setLanguage('ar');
        await _storageService.write(_languageKey, 'ar');
        print('Default language set and saved: ar');
      }
    } catch (e) {
      print('Error loading saved language: $e');
      // استخدام اللغة الافتراضية (العربية)
      _setLanguage('ar');
    }
  }

  /// تغيير لغة التطبيق وحفظها
  Future<void> changeLanguage(String language) async {
    if (language != 'ar' && language != 'en') {
      throw ArgumentError('Unsupported language: $language');
    }

    try {
      print('Changing language to: $language');

      // حفظ اللغة في التخزين المحلي أولاً
      await _storageService.write(_languageKey, language);
      print('Language saved to storage: $language');

      // تطبيق اللغة
      _setLanguage(language);

      // التأكد من الحفظ
      final verifyWrite = _storageService.read(_languageKey);
      print('Verification - saved language: $verifyWrite');

    } catch (e) {
      print('Error changing language: $e');
      rethrow;
    }
  }

  /// تطبيق اللغة داخلياً
  void _setLanguage(String language) {
    // تحديث قيمة اللغة الحالية
    currentLanguage.value = language;

    // إنشاء Locale الجديد
    Locale newLocale;
    switch (language) {
      case 'ar':
        newLocale = const Locale('ar', 'SA');
        break;
      case 'en':
        newLocale = const Locale('en', 'US');
        break;
      default:
        newLocale = const Locale('ar', 'SA');
    }

    // تحديث الـ Locale المحلي
    currentLocale.value = newLocale;

    // تطبيق اللغة على GetX بطرق متعددة للتأكد
    Get.updateLocale(newLocale);

    // إجبار تحديث الـ UI
    Get.forceAppUpdate();

    print('Language set to: $language');
    print('Locale updated to: ${newLocale.languageCode}');
    print('Current Get locale: ${Get.locale?.languageCode}');
  }

  /// الحصول على اللغة الحالية
  String get getCurrentLanguage => currentLanguage.value;

  /// الحصول على Locale الحالي
  Locale get getCurrentLocale => currentLocale.value;

  /// التحقق من كون اللغة الحالية عربية
  bool get isArabic => currentLanguage.value == 'ar';

  /// التحقق من كون اللغة الحالية إنجليزية
  bool get isEnglish => currentLanguage.value == 'en';

  /// الحصول على اتجاه النص للغة الحالية
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// قائمة اللغات المدعومة
  List<Map<String, String>> get supportedLanguages => [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
  ];

  /// إعادة تحميل اللغة من التخزين (للاستخدام عند الحاجة)
  Future<void> reloadLanguage() async {
    await loadSavedLanguage();
  }

  /// إعادة تطبيق اللغة الحالية (إجبار التحديث)
  void forceUpdateLanguage() {
    final current = currentLanguage.value;
    print('Force updating language: $current');
    _setLanguage(current);
  }

  /// دالة للتشخيص - طباعة حالة التخزين
  void debugStorage() {
    try {
      final stored = _storageService.read(_languageKey);
      final current = currentLanguage.value;
      final getLocale = Get.locale;
      print('=== Language Debug ===');
      print('Stored in storage: $stored');
      print('Current in memory: $current');
      print('Current locale: ${currentLocale.value}');
      print('Get.locale: ${getLocale?.languageCode}');
      print('Storage service registered: ${Get.isRegistered<StorageService>()}');
      print('Is Arabic: $isArabic');
      print('Is English: $isEnglish');
      print('Text Direction: $textDirection');
      print('===================');
    } catch (e) {
      print('Debug error: $e');
    }
  }
}