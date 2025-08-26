import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/order_model.dart';
import '../services/orders_service.dart';

class RequestsController extends GetxController {
  final OrdersService _ordersService = OrdersService();

  // Observable list of requests (converted from orders)
  var requests = <Map<String, dynamic>>[].obs;

  // Loading states
  var isLoading = false.obs;
  var isAccepting = false.obs;
  var isCompleting = false.obs;
  var isCancelling = false.obs;

  // Track which request is being processed
  var processingRequestId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }


  startLocationTrackingForOrderId(int orderId) async {
    await _ordersService.startLocationTrackingForOrderId(orderId);
  }

  // Load requests from API
  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
      final orders = await _ordersService.getProviderOrders();
      requests.value = orders.map((order) => order.toRequestFormat()).toList();
    } catch (e) {
      _showErrorSnackbar('خطأ في جلب الطلبات', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // View location on map
  void viewLocation(String requestId) async {
    final request = requests.firstWhere((req) => req['id'] == requestId, orElse: () => {});
    if (request.isEmpty) {
      Get.snackbar(
        'خطأ',
        'الطلب غير موجود',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    final location = request['location'] as Map<String, dynamic>?;

    if (location == null || location['latitude'] == null || location['longitude'] == null) {
      Get.snackbar(
        'خطأ',
        'لا توجد إحداثيات متاحة لهذا الموقع',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    final double latitude = location['latitude'] as double;
    final double longitude = location['longitude'] as double;
    final String address = location['address']?.toString() ?? 'موقع العميل';

    // إنشاء رابط Google Maps
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
        Get.snackbar(
          'الموقع',
          'يتم فتح الموقع: $address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.location_on, color: Colors.white),
        );
      } else {
        throw 'لا يمكن فتح خريطة Google';
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في فتح الخريطة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // View services details for multiple services orders
  void viewServicesDetails(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null) {
      _showErrorSnackbar('خطأ', 'الطلب غير موجود');
      return;
    }

    final services = request['services'] as List<dynamic>? ?? [];
    final isMultipleServices = request['isMultipleServices'] ?? false;

    if (!isMultipleServices || services.isEmpty) {
      Get.snackbar(
        'معلومات الخدمات',
        'هذا الطلب يحتوي على خدمة واحدة فقط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.info, color: Colors.white),
      );
      return;
    }

    // Show services details dialog
    Get.dialog(
      AlertDialog(
        title: const Text('تفاصيل الخدمات'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الطلب رقم: ${request['id']}'),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['serviceTitle'] ?? 'غير محدد',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service['serviceDescription'] ?? 'لا يوجد وصف',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('الكمية: ${service['quantity'] ?? 0}'),
                                Text('السعر: ${service['totalPrice'] ?? 0} OMR'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // Mark request as incomplete (Cancel order)
  void markIncomplete(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null || request['status'] != 'pending') {
      _showErrorSnackbar('خطأ', 'لا يمكن إلغاء هذا الطلب');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟\nسيتم إشعار العميل بذلك.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _confirmIncomplete(requestId);
              Get.back();
            },
            child: const Text(
              'تأكيد الإلغاء',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Accept request
  Future<void> acceptRequest(String requestId) async {
    try {
      isAccepting.value = true;
      processingRequestId.value = requestId;

      final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        throw Exception('الطلب غير موجود');
      }

      final originalOrder = request['originalOrder'] as OrderModel;
      await _ordersService.acceptOrder(originalOrder.id);

      _updateRequestStatus(requestId, 'accepted');
      _showSuccessSnackbar('تم القبول', 'تم قبول الطلب بنجاح');
    } catch (e) {
      _showErrorSnackbar('خطأ في قبول الطلب', e.toString());
    } finally {
      isAccepting.value = false;
      processingRequestId.value = null;
    }
  }

  // Confirm marking as incomplete (Cancel order via API)
  Future<void> _confirmIncomplete(String requestId) async {
    try {
      isCancelling.value = true;
      processingRequestId.value = requestId;

      final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        throw Exception('الطلب غير موجود');
      }

      final originalOrder = request['originalOrder'] as OrderModel;
      await _ordersService.cancelOrder(originalOrder.id);

      _updateRequestStatus(requestId, 'incomplete');
      _showSuccessSnackbar('تم الإلغاء', 'تم إلغاء الطلب بنجاح');
    } catch (e) {
      _showErrorSnackbar('خطأ في إلغاء الطلب', e.toString());
    } finally {
      isCancelling.value = false;
      processingRequestId.value = null;
    }
  }

  Future<void> _confirmComplete(String requestId) async {
    try {
      isCompleting.value = true;
      processingRequestId.value = requestId;

      final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        throw Exception('الطلب غير موجود');
      }

      final originalOrder = request['originalOrder'] as OrderModel;
      await _ordersService.completeOrder(originalOrder.id);

      _updateRequestStatus(requestId, 'completed', additionalData: {
        'completedDate': DateTime.now(),
      });

      _showSuccessSnackbar(
        'تم بنجاح!',
        'تم إكمال الطلب بنجاح. تم إضافة ${request['totalPrice']} OMR إلى رصيدك',
      );
    } catch (e) {
      _showErrorSnackbar('خطأ في إكمال الطلب', e.toString());
    } finally {
      isCompleting.value = false;
      processingRequestId.value = null;
    }
  }

  // Mark request as complete
  void markComplete(String requestId) {
    // تحقق من حالة الطلب قبل المتابعة
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null || (request['status'] != 'pending' && request['status'] != 'accepted')) {
      _showErrorSnackbar('خطأ', 'لا يمكن إكمال هذا الطلب');
      return;
    }

    final originalOrder = request['originalOrder'] as OrderModel;

    // Check if order is accepted first, if not - accept then complete
    if (originalOrder.status == 'pending') {
      Get.dialog(
        AlertDialog(
          title: const Text('قبول وإكمال الطلب'),
          content: const Text('سيتم قبول الطلب أولاً ثم تأكيد إكماله.\nهل تريد المتابعة؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                _acceptThenComplete(requestId);
                Get.back();
              },
              child: const Text(
                'قبول وإكمال',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.dialog(
        AlertDialog(
          title: const Text('تأكيد الإكمال'),
          content: const Text('هل تم إنجاز هذا الطلب بنجاح؟\nسيتم إشعار العميل وإضافة المبلغ إلى رصيدك.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                _confirmComplete(requestId);
                Get.back();
              },
              child: const Text(
                'تأكيد الإكمال',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Accept then complete order
  Future<void> _acceptThenComplete(String requestId) async {
    try {
      isAccepting.value = true;
      processingRequestId.value = requestId;

      final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
      if (request == null) {
        _showErrorSnackbar('خطأ', 'الطلب غير موجود');
        return;
      }

      final originalOrder = request['originalOrder'] as OrderModel;

      // First accept the order
      await _ordersService.acceptOrder(originalOrder.id);

      // Update status to accepted locally
      _updateRequestStatus(requestId, 'accepted');

      // Then complete it
      isAccepting.value = false;
      isCompleting.value = true;

      await _ordersService.completeOrder(originalOrder.id);

      // Update local state to completed
      _updateRequestStatus(requestId, 'completed', additionalData: {
        'completedDate': DateTime.now(),
      });

      _showSuccessSnackbar(
        'تم بنجاح!',
        'تم إكمال الطلب بنجاح. تم إضافة ${request['totalPrice']} OMR إلى رصيدك',
      );

    } catch (e) {
      _showErrorSnackbar('خطأ في معالجة الطلب', e.toString());
    } finally {
      isAccepting.value = false;
      isCompleting.value = false;
      processingRequestId.value = null;
    }
  }

  // Helper method to update request status correctly
  void _updateRequestStatus(String requestId, String newStatus, {Map<String, dynamic>? additionalData}) {
    final requestIndex = requests.indexWhere((req) => req['id'] == requestId);
    if (requestIndex != -1) {
      final updatedRequest = Map<String, dynamic>.from(requests[requestIndex]);
      updatedRequest['status'] = newStatus;

      // Update additional fields
      if (additionalData != null) {
        updatedRequest.addAll(additionalData);
      }

      // Update duration if needed
      final originalOrder = updatedRequest['originalOrder'] as OrderModel;
      updatedRequest['duration'] = originalOrder.duration ?? updatedRequest['duration'];

      requests[requestIndex] = updatedRequest;
      requests.refresh();
    }
  }

  // Helper method to remove request from list
  void _removeRequest(String requestId) {
    requests.removeWhere((request) => request['id'] == requestId);
  }

  // Get requests by status
  List<Map<String, dynamic>> getRequestsByStatus(String status) {
    return requests.where((request) => request['status'] == status).toList();
  }

  // Get pending requests count
  int get pendingRequestsCount {
    return requests.where((request) => request['status'] == 'pending').length;
  }

  // Get completed requests count
  int get completedRequestsCount {
    return requests.where((request) => request['status'] == 'completed').length;
  }

  // Get incomplete requests count
  int get incompleteRequestsCount {
    return requests.where((request) => request['status'] == 'incomplete').length;
  }

  // Calculate total pending amount
  double get totalPendingAmount {
    return requests
        .where((request) => request['status'] == 'pending')
        .fold(0.0, (sum, request) => sum + (request['totalPrice'] ?? 0));
  }

  // Calculate total completed amount
  double get totalCompletedAmount {
    return requests
        .where((request) => request['status'] == 'completed')
        .fold(0.0, (sum, request) => sum + (request['totalPrice'] ?? 0));
  }

  // Refresh requests list
  Future<void> refreshRequests() async {
    await loadRequests();
    _showSuccessSnackbar('تم التحديث', 'تم تحديث قائمة الطلبات');
  }

  // Filter requests by date
  void filterByDate(DateTime date) {
    // TODO: Implement date filtering
    Get.snackbar(
      'تصفية',
      'تصفية الطلبات لتاريخ ${date.day}/${date.month}/${date.year}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Search requests
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

      // Also search in services if it's a multiple services order
      final services = request['services'] as List<dynamic>? ?? [];
      bool serviceMatch = false;

      for (var service in services) {
        final serviceTitle = service['serviceTitle']?.toString().toLowerCase() ?? '';
        final serviceDesc = service['serviceDescription']?.toString().toLowerCase() ?? '';
        if (serviceTitle.contains(query.toLowerCase()) || serviceDesc.contains(query.toLowerCase())) {
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

  // Get request details
  Map<String, dynamic>? getRequestById(String requestId) {
    try {
      return requests.firstWhereOrNull((request) => request['id'] == requestId);
    } catch (e) {
      return null;
    }
  }

  // Check if request is being processed
  bool isRequestProcessing(String requestId) {
    return processingRequestId.value == requestId &&
        (isAccepting.value || isCompleting.value || isCancelling.value);
  }

  // Check if request can be cancelled
  bool canCancelRequest(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    return request != null &&
        request['status'] == 'pending' &&
        !isRequestProcessing(requestId);
  }

  // Check if request can be completed
  bool canCompleteRequest(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    return request != null &&
        (request['status'] == 'pending' || request['status'] == 'accepted') &&
        !isRequestProcessing(requestId);
  }

  // Calculate total services count for multiple services orders
  int getTotalServicesCount(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null) return 0;

    final services = request['services'] as List<dynamic>? ?? [];
    return services.fold(0, (total, service) => total + (service['quantity'] as int? ?? 0));
  }

  // Get services summary for a request
  String getServicesSummary(String requestId) {
    final request = requests.firstWhereOrNull((req) => req['id'] == requestId);
    if (request == null) return 'غير محدد';

    final isMultiple = request['isMultipleServices'] ?? false;
    final services = request['services'] as List<dynamic>? ?? [];

    if (!isMultiple || services.isEmpty) {
      return request['category'] ?? 'غير محدد';
    }

    if (services.length == 1) {
      return services.first['serviceTitle'] ?? 'غير محدد';
    }

    return '${services.first['serviceTitle']} + ${services.length - 1} أخرى';
  }

  // Show success message
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

  // Show error message
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
}