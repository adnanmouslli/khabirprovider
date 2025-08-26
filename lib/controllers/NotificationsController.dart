import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/orders_service.dart';

class NotificationsController extends GetxController {
  final OrdersService _ordersService = OrdersService();

  // Observable lists
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // تحميل الإشعارات من الطلبات المعلقة
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      print('Loading notifications from pending orders...');

      final orders = await _ordersService.getProviderOrders();

      // تصفية الطلبات المعلقة فقط
      final pendingOrders = orders.where((order) => order.status.toLowerCase() == 'pending').toList();

      // تحويل الطلبات إلى إشعارات
      notifications.value = pendingOrders.map((order) => _toNotification(order)).toList();

      print('Loaded ${notifications.length} notifications');
    } catch (e) {
      print('Error loading notifications: $e');
      _showErrorSnackbar('فشل في تحميل الإشعارات', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // تحويل OrderModel إلى تنسيق الإشعار
  Map<String, dynamic> _toNotification(OrderModel order) {
    // معالجة الخدمات المتعددة
    String category = '';
    String type = '';

    if (order.isMultipleServices && order.services.isNotEmpty) {
      // للخدمات المتعددة، استخدم الخدمة الأولى كأساس
      category = order.services.first.category?.titleAr ?? order.services.first.serviceTitle;
      type = order.services.first.serviceDescription;
    } else if (order.services.isNotEmpty) {
      // للخدمة الواحدة
      category = order.services.first.category?.titleAr ?? order.services.first.serviceTitle;
      type = order.services.first.serviceDescription;
    } else {
      // fallback للنظام القديم
      category = 'خدمة';
      type = 'غير محدد';
    }

    return {
      'orderId': order.id,
      'category': category,
      'type': type,
      'number': order.quantity,
      'duration': order.duration ?? (order.scheduledDate != null
          ? '${order.scheduledDate!.day}/${order.scheduledDate!.month}/${order.scheduledDate!.year}'
          : 'Now'),
      'price': order.providerAmount,
      'state': order.user.state ?? 'غير محدد',
      'customerName': order.user.name,
      'customerPhone': order.user.phone,
      'requestTime': order.orderDate,
      'priority': _getPriority(order),
      'location': {
        'latitude': order.providerLocation?.lat ?? order.user.latitude ?? 0.0,
        'longitude': order.providerLocation?.lng ?? order.user.longitude ?? 0.0,
        'address': order.locationDetails ?? order.location ?? 'غير محدد',
      },
      'status': order.status.toLowerCase(),
      'originalOrder': order,
      // معلومات الخدمات المتعددة
      'isMultipleServices': order.isMultipleServices,
      'services': order.services.map((s) => {
        'serviceTitle': s.serviceTitle,
        'serviceDescription': s.serviceDescription,
        'quantity': s.quantity,
        'totalPrice': s.totalPrice,
        'category': s.category?.titleAr,
      }).toList(),
      'servicesCount': order.services.length,
      'totalServicesQuantity': order.services.fold(0, (sum, s) => sum + s.quantity),
    };
  }

  // تحديد الأولوية بناءً على منطق معين
  String _getPriority(OrderModel order) {
    // يمكنك تخصيص هذا المنطق بناءً على متطلباتك
    if (order.providerAmount > 1000) return 'high';
    if (order.providerAmount > 500) return 'medium';
    return 'low';
  }

  // عرض تفاصيل الخدمات المتعددة
  void viewServicesDetails(int index) {
    if (index < 0 || index >= notifications.length) return;

    final notification = notifications[index];
    final isMultipleServices = notification['isMultipleServices'] ?? false;
    final services = notification['services'] as List<dynamic>? ?? [];

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

    // عرض نافذة تفاصيل الخدمات
    Get.dialog(
      AlertDialog(
        title: Text('تفاصيل الخدمات (${services.length} خدمة)'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الطلب رقم: ${notification['orderId']}'),
              Text('العميل: ${notification['customerName']}'),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: services.length,
                  itemBuilder: (context, serviceIndex) {
                    final service = services[serviceIndex];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    service['serviceTitle'] ?? 'غير محدد',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#${serviceIndex + 1}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service['serviceDescription'] ?? 'لا يوجد وصف',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            if (service['category'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'الفئة: ${service['category']}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('الكمية: ${service['quantity'] ?? 0}'),
                                Text(
                                  'السعر: ${service['totalPrice'] ?? 0} OMR',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المجموع الكلي: ${notification['totalServicesQuantity']} قطعة',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'إجمالي السعر: ${notification['price']} OMR',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
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

  // قبول الطلب/الإشعار
  Future<void> acceptNotification(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      final orderId = notification['orderId'] as int;
      final isMultipleServices = notification['isMultipleServices'] ?? false;
      final servicesCount = notification['servicesCount'] ?? 1;

      // إنشاء نص مخصص للخدمات المتعددة
      String contentText = '';
      if (isMultipleServices) {
        contentText = 'هل تريد قبول طلب ${notification['type']} في ${notification['state']}؟\n'
            'عدد الخدمات: $servicesCount خدمة\n'
            'إجمالي الكمية: ${notification['totalServicesQuantity']}\n'
            'السعر الإجمالي: ${notification['price']} OMR';
      } else {
        contentText = 'هل تريد قبول طلب ${notification['type']} في ${notification['state']}؟\n'
            'السعر: ${notification['price']} OMR\n'
            'العدد: ${notification['number']}';
      }

      Get.dialog(
        AlertDialog(
          title: const Text('تأكيد القبول'),
          content: Text(contentText),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            if (isMultipleServices) ...[
              TextButton(
                onPressed: () {
                  Get.back();
                  viewServicesDetails(index);
                },
                child: const Text(
                  'عرض التفاصيل',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
            TextButton(
              onPressed: () {
                Get.back();
                _confirmAcceptNotification(index, orderId);
              },
              child: const Text(
                'قبول',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
  }

  // تأكيد قبول الطلب
  Future<void> _confirmAcceptNotification(int index, int orderId) async {
    try {
      isLoading.value = true;
      print('Accepting order: $orderId');

      // استدعاء API لقبول الطلب
      await _ordersService.acceptOrder(orderId);

      // إزالة الإشعار من القائمة
      notifications.removeAt(index);

      Get.snackbar(
        'تم القبول!',
        'تم قبول الطلب بنجاح.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      print('Error accepting order: $e');
      _showErrorSnackbar('فشل في قبول الطلب', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // رفض الطلب/الإشعار
  Future<void> rejectNotification(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      final orderId = notification['orderId'] as int;
      final isMultipleServices = notification['isMultipleServices'] ?? false;
      final servicesCount = notification['servicesCount'] ?? 1;

      String contentText = '';
      if (isMultipleServices) {
        contentText = 'هل تريد رفض طلب ${notification['type']} في ${notification['state']}؟\n'
            'عدد الخدمات: $servicesCount خدمة\n'
            'لن تتمكن من التراجع عن هذا القرار.';
      } else {
        contentText = 'هل تريد رفض طلب ${notification['type']} في ${notification['state']}؟\n'
            'لن تتمكن من التراجع عن هذا القرار.';
      }

      Get.dialog(
        AlertDialog(
          title: const Text('تأكيد الرفض'),
          content: Text(contentText),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            if (isMultipleServices) ...[
              TextButton(
                onPressed: () {
                  Get.back();
                  viewServicesDetails(index);
                },
                child: const Text(
                  'عرض التفاصيل',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
            TextButton(
              onPressed: () {
                Get.back();
                _confirmRejectNotification(index, orderId);
              },
              child: const Text(
                'رفض',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  // تأكيد رفض الطلب
  Future<void> _confirmRejectNotification(int index, int orderId) async {
    try {
      isLoading.value = true;
      print('Rejecting order: $orderId');

      // استدعاء API لرفض الطلب
      await _ordersService.rejectOrder(orderId);

      // إزالة الإشعار من القائمة
      notifications.removeAt(index);

      Get.snackbar(
        'تم الرفض',
        'تم رفض الطلب.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.cancel, color: Colors.white),
      );
    } catch (e) {
      print('Error rejecting order: $e');
      _showErrorSnackbar('فشل في رفض الطلب', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // عرض الموقع على الخريطة
  void viewLocation(int index) {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      final location = notification['location'];

      Get.snackbar(
        'الموقع',
        'عرض موقع العميل: ${location['address']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.location_on, color: Colors.white),
      );

      // TODO: فتح الخريطة مع الموقع
      // يمكنك إضافة التكامل مع Google Maps هنا
    }
  }

  // الاتصال بالعميل
  void callCustomer(int index) {
    if (index >= 0 && index < notifications.length) {
      final notification = notifications[index];
      final customerPhone = notification['customerPhone'];

      Get.dialog(
        AlertDialog(
          title: const Text('الاتصال بالعميل'),
          content: Text('هل تريد الاتصال بالعميل؟\nرقم الهاتف: $customerPhone'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                // TODO: فتح تطبيق الهاتف للاتصال
                Get.snackbar(
                  'الاتصال',
                  'سيتم فتح تطبيق الهاتف للاتصال بالعميل',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
              child: const Text(
                'اتصال',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
  }

  // تحديث الإشعارات
  Future<void> refreshNotifications() async {
    try {
      isRefreshing.value = true;
      await loadNotifications();

      Get.snackbar(
        'تم التحديث',
        'تم تحديث قائمة الإشعارات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // مسح جميع الإشعارات
  void clearAllNotifications() {
    Get.dialog(
      AlertDialog(
        title: const Text('مسح جميع الإشعارات'),
        content: const Text('هل أنت متأكد من مسح جميع الإشعارات؟\nهذا سيرفض جميع الطلبات المعلقة.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _clearAllNotifications();
            },
            child: const Text(
              'مسح',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // مسح جميع الإشعارات من الخادم
  Future<void> _clearAllNotifications() async {
    try {
      isLoading.value = true;

      // رفض جميع الطلبات المعلقة
      for (var notification in notifications) {
        await _ordersService.rejectOrder(notification['orderId']);
      }

      notifications.clear();

      Get.snackbar(
        'تم المسح',
        'تم مسح جميع الإشعارات ورفض الطلبات المعلقة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar('فشل في مسح الإشعارات', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // الحصول على ملخص الخدمات
  String getServicesSummary(Map<String, dynamic> notification) {
    final isMultiple = notification['isMultipleServices'] ?? false;
    final services = notification['services'] as List<dynamic>? ?? [];

    if (!isMultiple || services.isEmpty) {
      return notification['category'] ?? 'خدمة';
    }

    if (services.length == 1) {
      return services.first['serviceTitle'] ?? 'خدمة';
    }

    return '${services.first['serviceTitle']} + ${services.length - 1} أخرى';
  }

  // عرض رسالة خطأ
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
    super.onClose();
  }
}