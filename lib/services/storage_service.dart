import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // حفظ البيانات
  Future<bool> write(String key, dynamic value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    } else {
      // تحويل الكائنات المعقدة إلى JSON
      return await _prefs.setString(key, jsonEncode(value));
    }
  }

  // قراءة البيانات
  T? read<T>(String key) {
    if (!_prefs.containsKey(key)) return null;

    final value = _prefs.get(key);
    if (value == null) return null;

    return value as T?;
  }

  // قراءة Map بشكل منفصل
  Map<String, dynamic>? readMap(String key) {
    final value = _prefs.getString(key);
    if (value == null) return null;

    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // كتابة Map بشكل منفصل
  Future<bool> writeMap(String key, Map<String, dynamic> value) async {
    try {
      return await _prefs.setString(key, jsonEncode(value));
    } catch (e) {
      return false;
    }
  }

  // قراءة البيانات مع قيمة افتراضية
  T readWithDefault<T>(String key, T defaultValue) {
    final value = read<T>(key);
    return value ?? defaultValue;
  }

  // حذف مفتاح معين
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // حذف جميع البيانات
  Future<bool> erase() async {
    return await _prefs.clear();
  }

  // التحقق من وجود مفتاح
  bool hasData(String key) {
    return _prefs.containsKey(key);
  }

  // الحصول على جميع المفاتيح
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // --- مفاتيح التطبيق المحددة مسبقاً ---

  // حالة التعريف
  bool get isOnboardingShown => readWithDefault('onboarding_shown', false);
  set isOnboardingShown(bool value) => write('onboarding_shown', value);

  // حالة تسجيل الدخول
  bool get isLoggedIn => readWithDefault('is_logged_in', false);
  set isLoggedIn(bool value) => write('is_logged_in', value);

  // رمز المستخدم
  String get userToken => readWithDefault('user_token', '');
  set userToken(String value) => write('user_token', value);

  // بيانات المستخدم
  Map<String, dynamic> get userData {
    final data = readMap('user_data');
    return data ?? <String, dynamic>{};
  }
  set userData(Map<String, dynamic> value) => writeMap('user_data', value);

  // نوع المستخدم
  String get userType => readWithDefault('user_type', '');
  set userType(String value) => write('user_type', value);

  // اللغة
  String get language => readWithDefault('language', 'ar');
  set language(String value) => write('language', value);

  // وضع المظهر
  String get themeMode => readWithDefault('theme_mode', 'light');
  set themeMode(String value) => write('theme_mode', value);

  // حالة الإشعارات
  bool get notificationsEnabled => readWithDefault('notifications_enabled', true);
  set notificationsEnabled(bool value) => write('notifications_enabled', value);

  // --- وظائف مساعدة ---

  // حفظ بيانات المستخدم بعد تسجيل الدخول
  Future<void> saveUserSession({
    required String token,
    required Map<String, dynamic> user,
    required String type,
  }) async {
    await write('user_token', token);
    await writeMap('user_data', user);
    await write('user_type', type);
    await write('is_logged_in', true);
  }

  // مسح جلسة المستخدم
  Future<void> clearUserSession() async {
    await write('user_token', '');
    await writeMap('user_data', <String, dynamic>{});
    await write('user_type', '');
    await write('is_logged_in', false);
  }

  // إعادة تعيين إعدادات التطبيق
  Future<void> resetAppSettings() async {
    await write('onboarding_shown', false);
    await clearUserSession();
    await write('language', 'ar');
    await write('theme_mode', 'light');
    await write('notifications_enabled', true);

  }

  // طباعة حالة التخزين (للتشخيص)
  void debugPrint() {
    print('=== Storage Service Debug ===');
    print('Onboarding Shown: $isOnboardingShown');
    print('Is Logged In: $isLoggedIn');
    print('User Type: $userType');
    print('Language: $language');
    print('Theme Mode: $themeMode');
    print('Notifications: $notificationsEnabled');
    print('Has User Token: ${userToken.isNotEmpty}');
    print('User Data Keys: ${userData.keys.toList()}');
    print('All Keys: ${getKeys().toList()}');
    print('=== End Debug ===');
  }
}