import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'package:khabir/controllers/IncomeController.dart';

class IncomeView extends GetView<IncomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            const SizedBox(height: 24),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
// Statistics Cards
                    _buildStatisticsCards(),
                    const SizedBox(height: 24),
// Income List
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'loading_invoices'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (controller.incomeRecords.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'no_invoices'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: controller.incomeRecords.length,
                          itemBuilder: (context, index) {
                            final record = controller.incomeRecords[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildIncomeCard(record),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
// Back button and title
          Row(
            children: [
// Back button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black54,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 20),
// Title
              Text(
                'income'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
// Logo
          GestureDetector(
            onTap: () {
              Get.snackbar('خبير', 'welcome_message'.tr);
            },
            child: Container(
              height: 40,
              child: Image.asset(
                'assets/icons/logo_sm.png',
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.build,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'خبير',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEF4444),
                              height: 1.0,
                            ),
                          ),
                          const Text(
                            'khabir',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFEF4444),
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Obx(() => Row(
          children: [
// Completed requests
            Expanded(
              child: _buildStatCard(
                icon: Icons.work_outline,
                title: 'completed_requests'.tr,
                value: controller.completedRequests.toString(),
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 15),
// Gross income
            Expanded(
              child: _buildStatCard(
                icon: Icons.attach_money,
                title: 'gross_income'.tr,
                value: '${controller.grossIncome.value.toStringAsFixed(2)} OMR',
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 15),
// After commission
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                title: 'after_commission'.tr,
                value:
                    '${controller.afterCommission.value.toStringAsFixed(2)} OMR',
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ));
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
// Icon container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
// Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
// Value
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(Map<String, dynamic> record) {
    final isMultipleServices = record['isMultipleServices'] ?? false;
    final services = record['services'] as List<dynamic>? ?? [];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with customer info and ID
          Row(
            children: [
              // Customer name and phone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['customerName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _formatPhoneNumber(record['phone']),
                  ],
                ),
              ),
              // ID and State
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'id'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record['id'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'state_label'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record['state'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ✅ Services Section - عرض الخدمات المتعددة أو الواحدة
          if (isMultipleServices && services.isNotEmpty) ...[
            _buildMultipleServicesSection(services, record),
          ] else ...[
            _buildSingleServiceSection(record),
          ],

          const SizedBox(height: 20),
          // Price section
          _buildPriceSection(record),
          const SizedBox(height: 18),
          // Payment status
          Row(
            children: [
              Expanded(child: SizedBox()),
              _buildPaymentStatus(record['paymentStatus'], record['id']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleServiceSection(Map<String, dynamic> record) {
    return Row(
      children: [
        // Category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'category'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                record['category'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // Type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'type'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                record['type'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // Number
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'number'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                record['number'].toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // Duration
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'duration'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                record['duration'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleServicesSection(
      List<dynamic> services, Map<String, dynamic> record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'multiple_services'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // زر لعرض التفاصيل الكاملة
            GestureDetector(
              onTap: () => controller.viewServicesDetails(record['id']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'view_details'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: Colors.blue[700],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Services List
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              // Services Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'service'.tr,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'qty'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'price'.tr,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Services Items (show max 3)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length > 3 ? 3 : services.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final service = services[index];

                  // ✅ استخراج اسم الخدمة حسب اللغة
                  final serviceTitle = controller.isArabic
                      ? service['serviceTitleAr'] ??
                          service['serviceTitleEn'] ??
                          service['serviceTitle'] ??
                          'not_specified'.tr
                      : service['serviceTitleEn'] ??
                          service['serviceTitleAr'] ??
                          service['serviceTitle'] ??
                          'not_specified'.tr;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            serviceTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${service['quantity'] ?? 0}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${service['totalPrice'] ?? 0}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Show more indicator
              if (services.length > 3) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+ ${services.length - 3} ${'more_services'.tr}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

// دالة محسنة لعرض تفاصيل الأسعار
  Widget _buildPriceSection(Map<String, dynamic> record) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
// Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_price'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${record['totalPrice']} ${'omr'.tr}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
// Divider
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
// Commission
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'commission'.tr,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '- ${record['commission']} ${'omr'.tr}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
// After Commission (Net amount)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'after_commission'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green[200]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${record['afterCommission']} ${'omr'.tr}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// دالة لتنسيق رقم الهاتف
  Widget _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty || phone == 'غير متوفر') {
      return Text(
        'غير متوفر',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
        ),
      );
    }

    String formattedPhone = phone;
    String countryCode = '';

    // إزالة المسافات والرموز الإضافية
    formattedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // التحقق من وجود رمز الدولة
    if (formattedPhone.startsWith('+968')) {
      countryCode = '+968';
      formattedPhone = formattedPhone.substring(4);
    } else if (formattedPhone.startsWith('968')) {
      countryCode = '+968';
      formattedPhone = formattedPhone.substring(3);
    } else if (formattedPhone.startsWith('00968')) {
      countryCode = '+968';
      formattedPhone = formattedPhone.substring(5);
    } else {
      // افتراض أن الرقم عماني إذا لم يحتوي على رمز الدولة
      countryCode = '+968';
    }

    String fullPhoneNumber = '$countryCode$formattedPhone';

    return GestureDetector(
      onTap: () => _copyPhoneNumber(fullPhoneNumber),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.blue.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Directionality(
          textDirection:
              TextDirection.ltr, // فرض اتجاه LTR بغض النظر عن لغة التطبيق
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // رمز الدولة على اليسار في LTR (يظهر على اليمين في العرض النهائي)
              Text(
                countryCode,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              // رقم الهاتف في المنتصف
              Text(
                formattedPhone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 6),
              // أيقونة النسخ على اليمين في LTR (يظهر على اليسار في العرض النهائي)
              Icon(
                Icons.content_copy,
                size: 14,
                color: Colors.blue[700],
              ),
            ],
          ),
        ),
      ),
    );
  }

// دالة نسخ رقم الهاتف
  void _copyPhoneNumber(String phoneNumber) async {
    try {
      await Clipboard.setData(ClipboardData(text: phoneNumber));

      Get.snackbar(
        'phone_copied'.tr.isNotEmpty ? 'phone_copied'.tr : 'تم النسخ',
        'phone_copied_message'.tr.isNotEmpty
            ? 'phone_copied_message'.tr
            : 'تم نسخ رقم الهاتف إلى الحافظة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
      );

      print('Phone number copied: $phoneNumber');
    } catch (e) {
      print('Error copying phone number: $e');

      Get.snackbar(
        'copy_error'.tr.isNotEmpty ? 'copy_error'.tr : 'خطأ في النسخ',
        'copy_error_message'.tr.isNotEmpty
            ? 'copy_error_message'.tr
            : 'فشل في نسخ رقم الهاتف',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.error, color: Colors.white, size: 20),
      );
    }
  }

  Widget _buildPaymentStatus(String status, String recordId) {
    // المقارنة مع القيمة الأصلية بالإنجليزية فقط
    final bool isPaid = status.toLowerCase() == 'paid';
    final bool canRequest = controller.canRequestPayment(recordId);

    Color backgroundColor;
    Color textColor;
    String text;
    IconData? icon;

    if (isPaid) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
      text = 'paid'.tr; // الآن نترجم فقط للعرض
      icon = Icons.check;
    } else {
      backgroundColor = const Color(0xFFEF4444);
      textColor = Colors.white;
      text = 'not_paid'.tr; // الآن نترجم فقط للعرض
      icon = Icons.paid_outlined;
    }

    return GestureDetector(
      onTap:
          canRequest ? () => controller.contactAdminForPayment(recordId) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: canRequest
              ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (canRequest) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                color: textColor,
                size: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
