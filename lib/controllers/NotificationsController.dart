import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:khabir/services/language_service.dart';
import 'package:khabir/utils/app_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';
import '../services/orders_service.dart';

class NotificationsController extends GetxController {
  final OrdersService _ordersService = OrdersService();

  // Observable lists
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  final LanguageService _languageService = Get.find<LanguageService>();

  bool get isArabic => _languageService.isArabic;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // Load notifications from pending orders
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      print('Loading notifications from pending orders...');

      final orders = await _ordersService.getProviderOrders();

      // Filter pending orders only
      final pendingOrders = orders
          .where((order) => order.status.toLowerCase() == 'pending')
          .toList();

      // Convert orders to notifications
      notifications.value =
          pendingOrders.map((order) => _toNotification(order)).toList();

      print('Loaded ${notifications.length} notifications');
    } catch (e) {
      print('Error loading notifications: $e');
      _showErrorSnackbar('notification_load_error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Convert OrderModel to notification format
  Map<String, dynamic> _toNotification(OrderModel order) {
    // Handle multiple services
    String category = '';
    String type = '';

    if (order.isMultipleServices && order.services.isNotEmpty) {
      // ✅ استخدام getTitle() للحصول على العنوان حسب اللغة
      category = order.services.first.category?.titleAr ??
          order.services.first.getTitle();
      type = order.services.first.serviceDescription ?? '';
    } else if (order.services.isNotEmpty) {
      // ✅ للخدمة الواحدة
      category = order.services.first.category?.titleAr ??
          order.services.first.getTitle();
      type = order.services.first.serviceDescription ?? '';
    } else {
      // Fallback for old system
      category = 'service'.tr;
      type = 'not_specified'.tr;
    }

    return {
      'orderId': order.id,
      'category': category,
      'type': type,
      'number': order.quantity,
      'duration': order.duration ??
          (order.scheduledDate != null
              ? '${order.scheduledDate!.day}/${order.scheduledDate!.month}/${order.scheduledDate!.year}'
              : 'now'.tr),
      'price': order.providerAmount,
      'state': order.user.state ?? 'not_specified'.tr,
      'customerName': order.user.name,
      'customerPhone': order.user.phone,
      'requestTime': order.orderDate,
      'priority': _getPriority(order),
      'location': {
        'latitude': order.providerLocation?.lat ?? order.user.latitude ?? 0.0,
        'longitude': order.providerLocation?.lng ?? order.user.longitude ?? 0.0,
        'address':
            order.locationDetails ?? order.location ?? 'not_specified'.tr,
      },
      'status': order.status.toLowerCase(),
      'originalOrder': order,
      // Multiple services information
      'isMultipleServices': order.isMultipleServices,
      'services': order.services
          .map((s) => {
                'serviceTitleAr': s.serviceTitleAr,
                'serviceTitleEn': s.serviceTitleEn,
                'serviceTitle': s.getTitle(),
                'serviceDescription': s.serviceDescription,
                'quantity': s.quantity,
                'totalPrice': s.totalPrice,
                'unitPrice': s.unitPrice,
                'commission': s.commission,
                'serviceId': s.serviceId,
                'serviceImage': s.serviceImage,
                'category': s.category?.titleAr,
              })
          .toList(),
      'servicesCount': order.services.length,
      'totalServicesQuantity':
          order.services.fold(0, (sum, s) => sum + s.quantity),
    };
  }

  // Determine priority based on logic
  String _getPriority(OrderModel order) {
    if (order.providerAmount > 1000) return 'high';
    if (order.providerAmount > 500) return 'medium';
    return 'low';
  }

  void viewServicesDetails(int index) {
    if (index < 0 || index >= notifications.length) return;

    final notification = notifications[index];
    final isMultipleServices = notification['isMultipleServices'] ?? false;
    final services = notification['services'] as List<dynamic>? ?? [];

    if (!isMultipleServices || services.isEmpty) {
      Get.snackbar(
        'services_info'.tr,
        'single_service_only'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.info, color: Colors.white),
      );
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Container(
          width: Get.width * 0.92,
          height: Get.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Column(
            children: [
              // Header رسمي ومبسط
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'order_details'.tr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${services.length} ${'services_count_text'.tr}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 22,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // المحتوى القابل للتمرير
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // قائمة الخدمات
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, serviceIndex) {
                          final service = services[serviceIndex];
                          return _buildServiceCard(service, serviceIndex);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // أزرار العمل
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side:
                              BorderSide(color: Colors.grey[300]!, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'dialog_close'.tr,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          acceptNotification(index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[900],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'dialog_accept_order'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // بناء صف معلومات الملخص
  Widget _buildSummaryRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: isPrice ? Colors.grey[900] : Colors.grey[800],
            fontWeight: isPrice ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // بناء كارت الخدمة المحسن
  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    String serviceName = isArabic
        ? service['serviceTitleAr'] ??
            service['serviceTitleEn'] ??
            service['serviceTitle'] ??
            'خدمة غير محددة'
        : service['serviceTitleEn'] ??
            service['serviceTitleAr'] ??
            service['serviceTitle'] ??
            'Service not specified';

    // استخراج باقي المعلومات
    String quantity = '${service['quantity'] ?? 0}';
    String price =
        '${service['totalPrice'] ?? service['unitPrice'] ?? service['price'] ?? 0} ${'omr'.tr}';
    String description =
        service['serviceDescription'] ?? service['description'] ?? '';
    String? imageUrl = service['serviceImage'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الخدمة
          Row(
            children: [
              // صورة الخدمة إن وجدت
              if (imageUrl != null && imageUrl.isNotEmpty)
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl.startsWith('http')
                          ? imageUrl
                          : '${AppConfig.imageBaseUrl}$imageUrl'),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                      ),
                    ),
                  
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // تفاصيل الخدمة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                _buildServiceDetailRow('quantity'.tr, quantity),
                const SizedBox(height: 8),
                _buildServiceDetailRow('total_price'.tr, price),
                if (service['unitPrice'] != null) ...[
                  const SizedBox(height: 8),
                  _buildServiceDetailRow(
                      'total_price'.tr, '${service['unitPrice']} ${'omr'.tr}'),
                ],
                if (service['commission'] != null) ...[
                  const SizedBox(height: 8),
                  _buildServiceDetailRow(
                      'commission'.tr, '${service['commission']} ${'omr'.tr}'),
                ],
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildServiceDetailRow('description'.tr, description),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء صف تفاصيل الخدمة
  Widget _buildServiceDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Accept notification/order
  Future<void> acceptNotification(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      final orderId = notification['orderId'] as int;
      final isMultipleServices = notification['isMultipleServices'] ?? false;
      final servicesCount = notification['servicesCount'] ?? 1;

      // Create custom text for multiple services
      String contentText = '';
      if (isMultipleServices) {
        contentText =
            '${'accept_order_question'.tr} ${notification['type']} ${'in'.tr} ${notification['state']}?\n'
            '${'services_count'.tr}: $servicesCount ${'service'.tr}\n'
            '${'total_quantity'.tr}: ${notification['totalServicesQuantity']}\n'
            '${'total_price'.tr}: ${notification['price']} ${'omr'.tr}';
      } else {
        contentText =
            '${'accept_order_question'.tr} ${notification['type']} ${'in'.tr} ${notification['state']}?\n'
            '${'price'.tr}: ${notification['price']} ${'omr'.tr}\n'
            '${'quantity'.tr}: ${notification['number']}';
      }

      Get.dialog(
        _buildCustomDialog(
          title: 'confirm_acceptance'.tr,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          content: Text(
            contentText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          actions: [
            _buildCustomButton(
              text: 'cancel'.tr,
              onPressed: () => Get.back(),
            ),
         
            _buildCustomButton(
              text: 'accept'.tr,
              isSuccess: true,
              onPressed: () {
                Get.back();
                _confirmAcceptNotification(index, orderId);
              },
            ),
          ],
        ),
      );
    }
  }

  // Confirm accept order
  Future<void> _confirmAcceptNotification(int index, int orderId) async {
    try {
      isLoading.value = true;
      print('Accepting order: $orderId');

      // Call API to accept order
      await _ordersService.acceptOrder(orderId);

      // Remove notification from list
      notifications.removeAt(index);

      // رسالة نجاح محسنة بخلفية بيضاء
      Get.rawSnackbar(
        titleText: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'accepted'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'order_accepted_successfully'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.transparent,
      );
    } catch (e) {
      print('Error accepting order: $e');

      // رسالة خطأ محسنة بخلفية بيضاء
      Get.rawSnackbar(
        titleText: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'accept_order_error'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      e.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.transparent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reject notification/order
  Future<void> rejectNotification(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      final orderId = notification['orderId'] as int;
      final isMultipleServices = notification['isMultipleServices'] ?? false;
      final servicesCount = notification['servicesCount'] ?? 1;

      String contentText = '';
      if (isMultipleServices) {
        contentText =
            '${'reject_order_question'.tr} ${notification['type']} ${'in'.tr} ${notification['state']}?\n'
            '${'services_count'.tr}: $servicesCount ${'service'.tr}\n'
            '${'cannot_undo'.tr}';
      } else {
        contentText =
            '${'reject_order_question'.tr} ${notification['type']} ${'in'.tr} ${notification['state']}?\n'
            '${'cannot_undo'.tr}';
      }

      Get.dialog(
        _buildCustomDialog(
          title: 'confirm_rejection'.tr,
          icon: Icons.cancel_outlined,
          iconColor: Colors.red,
          content: Text(
            contentText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          actions: [
            _buildCustomButton(
              text: 'cancel'.tr,
              onPressed: () => Get.back(),
            ),
           
            _buildCustomButton(
              text: 'reject'.tr,
              isDestructive: true,
              onPressed: () {
                Get.back();
                _confirmRejectNotification(index, orderId);
              },
            ),
          ],
        ),
      );
    }
  }

  // Confirm reject order
  Future<void> _confirmRejectNotification(int index, int orderId) async {
    try {
      isLoading.value = true;
      print('Rejecting order: $orderId');

      // Call API to reject order
      await _ordersService.rejectOrder(orderId);

      // Remove notification from list
      notifications.removeAt(index);

      Get.snackbar(
        'rejected'.tr,
        'order_rejected'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.cancel, color: Colors.white),
      );
    } catch (e) {
      print('Error rejecting order: $e');
      _showErrorSnackbar('reject_order_error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // عرض الموقع على الخريطة
  void viewLocation(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      final userLocation = notification['user'];

      if (userLocation != null) {
        final latitude = userLocation['latitude'];
        final longitude = userLocation['longitude'];
        final address = userLocation['state'];

        Get.snackbar(
          'الموقع',
          'عرض موقع العميل: $address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.location_on, color: Colors.white),
        );

        final url =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

        try {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } catch (e) {
          Get.snackbar('خطأ', 'الموقع غير متوفر');
        }
      } else {
        Get.snackbar('خطأ', 'الموقع غير متوفر');
      }
    }
  }

  // Call customer
  void callCustomer(int index) {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      final customerPhone = notification['customerPhone'];

      Get.dialog(
        _buildCustomDialog(
          title: 'call_customer'.tr,
          icon: Icons.phone_outlined,
          iconColor: Colors.blue,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'call_customer_question'.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${'phone_number'.tr}: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      customerPhone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            _buildCustomButton(
              text: 'cancel'.tr,
              onPressed: () => Get.back(),
            ),
            _buildCustomButton(
              text: 'call'.tr,
              isSuccess: true,
              icon: Icons.phone,
              onPressed: () {
                Get.back();
                // TODO: Open phone app to call
                Get.snackbar(
                  'call'.tr,
                  'opening_phone_app'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
      );
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    try {
      isRefreshing.value = true;
      await loadNotifications();

      Get.snackbar(
        'updated'.tr,
        'notifications_updated'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // Clear all notifications
  void clearAllNotifications() {
    Get.dialog(
      _buildCustomDialog(
        title: 'clear_all_notifications'.tr,
        icon: Icons.delete_sweep_outlined,
        iconColor: Colors.red,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'clear_all_confirm'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'reject_all_pending'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _buildCustomButton(
            text: 'cancel'.tr,
            onPressed: () => Get.back(),
          ),
          _buildCustomButton(
            text: 'clear'.tr,
            isDestructive: true,
            icon: Icons.delete_forever,
            onPressed: () async {
              Get.back();
              await _clearAllNotifications();
            },
          ),
        ],
      ),
    );
  }

  // Clear all notifications from server
  Future<void> _clearAllNotifications() async {
    try {
      isLoading.value = true;

      // Reject all pending orders
      for (var notification in notifications) {
        await _ordersService.rejectOrder(notification['orderId']);
      }

      notifications.clear();

      Get.snackbar(
        'cleared'.tr,
        'all_notifications_cleared'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar('clear_notifications_error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Get services summary
  // Get services summary
  String getServicesSummary(Map<String, dynamic> notification) {
    final isMultiple = notification['isMultipleServices'] ?? false;
    final services = notification['services'] as List<dynamic>? ?? [];

    if (!isMultiple || services.isEmpty) {
      return notification['category'] ?? 'service'.tr;
    }

    if (services.length == 1) {
      return isArabic
          ? services.first['serviceTitleAr'] ??
              services.first['serviceTitleEn'] ??
              services.first['serviceTitle'] ??
              'service'.tr
          : services.first['serviceTitleEn'] ??
              services.first['serviceTitleAr'] ??
              services.first['serviceTitle'] ??
              'service'.tr;
    }

    final firstServiceTitle = isArabic
        ? services.first['serviceTitleAr'] ??
            services.first['serviceTitleEn'] ??
            services.first['serviceTitle'] ??
            'service'.tr
        : services.first['serviceTitleEn'] ??
            services.first['serviceTitleAr'] ??
            services.first['serviceTitle'] ??
            'service'.tr;

    return '$firstServiceTitle + ${services.length - 1} ${'others'.tr}';
  }

  // Show error snackbar
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

  Widget _buildCustomDialog({
    required String title,
    IconData? icon,
    Color? iconColor,
    required Widget content,
    required List<Widget> actions,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.9,
          minWidth: 320,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: iconColor ?? Colors.grey[700],
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: content,
            ),

            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions
                    .map((action) => Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: action,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isDestructive = false,
    bool isSuccess = false,
    bool isSecondary = false,
  }) {
    Color backgroundColor;
    Color textColor;
    Color? borderColor;

    if (isDestructive) {
      backgroundColor = Colors.red[600]!;
      textColor = Colors.white;
    } else if (isSuccess) {
      backgroundColor = Colors.green[600]!;
      textColor = Colors.white;
    } else if (isSecondary) {
      backgroundColor = Colors.blue[600]!;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.transparent;
      textColor = Colors.grey[700]!;
      borderColor = Colors.grey[300]!;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
