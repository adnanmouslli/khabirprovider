import 'package:dio/dio.dart' as dio;
import 'dart:io';
import '../utils/app_config.dart';
import 'dio_service.dart';
import 'package:get/get.dart';

class AuthService {
  final DioService _dioService = DioService();

  static const String _baseUrl = AppConfig.baseUrl;
  static const String fileUrl = AppConfig.fileUrl;

  static const String _registerInitiate = '/auth/register/initiate';
  static const String _registerComplete = '/auth/register/complete';
  static const String _login = '/auth/login';
  static const String _checkStatus = '/auth/check-status';
  static const String _sendOtp = '/auth/phone/password-reset/send-otp';
  static const String _resetPassword = '/auth/phone/password-reset';

  // تهيئة التسجيل - الخطوة الأولى - مع الصورة باسم 'image'
  Future<Map<String, dynamic>> initiateRegistration({
    required String name,
    required String password,
    required String phoneNumber,
    required String role,
    required String description,
    required String state,
    List<int>? categoryIds,
    String? fcmToken,
    File? profileImage,
  }) async {
    try {
      // إنشاء FormData
      dio.FormData formData = dio.FormData.fromMap({
        'name': name,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': role,
        'description': description,
        'state': state,
        'registerType': 'PROVIDER',
      });

      // إضافة الفئات كـ array - كل واحدة على حدة
      if (categoryIds != null && categoryIds.isNotEmpty) {
        for (var id in categoryIds) {
          formData.fields.add(MapEntry('categoryIds[]', id.toString()));
        }
      }

      // إضافة FCM Token
      if (fcmToken != null && fcmToken.isNotEmpty) {
        formData.fields.add(MapEntry('fcm', fcmToken));
      }

      // إضافة الصورة باسم 'image' كما يتوقع الباك إند
      if (profileImage != null) {
        String fileName = profileImage.path.split('/').last;
        formData.files.add(
          MapEntry(
            'image', // اسم الحقل المطلوب في الباك إند
            await dio.MultipartFile.fromFile(
              profileImage.path,
              filename: fileName,
            ),
          ),
        );
        print('✓ Profile image added: $fileName');
      } else {
        print('✗ No profile image provided');
      }

      print('===== Registration Request =====');
      print('Name: $name');
      print('Phone: $phoneNumber');
      print('Role: $role');
      print('State: $state');
      print('Categories: ${categoryIds?.length ?? 0}');
      print('FCM Token: ${fcmToken?.isNotEmpty == true ? "✓" : "✗"}');
      print('Image: ${profileImage != null ? "✓" : "✗"}');
      print('================================');

      final response = await _dioService.post(
        '$_baseUrl$_registerInitiate',
        data: formData,
      );

      return response.data;
    } catch (e) {
      print('Registration error: $e');
      throw _handleError(e);
    }
  }

  // إكمال التسجيل - الخطوة الثانية - مع الفئات بدلاً من الخدمات
  Future<Map<String, dynamic>> completeRegistration({
    required String name,
    required String password,
    required String phoneNumber,
    required String otp,
    required String role,
    required String description,
    required String state,
    List<int>? categoryIds, // تغيير من services إلى categoryIds
    String? fcmToken,
  }) async {
    try {
      final data = {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'type': "PROVIDER",
        'registerType': 'PROVIDER',
      };

      final response = await _dioService.post(
        '$_baseUrl$_registerComplete',
        data: data,
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تسجيل الدخول - مع FCM Token
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    String? fcmToken, // إضافة FCM Token
  }) async {
    try {
      final data = {
        'phone': phone,
        'password': password,
        'type': "PROVIDER",
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm': fcmToken,
      };

      print(
          'Login attempt with FCM Token: ${fcmToken?.isNotEmpty == true ? "✓" : "✗"}');

      final response = await _dioService.post(
        '$_baseUrl$_login',
        data: data,
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // فحص حالة الحساب
  Future<Map<String, dynamic>> checkAccountStatus({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl$_checkStatus',
        data: {
          'phoneNumber': phoneNumber,
        },
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إرسال OTP لإعادة تعيين كلمة المرور
  Future<Map<String, dynamic>> sendPasswordResetOtp({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl$_sendOtp',
        data: {'phoneNumber': phoneNumber, 'role': "PROVIDER"},
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إعادة تعيين كلمة المرور
  Future<Map<String, dynamic>> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl$_resetPassword',
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
          'newPassword': newPassword,
          "role": "PROVIDER"
        },
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب الفئات العامة
  Future<List<Map<String, dynamic>>> getPublicCategories() async {
    try {
      final response = await _dioService.get('$_baseUrl/categories/public');

      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }

      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // تحديث FCM Token
  Future<Map<String, dynamic>> updateFCMToken({
    required String fcmToken,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/auth/update-fcm-token',
        data: {
          'fcm': fcmToken,
        },
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // فحص التحديث
  Future<bool> checkForUpdate() async {
    try {
      final response = await _dioService.get('$_baseUrl/update-audit/latest');

      if (response.data is bool) {
        return response.data;
      }

      if (response.data is String) {
        return response.data.toLowerCase() == 'true';
      }

      if (response.data is Map && response.data['hasUpdate'] != null) {
        return response.data['hasUpdate'] as bool;
      }

      return false;
    } catch (e) {
      print('Error checking for update: $e');
      return false;
    }
  }

  // تسجيل الخروج
  Future<Map<String, dynamic>> logout({
    String? fcmToken,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (fcmToken != null && fcmToken.isNotEmpty) {
        data['fcm'] = fcmToken;
      }

      final response = await _dioService.post(
        '$_baseUrl/auth/logout',
        data: data,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else {
        return {
          'success': true,
          'message': 'Logout completed',
          'raw_response': responseData
        };
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب الشروط والأحكام
  Future<Map<String, String?>> getTermsAndConditions() async {
    try {
      final response = await _dioService
          .get('$_baseUrl/admin/settings/terms-and-conditions');

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        String? termsEn = responseData['terms_en'] as String?;
        String? termsAr = responseData['terms_ar'] as String?;
        String? privacyEn = responseData['privacy_en'] as String?;
        String? privacyAr = responseData['privacy_ar'] as String?;

        return {
          'terms_en': termsEn != null ? '$fileUrl$termsEn' : null,
          'terms_ar': termsAr != null ? '$fileUrl$termsAr' : null,
          'privacy_en': privacyEn != null ? '$fileUrl$privacyEn' : null,
          'privacy_ar': privacyAr != null ? '$fileUrl$privacyAr' : null,
        };
      }

      return {
        'terms_en': null,
        'terms_ar': null,
        'privacy_en': null,
        'privacy_ar': null,
      };
    } catch (e) {
      print('Error fetching terms and conditions: $e');
      return {
        'terms_en': null,
        'terms_ar': null,
        'privacy_en': null,
        'privacy_ar': null,
      };
    }
  }

  // معالجة الأخطاء
  String _handleError(dynamic error) {
    if (error is dio.DioException) {
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          return 'connection_timeout'.tr;

        case dio.DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (statusCode != null) {
            switch (statusCode) {
              case 400:
                return data?['message'] ?? 'invalid_data'.tr;
              case 401:
                return 'invalid_credentials'.tr;
              case 403:
                return 'access_forbidden'.tr;
              case 404:
                return 'account_not_found'.tr;
              case 409:
                return data?['message'] ?? 'phone_already_used'.tr;
              case 422:
                return data?['message'] ?? 'invalid_data_format'.tr;
              case 500:
                return 'server_error'.tr;
              default:
                return data?['message'] ?? 'unexpected_error'.tr;
            }
          }
          break;

        case dio.DioExceptionType.cancel:
          return 'operation_cancelled'.tr;

        case dio.DioExceptionType.unknown:
          if (error.message?.contains('SocketException') == true) {
            return 'no_internet_connection'.tr;
          }
          return 'connection_error'.tr;

        default:
          return 'unexpected_error'.tr;
      }
    }

    return error.toString();
  }
}
