import 'package:get/get.dart';
import 'package:khabir/services/storage_service.dart';

class ApiService extends GetxService {
  final String baseUrl = 'https://api.yourapp.com'; // غير هذا للرابط الفعلي

  // Headers أساسية للطلبات
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${_getToken()}',
  };

  // الحصول على التوكن من التخزين المحلي
  String _getToken() {
    final StorageService storage = Get.find<StorageService>();
    return storage.userToken ?? '';
  }

  // طلب GET
  Future<Response> get(String endpoint, {Map<String, dynamic>? query}) async {
    try {
      final response = await GetConnect().get(
        '$baseUrl$endpoint',
        headers: headers,
        query: query,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // طلب POST
  Future<Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await GetConnect().post(
        '$baseUrl$endpoint',
        body,
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // طلب PUT
  Future<Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await GetConnect().put(
        '$baseUrl$endpoint',
        body,
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // طلب DELETE
  Future<Response> delete(String endpoint) async {
    try {
      final response = await GetConnect().delete(
        '$baseUrl$endpoint',
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // معالجة الاستجابة
  Response _handleResponse(Response response) {
    if (response.statusCode == 401) {
      // إذا انتهت صلاحية التوكن، قم بتسجيل الخروج
      _handleUnauthorized();
    }

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response;
    } else {
      throw ApiException(
        message: response.body['message'] ?? 'حدث خطأ غير متوقع',
        statusCode: response.statusCode!,
      );
    }
  }

  // معالجة الأخطاء
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return ApiException(message: 'خطأ في الاتصال بالخادم');
  }

  // معالجة انتهاء صلاحية التوكن
  void _handleUnauthorized() {
    final StorageService storage = Get.find<StorageService>();
    storage.clearUserSession();
    // إعادة توجيه لصفحة تسجيل الدخول
    Get.offAllNamed('/login');
  }

  // نقاط النهاية للـ API
  static const String LOGIN = '/auth/login';
  static const String REGISTER = '/auth/register';
  static const String LOGOUT = '/auth/logout';
  static const String FORGOT_PASSWORD = '/auth/forgot-password';
  static const String VERIFY_OTP = '/auth/verify-otp';
  static const String RESET_PASSWORD = '/auth/reset-password';
  static const String VERIFY_ACCOUNT = '/auth/verify-account';
  static const String RESEND_VERIFICATION_OTP = '/auth/resend-verification-otp';
  static const String RESEND_ACCOUNT_VERIFICATION = '/auth/resend-account-verification';


  static const String PROFILE = '/user/profile';
  static const String SERVICES = '/services';
  static const String ORDERS = '/orders';
}

// فئة الأخطاء المخصصة
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}