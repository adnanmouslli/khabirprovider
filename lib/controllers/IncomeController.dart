import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:khabir/services/language_service.dart';
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

  var supportPhone = ''.obs;
  final LanguageService _languageService = Get.find<LanguageService>();

  bool get isArabic => _languageService.isArabic;

  @override
  void onInit() {
    super.onInit();

    // الحصول على رقم الدعم من المعاملات المُمررة
    if (Get.arguments != null && Get.arguments['supportPhone'] != null) {
      supportPhone.value = Get.arguments['supportPhone'];
    }

    loadInvoicesFromAPI();
  }

  // تحميل الفواتير من الـ API
  Future<void> loadInvoicesFromAPI() async {
    try {
      isLoading.value = true;
      invoices.value = await _invoicesService.getProviderInvoices();
      incomeRecords.value =
          invoices.map((invoice) => _invoiceToIncomeFormat(invoice)).toList();
      calculateStatistics();
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // تحويل الفاتورة إلى تنسيق الدخل
  Map<String, dynamic> _invoiceToIncomeFormat(InvoiceModel invoice) {
    final order = invoice.order;

    // معالجة الخدمات المتعددة
    String category = '';
    String type = '';

    if (order.isMultipleServices && order.services.isNotEmpty) {
      // ✅ استخدام getTitle() للحصول على العنوان حسب اللغة
      category = order.services.first.category?.titleAr ??
          order.services.first.getTitle();
      type = order.services.first.serviceDescription ?? '';
    } else if (order.services.isNotEmpty) {
      category = order.services.first.category?.titleAr ??
          order.services.first.getTitle();
      type = order.services.first.serviceDescription ?? '';
    } else {
      category = 'service'.tr;
      type = 'not_specified'.tr;
    }

    double totalAmount = invoice.totalAmount;
    double commissionAmount = invoice.commissionAmount;
    double afterCommissionAmount = totalAmount - commissionAmount;

    return {
      'id': invoice.id.toString(),
      'customerName': order.user.name,
      'phone': order.user.phone,
      'profileImage': order.user.image.isNotEmpty
          ? order.user.image.startsWith('/Uploads')
              ? '${AppConfig.imageBaseUrl}${order.user.image}'
              : order.user.image
          : 'assets/images/profile1.jpg',
      'state': order.user.state ?? 'not_specified'.tr,
      'category': category,
      'type': type,
      'number': order.quantity,
      'duration': order.scheduledDate != null
          ? '${order.scheduledDate!.day}/${order.scheduledDate!.month}/${order.scheduledDate!.year}'
          : 'not_specified'.tr,
      'totalPrice': totalAmount,
      'commission': commissionAmount,
      'afterCommission': afterCommissionAmount,
      'paymentStatus': invoice.paymentStatus,
      'paymentStatusOriginal': invoice.paymentStatus,
      'completedDate': invoice.paymentDate ?? order.orderDate,
      'originalInvoice': invoice,
      'isMultipleServices': order.isMultipleServices,
      'services': order.services
          .map((s) => {
                'serviceTitleAr': s.serviceTitleAr, // ✅ تم التعديل
                'serviceTitleEn': s.serviceTitleEn, // ✅ جديد
                'serviceTitle': s.getTitle(), // ✅ للتوافق
                'serviceDescription': s.serviceDescription,
                'quantity': s.quantity,
                'totalPrice': s.totalPrice,
                'category': s.category?.titleAr,
              })
          .toList(),
      'servicesCount': order.services.length,
      'totalServicesQuantity':
          order.services.fold(0, (sum, s) => sum + s.quantity),
      'servicesBreakdown': order.servicesBreakdown
          .map((s) => {
                'serviceTitleAr': s.serviceTitleAr, // ✅ تم التعديل
                'serviceTitleEn': s.serviceTitleEn, // ✅ جديد
                'serviceTitle': s.getTitle(), // ✅ للتوافق
                'serviceDescription': s.serviceDescription,
                'quantity': s.quantity,
                'totalPrice': s.totalPrice,
              })
          .toList(),
    };
  }

  void viewServicesDetails(String requestId) {
    final request = incomeRecords.firstWhereOrNull((r) => r['id'] == requestId);

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

  // عرض تفاصيل الخدمات المتعددة
  // void viewServicesDetails(String recordId) {
  //   final record = incomeRecords.firstWhereOrNull((r) => r['id'] == recordId);
  //   if (record == null) {
  //     _showErrorSnackbar('error'.tr, 'no_data'.tr);
  //     return;
  //   }

  //   final isMultipleServices = record['isMultipleServices'] ?? false;
  //   final services = record['services'] as List<dynamic>? ?? [];

  //   if (!isMultipleServices || services.isEmpty) {
  //     Get.snackbar(
  //       'services_info'.tr,
  //       'single_service_only'.tr,
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: Colors.blue,
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 3),
  //       icon: const Icon(Icons.info, color: Colors.white),
  //     );
  //     return;
  //   }

  //   Get.dialog(
  //     AlertDialog(
  //       title: Text('services_details'.tr + ' (${services.length}' + ')'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text('order_number'.tr + ': ${record['id']}'),
  //             Text('customer'.tr + ': ${record['customerName']}'),
  //             const SizedBox(height: 16),
  //             Flexible(
  //               child: ListView.builder(
  //                 shrinkWrap: true,
  //                 itemCount: services.length,
  //                 itemBuilder: (context, serviceIndex) {
  //                   final service = services[serviceIndex];

  //                   // ✅ استخراج اسم الخدمة حسب اللغة
  //                   final serviceTitle = isArabic
  //                       ? service['serviceTitleAr'] ??
  //                           service['serviceTitleEn'] ??
  //                           service['serviceTitle'] ??
  //                           'not_specified'.tr
  //                       : service['serviceTitleEn'] ??
  //                           service['serviceTitleAr'] ??
  //                           service['serviceTitle'] ??
  //                           'not_specified'.tr;

  //                   return Card(
  //                     margin: const EdgeInsets.only(bottom: 8),
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(12),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               Expanded(
  //                                 child: Text(
  //                                   serviceTitle,
  //                                   style: const TextStyle(
  //                                     fontWeight: FontWeight.bold,
  //                                     fontSize: 14,
  //                                   ),
  //                                 ),
  //                               ),
  //                               Container(
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 6, vertical: 2),
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.blue.withOpacity(0.1),
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                                 child: Text(
  //                                   '#${serviceIndex + 1}',
  //                                   style: const TextStyle(
  //                                     fontSize: 10,
  //                                     color: Colors.blue,
  //                                     fontWeight: FontWeight.w600,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             service['serviceDescription'] ?? 'no_data'.tr,
  //                             style: TextStyle(
  //                               color: Colors.grey[600],
  //                               fontSize: 12,
  //                             ),
  //                           ),
  //                           if (service['category'] != null) ...[
  //                             const SizedBox(height: 4),
  //                             Text(
  //                               'category'.tr + ': ${service['category']}',
  //                               style: TextStyle(
  //                                 color: Colors.grey[500],
  //                                 fontSize: 11,
  //                               ),
  //                             ),
  //                           ],
  //                           const SizedBox(height: 8),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Text('quantity'.tr +
  //                                   ': ${service['quantity'] ?? 0}'),
  //                               Text(
  //                                 'price'.tr +
  //                                     ': ${service['totalPrice'] ?? 0} ' +
  //                                     'omr'.tr,
  //                                 style: const TextStyle(
  //                                   fontWeight: FontWeight.w600,
  //                                   color: Colors.green,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey[100],
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         'total_quantity'.tr +
  //                             ': ${record['totalServicesQuantity']}',
  //                         style: const TextStyle(fontWeight: FontWeight.w600),
  //                       ),
  //                       Text(
  //                         'total_price'.tr +
  //                             ': ${record['totalPrice']} ' +
  //                             'omr'.tr,
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.w700,
  //                           color: Colors.green,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         'commission'.tr +
  //                             ': ${record['commission']} ' +
  //                             'omr'.tr,
  //                         style: const TextStyle(fontWeight: FontWeight.w600),
  //                       ),
  //                       Text(
  //                         'net_income'.tr +
  //                             ': ${record['afterCommission']} ' +
  //                             'omr'.tr,
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.w700,
  //                           color: Color(0xFFEF4444),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text('close'.tr),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // الحصول على ملخص الخدمات
  String getServicesSummary(Map<String, dynamic> record) {
    final isMultiple = record['isMultipleServices'] ?? false;
    final services = record['services'] as List<dynamic>? ?? [];

    if (!isMultiple || services.isEmpty) {
      return record['category'] ?? 'service'.tr;
    }

    if (services.length == 1) {
      // ✅ عرض العنوان حسب اللغة
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

    // ✅ عرض أول خدمة مع عدد الخدمات المتبقية
    final firstServiceTitle = isArabic
        ? services.first['serviceTitleAr'] ??
            services.first['serviceTitleEn'] ??
            services.first['serviceTitle'] ??
            'service'.tr
        : services.first['serviceTitleEn'] ??
            services.first['serviceTitleAr'] ??
            services.first['serviceTitle'] ??
            'service'.tr;

    return '$firstServiceTitle + ${services.length - 1} ' + 'others'.tr;
  }

  // حساب الإحصائيات
  void calculateStatistics() {
    completedRequests.value = incomeRecords.length;
    grossIncome.value = incomeRecords.fold(
        0.0, (sum, record) => sum + (record['totalPrice'] as double));
    afterCommission.value = incomeRecords.fold(
        0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  // التواصل مع الإدارة لطلب الدفع
  Future<void> contactAdminForPayment(String recordId) async {
    try {
      final record = incomeRecords.firstWhereOrNull((r) => r['id'] == recordId);
      if (record == null) {
        _showErrorSnackbar('error'.tr, 'no_data'.tr);
        return;
      }
      print(record);
      final amount = record['commission'];

      // final originalInvoice = record['originalInvoice'] as InvoiceModel;
      await _openWhatsAppFallback(recordId, amount);
      // محاكاة تأكيد الإدارة (في الإنتاج، انتظر تحديث الخادم)
      // await _invoicesService.updatePaymentStatus(originalInvoice.id, 'paid');
      await refreshIncomeData();
      _showSuccessSnackbar('success'.tr, 'payment_request_sent'.tr);
    } catch (e) {
      _showErrorSnackbar('error'.tr, 'error_contacting_admin'.tr);
    }
  }

  // فتح واتساب كبديل
  Future<void> _openWhatsAppFallback(String recordId, double amount) async {
    final String message = Uri.encodeComponent('support_message'.tr +
        ': $recordId ' +
        'amount'.tr +
        ' $amount ' +
        'omr'.tr);
    final String whatsappUrl =
        'https://wa.me/${supportPhone.value}?text=$message';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
      _showSuccessSnackbar('whatsapp_opened'.tr, 'contact_admin'.tr);
    } else {
      _showErrorSnackbar('error'.tr, 'cannot_open_whatsapp'.tr);
    }
  }

  // الحصول على السجلات المدفوعة
  List<Map<String, dynamic>> get paidRecords {
    return incomeRecords
        .where((record) =>
            record['paymentStatus'].toString().toLowerCase() ==
            'paid'.tr.toLowerCase())
        .toList();
  }

  // الحصول على السجلات غير المدفوعة
  List<Map<String, dynamic>> get unpaidRecords {
    return incomeRecords
        .where((record) =>
            record['paymentStatus'].toString().toLowerCase() ==
            'not_paid'.tr.toLowerCase())
        .toList();
  }

  // الحصول على إجمالي المبلغ المدفوع
  double get totalPaidAmount {
    return paidRecords.fold(
        0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  // الحصول على إجمالي المبلغ غير المدفوع
  double get totalUnpaidAmount {
    return unpaidRecords.fold(
        0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  // الحصول على إجمالي مبلغ العمولة
  double get totalCommissionAmount {
    return incomeRecords.fold(
        0.0, (sum, record) => sum + (record['commission'] as double));
  }

  // تصفية السجلات حسب حالة الدفع
  void filterByPaymentStatus(String status) {
    if (status.toLowerCase() == 'all') {
      loadInvoicesFromAPI();
    } else {
      final filteredRecords = incomeRecords
          .where((record) =>
              record['paymentStatus'].toString().toLowerCase() ==
              status.toLowerCase())
          .toList();
      incomeRecords.value = filteredRecords;
    }
    calculateStatistics();
  }

  // تصفية السجلات حسب نطاق التاريخ
  void filterByDateRange(DateTime startDate, DateTime endDate) {
    final filteredRecords = incomeRecords.where((record) {
      final recordDate = record['completedDate'] as DateTime;
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
    incomeRecords.value = filteredRecords;
    calculateStatistics();
    _showInfoSnackbar(
      'filter_by_date'.tr,
      'filter_records'.tr +
          ' ${startDate.day}/${startDate.month} ' +
          'to'.tr +
          ' ${endDate.day}/${endDate.month}',
    );
  }

  // تصفية السجلات حسب اسم العميل
  void filterByCustomer(String customerName) {
    if (customerName.isEmpty) {
      loadInvoicesFromAPI();
    } else {
      final filteredRecords = incomeRecords
          .where((record) => record['customerName']
              .toString()
              .toLowerCase()
              .contains(customerName.toLowerCase()))
          .toList();
      incomeRecords.value = filteredRecords;
    }
    calculateStatistics();
  }

  // تصفية السجلات حسب الفئة
  void filterByCategory(String category) {
    if (category.toLowerCase() == 'all') {
      loadInvoicesFromAPI();
    } else {
      final filteredRecords = incomeRecords
          .where((record) =>
              record['category'].toString().toLowerCase() ==
              category.toLowerCase())
          .toList();
      incomeRecords.value = filteredRecords;
    }
    calculateStatistics();
  }

  // تصفية السجلات حسب نوع الخدمة
  void filterByServiceType(String serviceType) {
    if (serviceType.toLowerCase() == 'all') {
      loadInvoicesFromAPI();
    } else if (serviceType.toLowerCase() == 'multiple') {
      final filteredRecords = incomeRecords
          .where((record) => record['isMultipleServices'] == true)
          .toList();
      incomeRecords.value = filteredRecords;
    } else if (serviceType.toLowerCase() == 'single') {
      final filteredRecords = incomeRecords
          .where((record) => record['isMultipleServices'] != true)
          .toList();
      incomeRecords.value = filteredRecords;
    }
    calculateStatistics();
  }

  bool isRecordPaid(Map<String, dynamic> record) {
    final status = record['paymentStatus'].toString().toLowerCase();
    return status == 'paid';
  }

  // التحقق مما إذا كان يمكن طلب الدفع
  bool canRequestPayment(String recordId) {
    final record = incomeRecords.firstWhereOrNull((r) => r['id'] == recordId);
    return record != null && !isRecordPaid(record);
  }

  // الحصول على إحصائيات الدخل
  Map<String, dynamic> getIncomeStats(DateTime startDate, DateTime endDate) {
    final periodRecords = incomeRecords.where((record) {
      final recordDate = record['completedDate'] as DateTime;
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    return {
      'totalRequests': periodRecords.length,
      'multipleServicesCount':
          periodRecords.where((r) => r['isMultipleServices'] == true).length,
      'singleServicesCount':
          periodRecords.where((r) => r['isMultipleServices'] != true).length,
      'totalGross': periodRecords.fold(
          0.0, (sum, record) => sum + (record['totalPrice'] as double)),
      'totalCommission': periodRecords.fold(
          0.0, (sum, record) => sum + (record['commission'] as double)),
      'totalNet': periodRecords.fold(
          0.0, (sum, record) => sum + (record['afterCommission'] as double)),
      'paidAmount': periodRecords
          .where((r) =>
              r['paymentStatus'].toString().toLowerCase() ==
              'paid'.tr.toLowerCase())
          .fold(0.0,
              (sum, record) => sum + (record['afterCommission'] as double)),
      'unpaidAmount': periodRecords
          .where((r) =>
              r['paymentStatus'].toString().toLowerCase() ==
              'not_paid'.tr.toLowerCase())
          .fold(0.0,
              (sum, record) => sum + (record['afterCommission'] as double)),
    };
  }

  // تحديث بيانات الدخل
  Future<void> refreshIncomeData() async {
    await loadInvoicesFromAPI();
    _showSuccessSnackbar('updated'.tr, 'income_data_updated'.tr);
  }

  // الحصول على متوسط معدل العمولة
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
    return incomeRecords
        .where((record) => record['isMultipleServices'] == true)
        .length;
  }

  // إحصائيات الخدمات الفردية
  int get singleServicesCount {
    return incomeRecords
        .where((record) => record['isMultipleServices'] != true)
        .length;
  }

  // الدخل من الخدمات المتعددة
  double get multipleServicesIncome {
    return incomeRecords
        .where((record) => record['isMultipleServices'] == true)
        .fold(
            0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  // الدخل من الخدمات الفردية
  double get singleServicesIncome {
    return incomeRecords
        .where((record) => record['isMultipleServices'] != true)
        .fold(
            0.0, (sum, record) => sum + (record['afterCommission'] as double));
  }

  // مسح جميع المرشحات
  Future<void> clearAllFilters() async {
    await loadInvoicesFromAPI();
    _showInfoSnackbar('cleared'.tr, 'filters_cleared'.tr);
  }

  // إظهار رسالة نجاح
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

  // إظهار رسالة معلومات
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
