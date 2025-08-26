import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../utils/app_config.dart';
import 'dio_service.dart';

class AuthService {
  final DioService _dioService = DioService();

  // Base URLs
  static const String _baseUrl = AppConfig.baseUrl;

  // Auth endpoints
  static const String _registerInitiate = '/auth/register/initiate';
  static const String _registerComplete = '/auth/register/complete';
  static const String _login = '/auth/login';
  static const String _checkStatus = '/auth/check-status';
  static const String _sendOtp = '/auth/phone/password-reset/send-otp';
  static const String _resetPassword = '/auth/phone/password-reset';

  // تهيئة التسجيل - الخطوة الأولى - مع FCM Token
  Future<Map<String, dynamic>> initiateRegistration({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    required String description,
    required String address,
    required String state,
    String? city,
    String? serviceType,
    String? fcmToken,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': role,
        'description': description,
        'address': address,
        'state': state,
        if (city != null) 'city': city,
        if (serviceType != null) 'serviceType': serviceType,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm': fcmToken,
      };

      print('Sending registration data with FCM Token: ${fcmToken?.isNotEmpty == true ? "✓" : "✗"}');

      final response = await _dioService.post(
        '$_baseUrl$_registerInitiate',
        data: data,
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إكمال التسجيل - الخطوة الثانية - مع FCM Token
  Future<Map<String, dynamic>> completeRegistration({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required String otp,
    required String role,
    required String description,
    required String address,
    required String state,
    String? city,
    String? serviceType,
    String? fcmToken,
  }) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'otp': otp,
        'role': role,
        'description': description,
        'address': address,
        'state': state,
        if (city != null) 'city': city,
        if (serviceType != null) 'serviceType': serviceType,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm': fcmToken,
      };

      print('Completing registration with FCM Token: ${fcmToken?.isNotEmpty == true ? "✓" : "✗"}');

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
    required String email,
    required String password,
    String? fcmToken, // إضافة FCM Token
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        if (fcmToken != null && fcmToken.isNotEmpty) 'fcm': fcmToken,
      };

      print('Login attempt with FCM Token: ${fcmToken?.isNotEmpty == true ? "✓" : "✗"}');

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
    required String email,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl$_checkStatus',
        data: {
          'email': email,
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
        data: {
          'phoneNumber': phoneNumber,
        },
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
        },
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تحديث FCM Token للمستخدم المسجل (دالة إضافية)
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

  // معالجة الأخطاء
  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (statusCode != null) {
            switch (statusCode) {
              case 400:
                return data?['message'] ?? 'بيانات غير صحيحة';
              case 401:
                return 'بيانات الدخول غير صحيحة';
              case 403:
                return 'غير مسموح بالوصول';
              case 404:
                return 'الحساب غير موجود';
              case 409:
                return data?['message'] ?? 'البريد الإلكتروني أو رقم الهاتف مستخدم مسبقاً';
              case 422:
                return data?['message'] ?? 'بيانات غير صالحة';
              case 500:
                return 'خطأ في الخادم، يرجى المحاولة لاحقاً';
              default:
                return data?['message'] ?? 'حدث خطأ غير متوقع';
            }
          }
          break;

        case DioExceptionType.cancel:
          return 'تم إلغاء العملية';

        case DioExceptionType.unknown:
          if (error.message?.contains('SocketException') == true) {
            return 'لا يوجد اتصال بالإنترنت';
          }
          return 'حدث خطأ في الاتصال';

        default:
          return 'حدث خطأ غير متوقع';
      }
    }

    return error.toString();
  }
}