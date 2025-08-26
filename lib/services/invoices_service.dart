import 'package:dio/dio.dart';
import '../models/invoice_model.dart';
import '../utils/app_config.dart';
import 'dio_service.dart';

class InvoicesService {
  final DioService _dioService = DioService();

  // Base URLs
  static const String _baseUrl = AppConfig.baseUrl;

  // Invoices endpoints
  static const String _invoices = '/invoices';

  // جلب جميع فواتير المزود
  Future<List<InvoiceModel>> getProviderInvoices() async {
    try {
      final response = await _dioService.get('$_baseUrl$_invoices');

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => InvoiceModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب فاتورة معينة
  Future<InvoiceModel> getInvoiceById(int invoiceId) async {
    try {
      final response = await _dioService.get('$_baseUrl$_invoices/$invoiceId');

      return InvoiceModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تحديث حالة الدفع للفاتورة
  Future<InvoiceModel> updatePaymentStatus(int invoiceId, String status) async {
    try {
      final response = await _dioService.put(
        '$_baseUrl$_invoices/$invoiceId/payment-status',
        data: {'payoutStatus': status},
      );

      return InvoiceModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // طلب دفع العمولة
  Future<void> requestPayment(int invoiceId) async {
    try {
      await _dioService.post(
        '$_baseUrl$_invoices/$invoiceId/request-payment',
        data: {'requestedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // جلب إحصائيات الفواتير
  Future<Map<String, dynamic>> getInvoiceStats() async {
    try {
      final response = await _dioService.get('$_baseUrl$_invoices/stats');

      return response.data ?? {};
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تصفية الفواتير حسب الحالة
  Future<List<InvoiceModel>> getInvoicesByStatus(String status) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl$_invoices',
        queryParameters: {'payoutStatus': status},
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => InvoiceModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تصفية الفواتير حسب التاريخ
  Future<List<InvoiceModel>> getInvoicesByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final response = await _dioService.get(
        '$_baseUrl$_invoices',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      final List<dynamic> data = response.data ?? [];
      return data.map((json) => InvoiceModel.fromJson(json)).toList();
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
                return 'الفاتورة غير موجودة';
              case 409:
                return data?['message'] ?? 'تعارض في حالة الفاتورة';
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