import 'package:dio/dio.dart';
import '../models/offer_model.dart';
import '../utils/app_config.dart';
import 'dio_service.dart';

class OffersService {
  final DioService _dioService = DioService();

  // Base URLs
  static const String _baseUrl = AppConfig.baseUrl;

  // Offers endpoints
  static const String _offers = '/offers';
  static const String _myOffers = '/offers/my-offers';
  static const String _providerServices = '/provider-service';

  // جلب خدمات المزود (للعروض)
  Future<List<ProviderServiceModel>> getProviderServicesForOffers() async {
    try {
      final response = await _dioService.get('$_baseUrl$_providerServices');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => ProviderServiceModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب عروضي
  Future<List<OfferModel>> getMyOffers() async {
    try {
      final response = await _dioService.get('$_baseUrl$_myOffers');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => OfferModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إنشاء عرض جديد
  Future<OfferModel> createOffer(CreateOfferRequest request) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl$_offers',
        data: request.toJson(),
      );

      return OfferModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // حذف عرض
  Future<void> deleteOffer(int offerId) async {
    try {
      await _dioService.delete('$_baseUrl$_offers/$offerId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تحديث عرض
  Future<OfferModel> updateOffer(int offerId, UpdateOfferRequest request) async {
    try {
      final response = await _dioService.put(
        '$_baseUrl$_offers/$offerId',
        data: request.toJson(),
      );

      return OfferModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تبديل حالة العرض (تفعيل/تعطيل)
  Future<OfferModel> toggleOfferStatus(int offerId) async {
    try {
      final response = await _dioService.put('$_baseUrl$_offers/$offerId/toggle');

      return OfferModel.fromJson(response.data);
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
                return 'غير مصرح، يرجى تسجيل الدخول مرة أخرى';
              case 403:
                return 'غير مسموح بالوصول';
              case 404:
                return 'العرض غير موجود';
              case 409:
                return data?['message'] ?? 'العرض موجود مسبقاً لهذه الخدمة';
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