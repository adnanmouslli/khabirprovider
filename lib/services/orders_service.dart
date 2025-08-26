import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:khabir/services/storage_service.dart';
import '../models/order_model.dart';
import '../utils/app_config.dart';
import 'LocationTrackingService.dart';
import 'dio_service.dart';

class OrdersService {
  final DioService _dioService = DioService();
  final StorageService _storageService = Get.find<StorageService>();
  final LocationTrackingService _locationService =
      Get.find<LocationTrackingService>(); // إضافة reference

  // Base URLs
  static const String _baseUrl = AppConfig.baseUrl;

  // Orders endpoints
  static const String _orders = '/orders';
  static const String _getOrders = '/providers';

  // جلب الطلبات المعلقة (الإشعارات)

  startLocationTrackingForOrderId(int orderId) async {
    await _locationService.startLocationTracking(orderId.toString());
  }

  Future<Map<String, dynamic>> getPendingOrders() async {
    try {
      // الحصول على ID المزود من التخزين
      final providerId = _getProviderIdFromStorage();
      if (providerId == null) {
        throw Exception('لا يمكن العثور على معرف المزود');
      }

      print('Fetching pending orders for provider: $providerId');

      final response = await _dioService.get(
        '$_baseUrl$_getOrders/$providerId/orders/pending',
      );

      print('Pending orders response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error fetching pending orders: $e');
      throw _handleError(e);
    }
  }

  // جلب جميع طلبات المزود
  Future<List<OrderModel>> getProviderOrders() async {
    try {
      final response = await _dioService.get('$_baseUrl$_orders');

      if (response.statusCode == 200) {
        // تحويل البيانات إلى قائمة
        final data =
            response.data is String ? jsonDecode(response.data) : response.data;

        if (data is List) {
          // إذا كانت الاستجابة قائمة من الطلبات
          return data.map((json) => OrderModel.fromJson(json)).toList();
        } else if (data is Map<String, dynamic>) {
          // إذا كانت الاستجابة كائنًا واحدًا
          return [OrderModel.fromJson(data)];
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // قبول طلب مع بدء تتبع الموقع
  Future<OrderModel> acceptOrder(int orderId) async {
    try {
      final response = await _dioService.put(
        '$_baseUrl$_orders/$orderId/accept',
        data: {'status': 'accepted'},
      );

      final acceptedOrder = OrderModel.fromJson(response.data);

      // 🔥 بدء تتبع الموقع بعد قبول الطلب
      try {
        await _locationService.startLocationTracking(orderId.toString());
        print('✅ Location tracking started for order: $orderId');
      } catch (locationError) {
        print('⚠️ Failed to start location tracking: $locationError');
        // يمكنك إظهار تحذير للمستخدم هنا إذا أردت
      }

      return acceptedOrder;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إكمال طلب مع إيقاف تتبع الموقع
  Future<OrderModel> completeOrder(int orderId) async {
    try {
      final response = await _dioService.put(
        '$_baseUrl$_orders/$orderId/complete',
        data: {'status': 'completed'},
      );

      final completedOrder = OrderModel.fromJson(response.data);

      // 🛑 إيقاف تتبع الموقع عند إكمال الطلب
      _locationService.stopLocationTracking();
      print('✅ Location tracking stopped for completed order: $orderId');

      return completedOrder;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // إلغاء طلب مع إيقاف تتبع الموقع
  Future<OrderModel> cancelOrder(int orderId) async {
    try {
      final response = await _dioService.put(
        '$_baseUrl$_orders/$orderId/cancel',
        data: {'status': 'cancelled'},
      );

      final cancelledOrder = OrderModel.fromJson(response.data);

      // 🛑 إيقاف تتبع الموقع عند إلغاء الطلب
      _locationService.stopLocationTracking();
      print('✅ Location tracking stopped for cancelled order: $orderId');

      return cancelledOrder;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // رفض الطلب
  Future<Map<String, dynamic>> rejectOrder(int orderId) async {
    try {
      print('Rejecting order: $orderId');

      final response = await _dioService.put(
        '$_baseUrl$_orders/$orderId/reject',
        data: {
          'status': 'cancelled',
        },
      );

      if (response.statusCode == 200) {
        print('Order rejected successfully: $orderId');

        // 🛑 إيقاف تتبع الموقع عند رفض الطلب (إذا كان مفعلاً)
        if (_locationService.currentOrderId == orderId.toString()) {
          _locationService.stopLocationTracking();
          print('✅ Location tracking stopped for rejected order: $orderId');
        }

        return response.data;
      } else {
        throw Exception('Failed to reject order: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in rejectOrder: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        final errorMessage = e.response?.data['message'] ?? e.message;
        throw Exception('API Error: $errorMessage');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in rejectOrder: $e');
      throw Exception('Unexpected Error: $e');
    }
  }

  // الحصول على ID المزود من التخزين
  int? _getProviderIdFromStorage() {
    try {
      final userData = _storageService.userData;
      final providerId = userData['id'];

      if (providerId is int) {
        return providerId;
      } else if (providerId is String) {
        return int.tryParse(providerId);
      }

      return null;
    } catch (e) {
      print('Error getting provider ID from storage: $e');
      return null;
    }
  }

  // جلب تفاصيل طلب محدد
  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      print('Fetching order details for: $orderId');

      final response = await _dioService.get(
        '$_baseUrl$_orders/$orderId',
      );

      print('Order details response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error fetching order details: $e');
      throw _handleError(e);
    }
  }

  // إضافة دالة لإيقاف التتبع يدوياً (اختيارية)
  void stopLocationTracking() {
    _locationService.stopLocationTracking();
  }

  // التحقق من حالة التتبع
  bool get isLocationTracking => _locationService.isTracking;

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
                return 'غير مخول، يرجى تسجيل الدخول مرة أخرى';
              case 403:
                return 'غير مسموح بالوصول';
              case 404:
                return 'الطلب غير موجود';
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
