import 'package:dio/dio.dart';
import '../utils/app_config.dart';
import 'dio_service.dart';

class ProviderRatingsService {
  final DioService _dioService = DioService();

  // Base URLs
  static const String _baseUrl = AppConfig.baseUrl;

  // Provider ratings endpoints
  static const String _providerRatings = '/provider-ratings';

  // جلب تقييمات المزود
  Future<Map<String, dynamic>> getProviderRatings(int providerId) async {
    try {
      final response = await _dioService.get('$_baseUrl$_providerRatings/provider/$providerId');

      return response.data ?? {};
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب متوسط التقييم فقط
  Future<double> getProviderAverageRating(int providerId) async {
    try {
      print('Fetching rating for provider ID: $providerId');
      final response = await _dioService.get('$_baseUrl$_providerRatings/provider/$providerId');

      print('Rating API response: ${response.data}');
      final data = response.data ?? {};
      final averageRating = (data['averageRating'] ?? 0.0).toDouble();
      print('Average rating: $averageRating');

      return averageRating;
    } catch (e) {
      print('Error in getProviderAverageRating: $e');
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
                return 'غير مصرح، يرجى تسجيل الدخول مرة أخرى';
              case 403:
                return 'غير مسموح بالوصول';
              case 404:
                return 'المزود غير موجود';
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