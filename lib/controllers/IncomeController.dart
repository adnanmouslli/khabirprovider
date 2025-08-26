import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/invoice_model.dart';
import '../services/invoices_service.dart';
import '../utils/app_config.dart';

class IncomeController extends GetxController {
  final InvoicesService _invoicesService = InvoicesService();
  var incomeRecords = <Map<String, dynamic>>[].obs;
  var completedRequests = 0.obs;
  var grossIncome = 0.0.obs;
  var afterCommission = 0.0.obs;
  var isLoading = false.obs;
  var invoices = <InvoiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInvoicesFromAPI();
  }

  Future<void> loadInvoicesFromAPI() async {
    try {
      isLoading.value = true;
      invoices.value = await _invoicesService.getProviderInvoices();
      incomeRecords.value = invoices.map((invoice) => _invoiceToIncomeFormat(invoice)).toList();
      calculateStatistics();
    } catch (e) {
      _showErrorSnackbar('خطأ في جلب الفواتير', e.toString());
      loadSampleData();
    } finally {
      isLoading.value = false;
    }
  }

  // تحويل الفاتورة الجديدة إلى تنسيق الدخل
  Map<String, dynamic> _invoiceToIncomeFormat(InvoiceModel invoice) {
    final order = invoice.order;

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
      'id': invoice.id.toString(),
      'customerName': order.user.name,
      'phone': order.user.phone,
      'profileImage': order.user.image.isNotEmpty
          ? order.user.image.startsWith('/uploads')
          ? 'https://your-api-domain.com${order.user.image}' // تحديث بالدومين الحقيقي
          : order.user.image
          : 'assets/images/profile1.jpg',
      'state': order.user.state ?? 'غير محدد',
      'category': category,
      'type': type,
      'number': order.quantity,
      'duration': order.scheduledDate != null
          ? '${order.scheduledDate!.day}/${order.scheduledDate!.month}/${order.scheduledDate!.year}'
          : 'غير محدد',
      'totalPrice': invoice.totalAmount,
      'commission': invoice.commissionAmount,
      'afterCommission': invoice.providerAmount,
      'paymentStatus': invoice.paymentStatus == 'paid' ? 'Paid' : 'Not paid',
      'completedDate': invoice.paymentDate ?? order.orderDate,
      'originalInvoice': invoice,
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
      'servicesBreakdown': order.servicesBreakdown.map((s) => {
        'serviceTitle': s.serviceTitle,
        'serviceDescription': s.serviceDescription,
        'quantity': s.quantity,
        'totalPrice': s.totalPrice,
      }).toList(),
    };
  }

  void loadSampleData() {
    incomeRecords.value = [
      {
        'id': '66548722',
        'customerName': 'Samer Bakour',
        'phone': '+968 XXX XXX XXX',
        'profileImage': 'assets/images/profile1.jpg',
        'state': 'Suhar',
        'category': 'كهربا',
        'type': 'غيير لمبات',
        'number': 2,
        'duration': '7/5/2025',
        'totalPrice': 36.0,
        'commission': 6.0,
        'afterCommission': 30.0,
        'paymentStatus': 'Paid',
        'completedDate': DateTime.now().subtract(const Duration(days: 1)),
        'isMultipleServices': false,
        'services': [],
        'servicesCount': 1,
      },
      {
        'id': '66548723',
        'customerName': 'Ahmad Ali',
        'phone': '+968 XXX XXX XXX',
        'profileImage': 'assets/images/profile2.jpg',
        'state': 'Muscat',
        'category': 'كهربا',
        'type': 'غيير لمبات',
        'number': 2,
        'duration': '7/5/2025',
        'totalPrice': 36.0,
        'commission': 6.0,
        'afterCommission': 30.0,
        'paymentStatus': 'Not paid',
        'completedDate': DateTime.now().subtract(const Duration(days: 2)),
        'isMultipleServices': false,
        'services': [],
        'servicesCount': 1,
      },
    ];
    calculateStatistics();
  }

  // عرض تفاصيل الخدمات المتعددة
  void viewServicesDetails(String recordId) {
    final record = incomeRecords.firstWhereOrNull((r) => r['id'] == recordId);
    if (record == null) {
      _showErrorSnackbar('خطأ', 'الفاتورة غير موجودة');
      return;
    }

    final isMultipleServices = record['isMultipleServices'] ?? false;
    final services = record['services'] as List<dynamic>? ?? [];

    if (!isMultipleServices || services.isEmpty) {
      Get.snackbar(
        'معلومات الخدمات',
        'هذه الفاتورة تحتوي على خدمة واحدة فقط',
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
              Text('الفاتورة رقم: ${record['id']}'),
              Text('العميل: ${record['customerName']}'),
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إجمالي الكمية: ${record['totalServicesQuantity']} قطعة',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'إجمالي السعر: ${record['totalPrice']} OMR',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'العمولة: ${record['commission']} OMR',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'صافي الدخل: ${record['afterCommission']} OMR',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
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

  // الحصول على ملخص الخدمات
  String getServicesSummary(Map<String, dynamic> record) {
    final isMultiple = record['isMultipleServices'] ?? false;
    final services = record['services'] as List<dynamic>? ?? [];

    if (!isMultiple || services.isEmpty) {
      return record['category'] ?? 'خدمة';
    }

    if (services.length == 1) {
      return services.first['serviceTitle'] ?? 'خدمة';
    }

    return '${services.first['serviceTitle']} + ${services.length - 1} أخرى';
  }

  void calculateStatistics() {
    completedRequests.value = incomeRecords.length;
    grossIncome.value = incomeRecords.fold(
        0.0, (sum, record) => sum + (record['totalPrice'] as double));
    afterCommission.value = incomeRecords.fold(
        0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  Future<void> contactAdminForPayment(String recordId) async {
    try {
      final record = incomeRecords.firstWhereOrNull((r) => r['id'] == recordId);
      if (record == null) {
        _showErrorSnackbar('خطأ', 'الفاتورة غير موجودة');
        return;
      }
      final double amount = record['afterCommission'] as double;
      final originalInvoice = record['originalInvoice'] as InvoiceModel;
      await _openWhatsAppFallback(recordId, amount);
      // Simulate admin confirmation (in production, wait for backend update)
      await _invoicesService.updatePaymentStatus(originalInvoice.id, 'paid');
      await refreshIncomeData();
      _showSuccessSnackbar('تم الطلب', 'تم إرسال طلب الدفع بنجاح');
    } catch (e) {
      _showErrorSnackbar('خطأ', 'حدث خطأ أثناء محاولة التواصل مع الإدارة');
    }
  }

  Future<void> _openWhatsAppFallback(String recordId, double amount) async {
    final String message = Uri.encodeComponent(
        'مرحباً، أريد استلام عمولتي للطلب رقم: $recordId بقيمة $amount OMR');
    final String whatsappUrl =
        'https://wa.me/${AppConfig.supportWhatsAppNumber}?text=$message';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
      _showSuccessSnackbar('تم فتح واتساب', 'يمكنك الآن التواصل مع الإدارة');
    } else {
      _showErrorSnackbar('خطأ', 'لا يمكن فتح واتساب. تأكد من وجود التطبيق على جهازك');
    }
  }

  List<Map<String, dynamic>> get paidRecords {
    return incomeRecords
        .where((record) => record['paymentStatus'].toString().toLowerCase() == 'paid')
        .toList();
  }

  List<Map<String, dynamic>> get unpaidRecords {
    return incomeRecords
        .where((record) => record['paymentStatus'].toString().toLowerCase() == 'not paid')
        .toList();
  }

  double get totalPaidAmount {
    return paidRecords.fold(
        0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  double get totalUnpaidAmount {
    return unpaidRecords.fold(
        0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  double get totalCommissionAmount {
    return incomeRecords.fold(
        0.0, (sum, record) => sum + (record['commission'] as double));
  }

  void filterByPaymentStatus(String status) {
    if (status.toLowerCase() == 'all') {
      loadInvoicesFromAPI();
    } else {
      final filteredRecords = incomeRecords.where((record) =>
      record['paymentStatus'].toString().toLowerCase() == status.toLowerCase()).toList();
      incomeRecords.value = filteredRecords;
    }
    calculateStatistics();
  }

  void filterByDateRange(DateTime startDate, DateTime endDate) {
    final filteredRecords = incomeRecords.where((record) {
      final recordDate = record['completedDate'] as DateTime;
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    incomeRecords.value = filteredRecords;
    calculateStatistics();
    _showInfoSnackbar(
      'تصفية التواريخ',
      'تم تصفية السجلات من ${startDate.day}/${startDate.month} إلى ${endDate.day}/${endDate.month}',
    );
  }

  void filterByCustomer(String customerName) {
    if (customerName.isEmpty) {
      loadInvoicesFromAPI();
    } else {
      final filteredRecords = incomeRecords.where((record) => record['customerName']
          .toString()
          .toLowerCase()
          .contains(customerName.toLowerCase())).toList();
      incomeRecords.value = filteredRecords;
    }
    calculateStatistics();
  }

  void filterByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      loadInvoicesFromAPI();
    } else {
      final filteredRecords = incomeRecords.where((record) =>
      record['category'].toString().toLowerCase() == category.toLowerCase()).toList();
      incomeRecords.value = filteredRecords;
    }
    calculateStatistics();
  }

  void filterByServiceType(String serviceType) {
    if (serviceType.toLowerCase() == 'all') {
      loadInvoicesFromAPI();
    } else if (serviceType.toLowerCase() == 'multiple') {
      final filteredRecords = incomeRecords.where((record) =>
      record['isMultipleServices'] == true).toList();
      incomeRecords.value = filteredRecords;
    } else if (serviceType.toLowerCase() == 'single') {
      final filteredRecords = incomeRecords.where((record) =>
      record['isMultipleServices'] != true).toList();
      incomeRecords.value = filteredRecords;
    }
    calculateStatistics();
  }

  bool canRequestPayment(String recordId) {
    final record = incomeRecords.firstWhereOrNull((r) => r['id'] == recordId);
    return record != null &&
        record['paymentStatus'].toString().toLowerCase() == 'not paid';
  }

  Map<String, dynamic> getIncomeStats(DateTime startDate, DateTime endDate) {
    final periodRecords = incomeRecords.where((record) {
      final recordDate = record['completedDate'] as DateTime;
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return {
      'totalRequests': periodRecords.length,
      'multipleServicesCount': periodRecords.where((r) => r['isMultipleServices'] == true).length,
      'singleServicesCount': periodRecords.where((r) => r['isMultipleServices'] != true).length,
      'totalGross': periodRecords.fold(
          0.0, (sum, record) => sum + (record['totalPrice'] as double)),
      'totalCommission': periodRecords.fold(
          0.0, (sum, record) => sum + (record['commission'] as double)),
      'totalNet': periodRecords.fold(
          0.0, (sum, record) => sum + (record['afterCommission'] as double)),
      'paidAmount': periodRecords
          .where((r) => r['paymentStatus'].toString().toLowerCase() == 'paid')
          .fold(0.0, (sum, record) => sum + (record['afterCommission'] as double)),
      'unpaidAmount': periodRecords
          .where((r) => r['paymentStatus'].toString().toLowerCase() == 'not paid')
          .fold(0.0, (sum, record) => sum + (record['afterCommission'] as double)),
    };
  }

  Future<void> refreshIncomeData() async {
    await loadInvoicesFromAPI();
    _showSuccessSnackbar('تم التحديث', 'تم تحديث بيانات الدخل');
  }

  double get averageCommissionRate {
    if (incomeRecords.isEmpty) return 0.0;
    final totalCommission = incomeRecords.fold(
        0.0, (sum, record) => sum + (record['commission'] as double));
    final totalGross = incomeRecords.fold(
        0.0, (sum, record) => sum + (record['totalPrice'] as double));
    if (totalGross == 0) return 0.0;
    return (totalCommission / totalGross) * 100;
  }

  // إحصائيات الخدمات المتعددة
  int get multipleServicesCount {
    return incomeRecords.where((record) => record['isMultipleServices'] == true).length;
  }

  int get singleServicesCount {
    return incomeRecords.where((record) => record['isMultipleServices'] != true).length;
  }

  double get multipleServicesIncome {
    return incomeRecords
        .where((record) => record['isMultipleServices'] == true)
        .fold(0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  double get singleServicesIncome {
    return incomeRecords
        .where((record) => record['isMultipleServices'] != true)
        .fold(0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  Future<void> clearAllFilters() async {
    await loadInvoicesFromAPI();
    _showInfoSnackbar('تم المسح', 'تم مسح جميع المرشحات');
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

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

  void _showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}