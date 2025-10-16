import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/controllers/RequestsController.dart';
import 'package:khabir/models/order_model.dart';
import '../../utils/colors.dart';
import 'package:flutter/services.dart';

class RequestsView extends GetView<RequestsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            const SizedBox(height: 20),

            // Requests List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.requests.isEmpty) {
                    return Center(
                      child: Text(
                        'no_requests'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.requests.length,
                    itemBuilder: (context, index) {
                      final request = controller.requests[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildRequestCard(request),
                      );
                    },
                  );
                }),
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
                'requests'.tr,
                style: const TextStyle(
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // رقم الهاتف على اليسار
            Text(
              formattedPhone,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
                fontWeight: FontWeight.w400,
              ),
              textDirection: TextDirection.ltr,
            ),
            // مسافة صغيرة
            const SizedBox(width: 4),
            // رمز الدولة على اليمين
            Text(
              countryCode,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
                fontWeight: FontWeight.w400,
              ),
              textDirection: TextDirection.ltr,
            ),
            // أيقونة النسخ
            const SizedBox(width: 4),
            Icon(
              Icons.content_copy,
              size: 14,
              color: Colors.blue[700],
            ),
          ],
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

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'].toString().toLowerCase();
    final isMultipleServices = request['isMultipleServices'] ?? false;
    final services = request['services'] as List<dynamic>? ?? [];
    final originalOrder =
        request['originalOrder'] as OrderModel; // ✅ إضافة هذا السطر

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (status == 'accepted' || status == 'completed') ...[
                      Text(
                        request['name'] ?? 'غير معروف',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _formatPhoneNumber(request['phone']),
                    ] else ...[
                      Text(
                        'waiting_for_acceptance'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
                        request['id'] ?? 'N/A',
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
                        request['state'] ?? 'غير محدد',
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
          const SizedBox(height: 16),

          // Services Section
          if (isMultipleServices && services.isNotEmpty) ...[
            _buildMultipleServicesSection(services),
          ] else ...[
            _buildSingleServiceSection(request),
          ],

          // ✅ إضافة Scheduled Date هنا (يظهر لجميع الطلبات)
          if (originalOrder.scheduledDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 18,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'scheduled_time'.tr.isNotEmpty
                        ? 'scheduled_time'.tr
                        : 'الوقت المجدول',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(originalOrder.scheduledDate),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          _buildStatusBadge(request['status'] ?? 'pending'),
          const SizedBox(height: 20),
          _buildActionButtons(request),
        ],
      ),
    );
  }

  Widget _buildSingleServiceSection(Map<String, dynamic> request) {
    final originalOrder = request['originalOrder'] as OrderModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الصف الأول - معلومات الخدمة الأساسية
        Row(
          children: [
            // صنف الخدمة (Category)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'service_category'.tr.isNotEmpty
                        ? 'service_category'.tr
                        : 'صنف الخدمة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request['category'] ?? 'غير محدد',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // نوع الخدمة (Type)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'service_type'.tr.isNotEmpty
                        ? 'service_type'.tr
                        : 'نوع الخدمة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request['type'] ?? 'غير محدد',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // الكمية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'quantity'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request['number']?.toString() ?? '0',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // السعر الإجمالي
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'total_price'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${request['totalPrice'] ?? 0} ${"omr".tr}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),

        // الصف الثاني - الوقت المجدول (إذا كان موجوداً)
        if (originalOrder.scheduledDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'scheduled_time'.tr.isNotEmpty
                      ? 'scheduled_time'.tr
                      : 'الوقت المجدول',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(originalOrder.scheduledDate),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

// دالة لتنسيق عرض المدة
  String _formatDuration(dynamic duration) {
    if (duration == null) return 'غير محدد';

    String durationStr = duration.toString();

    // إذا كانت المدة رقم (بالدقائق)
    if (RegExp(r'^\d+$').hasMatch(durationStr)) {
      int minutes = int.parse(durationStr);
      if (minutes >= 60) {
        int hours = minutes ~/ 60;
        int remainingMinutes = minutes % 60;
        if (remainingMinutes == 0) {
          return '$hours ساعة';
        } else {
          return '$hours س $remainingMinutes د';
        }
      } else {
        return '$minutes دقيقة';
      }
    }

    // إذا كانت تاريخ أو نص
    return durationStr;
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'not_specified'.tr;

    final now = DateTime.now();
    final difference = dateTime.difference(now);

    // إذا كان التاريخ في الماضي
    if (difference.isNegative) {
      final absDifference = difference.abs();

      if (absDifference.inMinutes < 60) {
        return '${'since'.tr} ${absDifference.inMinutes} ${'minutes'.tr}';
      } else if (absDifference.inHours < 24) {
        return '${'since'.tr} ${absDifference.inHours} ${'hours'.tr}';
      } else {
        return '${'since'.tr} ${absDifference.inDays} ${'days'.tr}';
      }
    } else {
      // التاريخ في المستقبل
      if (difference.inMinutes < 60) {
        return '${'after'.tr} ${difference.inMinutes} ${'minutes'.tr}';
      } else if (difference.inHours < 24) {
        return '${'after'.tr} ${difference.inHours} ${'hours'.tr}';
      } else {
        return '${'after'.tr} ${difference.inDays} ${'days'.tr}';
      }
    }
  }

  Widget _buildMultipleServicesSection(List<dynamic> services) {
    // Calculate total values
    double totalPrice = 0;
    int totalQuantity = 0;

    for (var service in services) {
      totalPrice += (service['totalPrice'] ?? 0).toDouble();
      totalQuantity += (service['quantity'] ?? 0) as int;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 8),

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
                        'service_category'.tr.isNotEmpty
                            ? 'service_category'.tr
                            : 'صنف الخدمة',
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
                        'qty'.tr.isNotEmpty ? 'qty'.tr : 'الكمية',
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
                        'price'.tr.isNotEmpty ? 'price'.tr : 'السعر',
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

              // Services Items
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
                          'غير محدد'
                      : service['serviceTitleEn'] ??
                          service['serviceTitleAr'] ??
                          service['serviceTitle'] ??
                          'Not specified';

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                serviceTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (service['serviceDescription'] != null &&
                                  service['serviceDescription']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  service['serviceDescription'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
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

              // Show more services indicator
              if (services.length > 3) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+ ${services.length - 3} ${'more_services'.tr.isNotEmpty ? 'more_services'.tr : 'خدمة أخرى'}',
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

              // Total Summary
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'total'.tr.isNotEmpty ? 'total'.tr : 'المجموع',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '$totalQuantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${totalPrice.toStringAsFixed(1)}',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// دالة لتنسيق مدة الخدمة للخدمات المتعددة
  String _formatServiceDuration(dynamic duration) {
    if (duration == null) return '-';

    String durationStr = duration.toString();

    // إذا كانت المدة رقم (بالدقائق)
    if (RegExp(r'^\d+$').hasMatch(durationStr)) {
      int minutes = int.parse(durationStr);
      if (minutes >= 60) {
        int hours = minutes ~/ 60;
        return '${hours}س';
      } else {
        return '${minutes}د';
      }
    }

    // إذا كانت نص قصير
    if (durationStr.length > 10) {
      return durationStr.substring(0, 10) + '...';
    }

    return durationStr;
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        statusText = 'pending_status'.tr; // في انتظار
        break;
      case 'accepted':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        statusText = 'accepted_status'.tr; // مقبول
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        statusText = 'completed_status'.tr; // مكتمل
        break;
      case 'incomplete':
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        statusText = 'incomplete_status'.tr; // ملغى
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        statusText = 'unknown_status'.tr; // غير معروف
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> request) {
    final status = request['status'].toString().toLowerCase();
    final requestId = request['id'];

    return Column(
      children: [
        // الصف الأول - أزرار الموقع والتتبع
        Row(
          children: [
            // زر التتبع - يظهر فقط للطلبات المقبولة
            if (status == 'accepted') ...[
              // زر الموقع
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.viewLocation(requestId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'location'.tr,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // مساحة فاصلة
              const SizedBox(width: 10),

              Expanded(
                child: Obx(() {
                  final isStartingTracking =
                      controller.isStartingTracking.value &&
                          controller.trackingRequestId.value == requestId;

                  return GestureDetector(
                    onTap: () => controller.startLocationTracking(requestId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 1.5),
                      ),
                      child: isStartingTracking
                          ? const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.orange),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.my_location,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'start_tracking'.tr,
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ),
            ] else ...[
              // مساحة فارغة إذا لم يكن هناك زر تتبع
              Expanded(child: Container()),
            ],
          ],
        ),

        // فاصل بين الصفوف
        if (status == 'pending' || status == 'accepted') ...[
          const SizedBox(height: 12),
        ],

        // الصف الثاني - أزرار الإجراءات الرئيسية
        if (status == 'pending') ...[
          // للطلبات المعلقة: زر الإلغاء + زر القبول فقط
          Row(
            children: [
              // زر الإلغاء
              Expanded(
                child: Obx(() {
                  final canCancel = controller.canCancelRequest(requestId);
                  final isProcessing =
                      controller.isRequestProcessing(requestId);
                  final isCancelling = controller.isCancelling.value;

                  return GestureDetector(
                    onTap: canCancel
                        ? () => controller.markIncomplete(requestId)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: !canCancel
                            ? Colors.grey[300]
                            : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: canCancel
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFFEF4444).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isProcessing && isCancelling
                          ? const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: !canCancel
                                      ? Colors.grey[600]
                                      : Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'cancel'.tr,
                                  style: TextStyle(
                                    color: !canCancel
                                        ? Colors.grey[600]
                                        : Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ),

              const SizedBox(width: 12),

              // زر القبول
              Expanded(
                child: Obx(() {
                  final isProcessing =
                      controller.isRequestProcessing(requestId);
                  final isAccepting = controller.isAccepting.value;

                  return GestureDetector(
                    onTap: () => controller.acceptRequest(requestId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isProcessing && isAccepting
                          ? const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'accept'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ] else if (status == 'accepted') ...[
          // للطلبات المقبولة: زر الإكمال فقط
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final isProcessing =
                      controller.isRequestProcessing(requestId);
                  final isCompleting = controller.isCompleting.value;

                  return GestureDetector(
                    onTap: () => controller.markComplete(requestId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isProcessing && isCompleting
                          ? const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'complete'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ]
      ],
    );
  }
}
