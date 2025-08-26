import 'package:dio/dio.dart';
import '../models/service_model.dart';
import '../utils/app_config.dart';
import 'dio_service.dart';

class ServicesService {
  final DioService _dioService = DioService();

  // Base URLs
  static const String _baseUrl = AppConfig.baseUrl;

  // Services endpoints
  static const String _services = '/services';
  static const String _categories = '/categories';
  static const String _servicesByCategory = '/services/category';
  static const String _providerServices = '/provider-service';
  static const String _addMultipleServices = '/provider-service/add-multiple';

  // جلب جميع الخدمات
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await _dioService.get('$_baseUrl$_services');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب جميع الأصناف
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _dioService.get('$_baseUrl$_categories');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب الخدمات حسب الصنف
  Future<List<ServiceModel>> getServicesByCategory(int categoryId) async {
    try {
      final response = await _dioService.get('$_baseUrl$_servicesByCategory/$categoryId');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب خدمات المزود
  Future<List<ProviderServiceModel>> getProviderServices() async {
    try {
      final response = await _dioService.get('$_baseUrl$_providerServices');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => ProviderServiceModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إضافة خدمات متعددة للمزود
  Future<AddMultipleServicesResponse> addMultipleServices(
      List<AddServiceRequest> services,
      ) async {
    try {
      final request = AddMultipleServicesRequest(services: services);
      final response = await _dioService.post(
        '$_baseUrl$_addMultipleServices',
        data: request.toJson(),
      );

      return AddMultipleServicesResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تحديث سعر خدمة مزود
  Future<ProviderServiceModel> updateProviderServicePrice(
      int providerServiceId,
      double price,
      ) async {
    try {
      final response = await _dioService.put(
        '$_baseUrl$_providerServices/$providerServiceId',
        data: {
          'price': price,
        },
      );

      return ProviderServiceModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تبديل حالة خدمة المزود
  Future<ProviderServiceModel> toggleProviderServiceStatus(
      int providerServiceId,
      ) async {
    try {
      final response = await _dioService.put(
        '$_baseUrl$_providerServices/$providerServiceId/toggle',
      );

      return ProviderServiceModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // حذف خدمة مزود
  Future<void> deleteProviderService(int providerServiceId) async {
    try {
      await _dioService.delete(
        '$_baseUrl$_providerServices/$providerServiceId',
      );
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
                return 'الخدمة غير موجودة';
              case 409:
                return data?['message'] ?? 'الخدمة موجودة مسبقاً';
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