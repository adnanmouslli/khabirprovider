import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:khabir/services/language_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

import '../models/order_model.dart';
import '../services/orders_service.dart';

class RequestsController extends GetxController {
  final OrdersService _ordersService = OrdersService();

  // قائمة الطلبات القابلة للمراقبة (مُحوّلة من الطلبات)
  var requests = <Map<String, dynamic>>[].obs;

  // حالات التحميل
  var isLoading = false.obs;
  var isAccepting = false.obs;
  var isCompleting = false.obs;
  var isCancelling = false.obs;

  // تتبع الطلب الذي يتم معالجته
  var processingRequestId = Rxn<String>();

  var isStartingTracking = false.obs;
  var trackingRequestId = Rxn<String>();
  var activeTrackingRequests = <String>{}.obs; // تتبع الطلبات النشطة

  // مفتاح لحفظ بيانات التتبع في SharedPreferences
  static const String _trackingKey = 'active_tracking_requests';

  final LanguageService _languageService = Get.find<LanguageService>();

  bool get isArabic => _languageService.isArabic;

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onReady() {
    super.onReady();
    // التأكد من تحديث الـ UI بعد تحميل البيانات
    ever(activeTrackingRequests, (_) {
      print('Active tracking requests changed: $_');
    });
  }

  // تهيئة الكونترولر بالتسلسل المطلوب
  Future<void> _initializeController() async {
    // تحميل حالة التتبع أولاً
    await _loadTrackingState();
    // ثم تحميل الطلبات
    await loadRequests();
  }

  // تحميل حالة التتبع من SharedPreferences
  Future<void> _loadTrackingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trackingData = prefs.getString(_trackingKey);

      if (trackingData != null) {
        final List<dynamic> trackingList = json.decode(trackingData);
        activeTrackingRequests.value = Set<String>.from(trackingList);
        print('Loaded tracking state: ${activeTrackingRequests.value}');

        // إجبار تحديث الـ UI
        activeTrackingRequests.refresh();
      }
    } catch (e) {
      print('Error loading tracking state: $e');
    }
  }

  // حفظ حالة التتبع في SharedPreferences
  Future<void> _saveTrackingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trackingList = activeTrackingRequests.toList();
      await prefs.setString(_trackingKey, json.encode(trackingList));
      print('Saved tracking state: $trackingList');
    } catch (e) {
      print('Error saving tracking state: $e');
    }
  }

  // التحقق من صلاحيات الموقع وتفعيلها
  Future<bool> _checkAndRequestLocationPermission() async {
    try {
      // التحقق من إذن الموقع
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDialog();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationSettingsDialog();
        return false;
      }

      // التحقق من تفعيل خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool? shouldEnable = await _showLocationServiceDialog();
        if (shouldEnable == true) {
          // طلب تفعيل خدمة الموقع
          bool enabled = await Geolocator.openLocationSettings();
          if (!enabled) {
            return false;
          }

          // إعادة التحقق من الخدمة بعد محاولة تفعيلها
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            _showErrorSnackbar(
              'location_error'.tr.isNotEmpty
                  ? 'location_error'.tr
                  : 'خطأ في الموقع',
              'location_service_required'.tr.isNotEmpty
                  ? 'location_service_required'.tr
                  : 'يجب تفعيل خدمة الموقع لبدء التتبع',
            );
            return false;
          }
        } else {
          return false;
        }
      }

      // اختبار الحصول على الموقع للتأكد من أن كل شيء يعمل
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        );
        print('Current location: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        print('Error getting location: $e');
        _showErrorSnackbar(
          'location_error'.tr.isNotEmpty
              ? 'location_error'.tr
              : 'خطأ في الموقع',
          'unable_to_get_location'.tr.isNotEmpty
              ? 'unable_to_get_location'.tr
              : 'لا يمكن الحصول على موقعك الحالي',
        );
        return false;
      }

      return true;
    } catch (e) {
      print('Location permission error: $e');
      _showErrorSnackbar(
        'location_error'.tr.isNotEmpty ? 'location_error'.tr : 'خطأ في الموقع',
        'location_permission_error'.tr.isNotEmpty
            ? 'location_permission_error'.tr
            : 'حدث خطأ أثناء التحقق من صلاحيات الموقع',
      );
      return false;
    }
  }

  // عرض حوار طلب إذن الموقع
  void _showLocationPermissionDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 24.0,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'location_permission_required'.tr.isNotEmpty
                    ? 'location_permission_required'.tr
                    : 'إذن الموقع مطلوب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    'location_permission_message'.tr.isNotEmpty
                        ? 'location_permission_message'.tr
                        : 'يجب السماح للتطبيق بالوصول إلى موقعك لبدء تتبع الطلبية',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      openAppSettings();
                    },
                    child: Text(
                        'settings'.tr.isNotEmpty ? 'settings'.tr : 'الإعدادات'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // عرض حوار إعدادات الموقع للصلاحيات المرفوضة نهائياً
  void _showLocationSettingsDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 24.0,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'location_permission_denied'.tr.isNotEmpty
                    ? 'location_permission_denied'.tr
                    : 'إذن الموقع مرفوض',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    'location_permission_denied_message'.tr.isNotEmpty
                        ? 'location_permission_denied_message'.tr
                        : 'تم رفض إذن الموقع نهائياً. يرجى الذهاب إلى إعدادات التطبيق وتفعيل صلاحية الموقع.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      openAppSettings();
                    },
                    child: Text('open_settings'.tr.isNotEmpty
                        ? 'open_settings'.tr
                        : 'فتح الإعدادات'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // عرض حوار تفعيل خدمة الموقع
  Future<bool?> _showLocationServiceDialog() async {
    return await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 24.0,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'location_service_disabled'.tr.isNotEmpty
                    ? 'location_service_disabled'.tr
                    : 'خدمة الموقع معطلة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    'location_service_message'.tr.isNotEmpty
                        ? 'location_service_message'.tr
                        : 'يجب تفعيل خدمة الموقع (GPS) في إعدادات الجهاز لبدء تتبع الطلبية.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text('cancel'.tr),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text('enable'.tr.isNotEmpty ? 'enable'.tr : 'تفعيل'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بدء تتبع الموقع لطلب معين
  startLocationTrackingForOrderId(int orderId) async {
    await _ordersService.startLocationTrackingForOrderId(orderId);
  }

  // دالة بدء تتبع الطلبية
  Future<void> startLocationTracking(String requestId) async {
    try {
      isStartingTracking.value = true;
      trackingRequestId.value = requestId;

      // التحقق من صلاحيات الموقع وتفعيلها أولاً
      bool locationReady = await _checkAndRequestLocationPermission();
      if (!locationReady) {
        _showErrorSnackbar(
          'tracking_error'.tr.isNotEmpty
              ? 'tracking_error'.tr
              : 'خطأ في التتبع',
          'location_setup_failed'.tr.isNotEmpty
              ? 'location_setup_failed'.tr
              : 'فشل في إعداد الموقع. يرجى المحاولة مرة أخرى.',
        );
        return;
      }

      // التحقق من وجود الطلب
      final request =
          requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        throw Exception('no_data'.tr);
      }

      // التحقق من حالة الطلب
      if (request['status'] != 'accepted') {
        throw Exception('يجب أن يكون الطلب مقبولاً لبدء التتبع');
      }

      // الحصول على معرف الطلب الأصلي
      final originalOrder = request['originalOrder'] as OrderModel;
      final orderId = originalOrder.id;

      print('Starting location tracking for order ID: $orderId');

      // استدعاء خدمة بدء التتبع
      await startLocationTrackingForOrderId(orderId);

      // إضافة الطلب إلى قائمة التتبع النشط
      activeTrackingRequests.add(requestId);

      // حفظ حالة التتبع
      await _saveTrackingState();

      _showSuccessSnackbar(
        'tracking_started'.tr.isNotEmpty ? 'tracking_started'.tr : 'بدء التتبع',
        'tracking_started_message'.tr.isNotEmpty
            ? 'tracking_started_message'.tr
            : 'تم بدء تتبع موقعك للطلبية #$requestId',
      );

      print('Location tracking started successfully for request: $requestId');
    } catch (e) {
      print('Error starting location tracking: $e');

      String errorMessage;
      if (e.toString().contains('يجب أن يكون الطلب مقبولاً')) {
        errorMessage = 'يجب أن يكون الطلب مقبولاً لبدء التتبع';
      } else if (e.toString().contains('no_data')) {
        errorMessage = 'الطلب غير موجود';
      } else {
        errorMessage = 'فشل في بدء تتبع الموقع: ${e.toString()}';
      }

      _showErrorSnackbar(
        'tracking_error'.tr.isNotEmpty ? 'tracking_error'.tr : 'خطأ في التتبع',
        errorMessage,
      );
    } finally {
      isStartingTracking.value = false;
      trackingRequestId.value = null;
    }
  }

  // التحقق من حالة التتبع للطلب
  bool isTrackingStarted(String requestId) {
    return activeTrackingRequests.contains(requestId);
  }

  // إيقاف تتبع الطلبية
  Future<void> stopLocationTracking(String requestId) async {
    try {
      // إزالة الطلب من قائمة التتبع النشط
      activeTrackingRequests.remove(requestId);

      // حفظ حالة التتبع
      await _saveTrackingState();

      _showSuccessSnackbar(
        'tracking_stopped'.tr.isNotEmpty
            ? 'tracking_stopped'.tr
            : 'إيقاف التتبع',
        'tracking_stopped_message'.tr.isNotEmpty
            ? 'tracking_stopped_message'.tr
            : 'تم إيقاف تتبع الموقع للطلبية #$requestId',
      );

      print('Location tracking stopped for request: $requestId');
    } catch (e) {
      print('Error stopping location tracking: $e');
      _showErrorSnackbar(
        'tracking_error'.tr.isNotEmpty ? 'tracking_error'.tr : 'خطأ في التتبع',
        'فشل في إيقاف تتبع الموقع',
      );
    }
  }

  // إيقاف جميع عمليات التتبع النشطة
  Future<void> stopAllLocationTracking() async {
    try {
      activeTrackingRequests.clear();
      await _saveTrackingState();
      print('All location tracking stopped');
    } catch (e) {
      print('Error stopping all location tracking: $e');
    }
  }

  // تحديد إذا كان الطلب لا يزال صالحاً للتتبع
  Future<void> _validateTrackingRequests() async {
    try {
      final requestsToRemove = <String>[];

      for (String requestId in activeTrackingRequests) {
        final request =
            requests.firstWhereOrNull((req) => req['id'] == requestId);

        // إذا كان الطلب غير موجود أو مكتمل أو ملغى، قم بإزالته من التتبع
        if (request == null ||
            request['status'] == 'completed' ||
            request['status'] == 'incomplete') {
          requestsToRemove.add(requestId);
        }
      }

      // إزالة الطلبات غير الصالحة من التتبع
      if (requestsToRemove.isNotEmpty) {
        for (String requestId in requestsToRemove) {
          activeTrackingRequests.remove(requestId);
        }
        await _saveTrackingState();
        print('Removed invalid tracking requests: $requestsToRemove');
      }
    } catch (e) {
      print('Error validating tracking requests: $e');
    }
  }

  // تحميل الطلبات من الـ API
  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
      final orders = await _ordersService.getProviderOrders();
      requests.value = orders.map((order) => order.toRequestFormat()).toList();

      // التحقق من صحة طلبات التتبع بعد تحميل الطلبات
      await _validateTrackingRequests();
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // عرض الموقع على الخريطة
  void viewLocation(String requestId) async {
    final request =
        requests.firstWhere((req) => req['id'] == requestId, orElse: () => {});
    if (request.isEmpty) {
      _showErrorSnackbar('error'.tr, 'no_data'.tr);
      return;
    }

    final location = request['location'] as Map<String, dynamic>?;

    if (location == null ||
        location['latitude'] == null ||
        location['longitude'] == null) {
      _showErrorSnackbar('error'.tr, 'no_data'.tr);
      return;
    }

    final double latitude = (location['latitude'] as num).toDouble();
    final double longitude = (location['longitude'] as num).toDouble();
    final String address = location['address']?.toString() ?? 'location'.tr;

    // إنشاء رابط Google Maps
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    try {
      print(googleMapsUrl.toString());

      try {
        await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        _showErrorSnackbar('error'.tr, 'error'.tr);
      }
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    }
  }

  // عرض تفاصيل الخدمات للطلبات متعددة الخدمات
  void viewServicesDetails(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null) {
      _showErrorSnackbar('error'.tr, 'no_data'.tr);
      return;
    }

    final services = request['services'] as List<dynamic>? ?? [];
    final isMultipleServices = request['isMultipleServices'] ?? false;

    if (!isMultipleServices || services.isEmpty) {
      _showErrorSnackbar('services_info'.tr, 'single_service_only'.tr);
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 24.0,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
            maxWidth: Get.width * 0.9,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'services_details'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('order_number'.tr + ': ${request['id']}'),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          // ✅ عرض العنوان حسب اللغة
                          final serviceTitle = isArabic
                              ? service['serviceTitleAr'] ??
                                  service['serviceTitleEn'] ??
                                  'not_specified'.tr
                              : service['serviceTitleEn'] ??
                                  service['serviceTitleAr'] ??
                                  'not_specified'.tr;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isArabic ? 
                                    service['serviceDescriptionAr'] :
                                       service['serviceDescriptionEn'] ,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('quantity'.tr +
                                          ': ${service['quantity'] ?? 0}'),
                                      Text('price'.tr +
                                          ': ${service['totalPrice'] ?? 0} ' +
                                          'omr'.tr),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('close'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // وضع علامة على الطلب كغير مكتمل (إلغاء الطلب)
  void markIncomplete(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null || request['status'] != 'pending') {
      _showErrorSnackbar('error'.tr, 'cannot_undo'.tr);
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 24.0,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'confirm_rejection'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                      'reject_order_question'.tr + '?\n' + 'cannot_undo'.tr),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('cancel'.tr),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      _confirmIncomplete(requestId);
                      Get.back();
                    },
                    child: Text(
                      'confirm_rejection'.tr,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // قبول الطلب
  Future<void> acceptRequest(String requestId) async {
    try {
      isAccepting.value = true;
      processingRequestId.value = requestId;

      final request =
          requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        throw Exception('no_data'.tr);
      }

      final originalOrder = request['originalOrder'] as OrderModel;
      await _ordersService.acceptOrder(originalOrder.id);

      _updateRequestStatus(requestId, 'accepted');
      _showSuccessSnackbar('accepted'.tr, 'order_accepted_successfully'.tr);
    } catch (e) {
      _showErrorSnackbar('accept_order_error'.tr, e.toString());
    } finally {
      isAccepting.value = false;
      processingRequestId.value = null;
    }
  }

  // تأكيد وضع علامة غير مكتمل (إلغاء الطلب عبر الـ API)
  Future<void> _confirmIncomplete(String requestId) async {
    try {
      isCancelling.value = true;
      processingRequestId.value = requestId;

      final request =
          requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        throw Exception('no_data'.tr);
      }

      final originalOrder = request['originalOrder'] as OrderModel;
      await _ordersService.cancelOrder(originalOrder.id);

      _updateRequestStatus(requestId, 'incomplete');
      _showSuccessSnackbar('rejected'.tr, 'order_rejected'.tr);
    } catch (e) {
      _showErrorSnackbar('reject_order_error'.tr, e.toString());
    } finally {
      isCancelling.value = false;
      processingRequestId.value = null;
    }
  }

  // تأكيد إكمال الطلب
  Future<void> _confirmComplete(String requestId) async {
    try {
      isCompleting.value = true;
      processingRequestId.value = requestId;

      final request =
          requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        throw Exception('no_data'.tr);
      }

      final originalOrder = request['originalOrder'] as OrderModel;
      await _ordersService.completeOrder(originalOrder.id);

      _updateRequestStatus(requestId, 'completed', additionalData: {
        'completedDate': DateTime.now(),
      });

      _showSuccessSnackbar('success'.tr, 'complate_accepted_successfully'.tr);
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isCompleting.value = false;
      processingRequestId.value = null;
    }
  }

  // وضع علامة على الطلب كمكتمل
  void markComplete(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null ||
        (request['status'] != 'pending' && request['status'] != 'accepted')) {
      _showErrorSnackbar('error'.tr, 'cannot_undo'.tr);
      return;
    }

    final originalOrder = request['originalOrder'] as OrderModel;

    if (originalOrder.status == 'pending') {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 24.0,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.8,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'accept_order'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text('accept_order_question'.tr +
                        '?\n' +
                        'confirm_acceptance'.tr),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('cancel'.tr),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        _acceptThenComplete(requestId);
                        Get.back();
                      },
                      child: Text(
                        'accept'.tr,
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 24.0,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.8,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'confirm'.tr + ' ' + 'complete'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text('complate_order_question'.tr + '?'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('cancel'.tr),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        _confirmComplete(requestId);
                        Get.back();
                      },
                      child: Text(
                        'confirm'.tr,
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  // قبول ثم إكمال الطلب
  Future<void> _acceptThenComplete(String requestId) async {
    try {
      isAccepting.value = true;
      processingRequestId.value = requestId;

      final request =
          requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        _showErrorSnackbar('error'.tr, 'no_data'.tr);
        return;
      }

      final originalOrder = request['originalOrder'] as OrderModel;

      // قبول الطلب أولاً
      await _ordersService.acceptOrder(originalOrder.id);

      // تحديث الحالة إلى مقبول محليًا
      _updateRequestStatus(requestId, 'accepted');

      // ثم إكماله
      isAccepting.value = false;
      isCompleting.value = true;

      await _ordersService.completeOrder(originalOrder.id);

      // تحديث الحالة المحلية إلى مكتمل
      _updateRequestStatus(requestId, 'completed', additionalData: {
        'completedDate': DateTime.now(),
      });

      _showSuccessSnackbar(
        'success'.tr,
        'order_accepted_successfully'.tr +
            '. ' +
            '${request['totalPrice']} ' +
            'omr'.tr,
      );
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isAccepting.value = false;
      isCompleting.value = false;
      processingRequestId.value = null;
    }
  }

  // الحصول على عدد الطلبات النشطة التي يتم تتبعها
  int get activeTrackingCount => activeTrackingRequests.length;

  void _updateRequestStatus(String requestId, String newStatus,
      {Map<String, dynamic>? additionalData}) async {
    final requestIndex = requests.indexWhere((req) => req['id'] == requestId);
    if (requestIndex != -1) {
      final updatedRequest = Map<String, dynamic>.from(requests[requestIndex]);
      updatedRequest['status'] = newStatus;

      // تحديث الحقول الإضافية
      if (additionalData != null) {
        updatedRequest.addAll(additionalData);
      }

      // إيقاف التتبع إذا تم إكمال أو إلغاء الطلب
      if (newStatus == 'completed' || newStatus == 'incomplete') {
        if (activeTrackingRequests.contains(requestId)) {
          activeTrackingRequests.remove(requestId);
          await _saveTrackingState(); // حفظ التغيير
          print(
              'Location tracking stopped for completed/cancelled request: $requestId');
        }
      }

      // تحديث المدة إذا لزم الأمر
      final originalOrder = updatedRequest['originalOrder'] as OrderModel;
      updatedRequest['duration'] =
          originalOrder.duration ?? updatedRequest['duration'];

      requests[requestIndex] = updatedRequest;
      requests.refresh();
    }
  }

  // طريقة مساعدة لإزالة طلب من القائمة
  void _removeRequest(String requestId) {
    requests.removeWhere((request) => request['id'] == requestId);
  }

  // الحصول على الطلبات حسب الحالة
  List<Map<String, dynamic>> getRequestsByStatus(String status) {
    return requests.where((request) => request['status'] == status).toList();
  }

  // الحصول على عدد الطلبات المعلقة
  int get pendingRequestsCount {
    return requests.where((request) => request['status'] == 'pending').length;
  }

  // الحصول على عدد الطلبات المكتملة
  int get completedRequestsCount {
    return requests.where((request) => request['status'] == 'completed').length;
  }

  // الحصول على عدد الطلبات غير المكتملة
  int get incompleteRequestsCount {
    return requests
        .where((request) => request['status'] == 'incomplete')
        .length;
  }

  // حساب إجمالي المبلغ المعلق
  double get totalPendingAmount {
    return requests
        .where((request) => request['status'] == 'pending')
        .fold(0.0, (sum, request) => sum + (request['totalPrice'] ?? 0));
  }

  // حساب إجمالي المبلغ المكتمل
  double get totalCompletedAmount {
    return requests
        .where((request) => request['status'] == 'completed')
        .fold(0.0, (sum, request) => sum + (request['totalPrice'] ?? 0));
  }

  // تحديث قائمة الطلبات
  Future<void> refreshRequests() async {
    await loadRequests();
    _showSuccessSnackbar('updated'.tr, 'notifications_updated'.tr);
  }

  // إعادة تحميل البيانات عند العودة للصفحة
  Future<void> onResumed() async {
    print('Page resumed - refreshing tracking state');
    await _loadTrackingState();
    activeTrackingRequests.refresh();
  }

  // تصفية الطلبات حسب التاريخ
  void filterByDate(DateTime date) {
    // TODO: تنفيذ تصفية التاريخ
    Get.snackbar(
      'filter'.tr,
      'filter'.tr + ' ' + '${date.day}/${date.month}/${date.year}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // البحث في الطلبات
  void searchRequests(String query) {
    if (query.isEmpty) {
      loadRequests();
      return;
    }

    final filteredRequests = requests.where((request) {
      final name = request['name']?.toString().toLowerCase() ?? '';
      final id = request['id']?.toString() ?? '';
      final category = request['category']?.toString().toLowerCase() ?? '';
      final type = request['type']?.toString().toLowerCase() ?? '';

      // البحث أيضًا في الخدمات إذا كان طلبًا متعدد الخدمات
      final services = request['services'] as List<dynamic>? ?? [];
      bool serviceMatch = false;

      for (var service in services) {
        final serviceTitle =
            service['serviceTitle']?.toString().toLowerCase() ?? '';
        final serviceDesc =
            service['serviceDescription']?.toString().toLowerCase() ?? '';
        if (serviceTitle.contains(query.toLowerCase()) ||
            serviceDesc.contains(query.toLowerCase())) {
          serviceMatch = true;
          break;
        }
      }

      return name.contains(query.toLowerCase()) ||
          id.contains(query) ||
          category.contains(query.toLowerCase()) ||
          type.contains(query.toLowerCase()) ||
          serviceMatch;
    }).toList();

    requests.value = filteredRequests;
  }

  // الحصول على تفاصيل الطلب
  Map<String, dynamic>? getRequestById(String requestId) {
    try {
      return requests.firstWhereOrNull((request) => request['id'] == requestId);
    } catch (e) {
      return null;
    }
  }

  // التحقق مما إذا كان الطلب قيد المعالجة
  bool isRequestProcessing(String requestId) {
    return processingRequestId.value == requestId &&
        (isAccepting.value || isCompleting.value || isCancelling.value);
  }

  // التحقق مما إذا كان يمكن إلغاء الطلب
  bool canCancelRequest(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    return request != null &&
        request['status'] == 'pending' &&
        !isRequestProcessing(requestId);
  }

  // التحقق مما إذا كان يمكن إكمال الطلب
  bool canCompleteRequest(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    return request != null &&
        (request['status'] == 'pending' || request['status'] == 'accepted') &&
        !isRequestProcessing(requestId);
  }

  // حساب إجمالي عدد الخدمات للطلبات متعددة الخدمات
  int getTotalServicesCount(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null) return 0;

    final services = request['services'] as List<dynamic>? ?? [];
    return services.fold(
        0, (total, service) => total + (service['quantity'] as int? ?? 0));
  }

  // الحصول على ملخص الخدمات للطلب
  String getServicesSummary(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null) return 'not_specified'.tr;

    final isMultiple = request['isMultipleServices'] ?? false;
    final services = request['services'] as List<dynamic>? ?? [];

    if (!isMultiple || services.isEmpty) {
      return request['category'] ?? 'not_specified'.tr;
    }

    if (services.length == 1) {
      // ✅ عرض العنوان حسب اللغة
      final serviceTitle = isArabic
          ? services.first['serviceTitleAr'] ??
              services.first['serviceTitleEn'] ??
              'not_specified'.tr
          : services.first['serviceTitleEn'] ??
              services.first['serviceTitleAr'] ??
              'not_specified'.tr;
      return serviceTitle;
    }

    // ✅ عرض أول خدمة حسب اللغة
    final firstServiceTitle = isArabic
        ? services.first['serviceTitleAr'] ??
            services.first['serviceTitleEn'] ??
            'not_specified'.tr
        : services.first['serviceTitleEn'] ??
            services.first['serviceTitleAr'] ??
            'not_specified'.tr;

    return '$firstServiceTitle + ${services.length - 1} ' + 'others'.tr;
  }

  // إظهار رسالة نجاح
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // إظهار رسالة خطأ
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  @override
  void onClose() {
    stopAllLocationTracking();
    super.onClose();
  }
}
