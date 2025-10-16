import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/controllers/NotificationsController.dart';
import '../../utils/colors.dart';

class NotificationsView extends GetView<NotificationsController> {
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

            // Notifications List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingState();
                  }

                  if (controller.notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshNotifications,
                    child: ListView.builder(
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = controller.notifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildNotificationCard(notification, index),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button للتحديث
      floatingActionButton: Obx(() => controller.isLoading.value
          ? const SizedBox.shrink()
          : FloatingActionButton(
              onPressed: controller.refreshNotifications,
              backgroundColor: const Color(0xFFEF4444),
              child: const Icon(Icons.refresh, color: Colors.white),
            )),
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

              // Title with notification count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'notifications_title'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions
          Row(
            children: [
              // Logo
              GestureDetector(
                onTap: () {
                  Get.snackbar('app_name'.tr, 'welcome_message'.tr);
                },
                child: Container(
                  height: 40,
                  child: Image.asset(
                    'assets/icons/logo_sm.png',
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final String priority = notification['priority'] ?? 'medium';
    final String status = notification['status'].toString().toLowerCase();
    final bool isMultipleServices = notification['isMultipleServices'] ?? false;
    final int servicesCount = notification['servicesCount'] ?? 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPriorityColor(priority),
          width: 2,
        ),
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
          // Header with priority indicator and services indicator
          Row(
            children: [
              // Priority indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Service category with multiple services indicator
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        controller.getServicesSummary(notification),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMultipleServices) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$servicesCount ${'services_label'.tr}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Time
              Text(
                _formatTime(notification['requestTime']),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Customer info
          if (status == 'accepted' || status == 'completed') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['customerName'] ??
                              'customer_default_name'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          notification['customerPhone'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Call button
                  GestureDetector(
                    onTap: () => controller.callCustomer(index),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.phone,
                        color: Colors.green[600],
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'waiting_for_acceptance'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Services details section
          if (isMultipleServices) ...[
            _buildMultipleServicesSection(notification, index),
          ] else ...[
            _buildSingleServiceSection(notification),
          ],

          const SizedBox(height: 16),

          // معلومات التاريخ والمدة والولاية والسعر
          Column(
            children: [
              // معلومات التاريخ والمدة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    // تاريخ الطلب
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),

                        // الولاية
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'state_label'.tr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                notification['state'] ?? 'not_specified'.tr,
                                style: const TextStyle(
                                  fontSize: 13,
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
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${notification['price']} ${'currency'.tr}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    //  والموقع
                    Row(
                      children: [
                        // زر الموقع
                        GestureDetector(
                          onTap: () => controller.viewLocation(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'view_location'.tr,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              // Accept button
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.acceptNotification(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'accept_request'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // View details button (for multiple services)
              if (isMultipleServices) ...[
                GestureDetector(
                  onTap: () => controller.viewServicesDetails(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'details_button'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Reject button
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.rejectNotification(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'reject_request'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleServiceSection(Map<String, dynamic> notification) {
    return Row(
      children: [
        // Service type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'service_type'.tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification['type'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // Quantity
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
                notification['number'].toString(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'duration'.tr,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification['duration'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultipleServicesSection(
      Map<String, dynamic> notification, int index) {
    final services = notification['services'] as List<dynamic>? ?? [];
    final totalQuantity = notification['totalServicesQuantity'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${'multiple_services'.tr} (${services.length} ${'services_label'.tr})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.viewServicesDetails(index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'view_all'.tr,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Services preview (first 2 services)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length > 2 ? 2 : services.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, serviceIndex) {
              final service = services[serviceIndex];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['serviceTitle'] ?? 'not_specified'.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (service['serviceDescription'] != null) ...[
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
                        '${service['totalPrice'] ?? 0} ${'currency'.tr}',
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
          if (services.length > 2) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+ ${services.length - 2} ${'more_services'.tr}',
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

          // Summary
          Container(
            padding: const EdgeInsets.all(12),
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
                  child: Text(
                    '${'total_quantity'.tr}: $totalQuantity',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '${'duration'.tr}: ${formatISODateTime(notification['duration'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatISODateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'not_specified'.tr;

    try {
      // تحويل النص إلى DateTime
      DateTime dateTime = DateTime.parse(isoString);

      // تحويل إلى التوقيت المحلي
      DateTime localDateTime = dateTime.toLocal();

      final now = DateTime.now();
      final difference = localDateTime.difference(now); // عكس العملية

      // إذا كان التاريخ في الماضي
      if (difference.isNegative) {
        final absDifference = difference.abs();

        // نفس اليوم
        if (absDifference.inDays == 0) {
          final hour = localDateTime.hour;
          final minute = localDateTime.minute.toString().padLeft(2, '0');
          String period = hour < 12 ? 'am'.tr : 'pm'.tr;
          int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '${'today'.tr} ${displayHour}:${minute} $period';
        }

        // أمس
        if (absDifference.inDays == 1) {
          final hour = localDateTime.hour;
          final minute = localDateTime.minute.toString().padLeft(2, '0');
          String period = hour < 12 ? 'am'.tr : 'pm'.tr;
          int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '${'yesterday'.tr} ${displayHour}:${minute} $period';
        }

        // أقل من أسبوع
        if (absDifference.inDays < 7) {
          return '${'since'.tr} ${absDifference.inDays} ${'days'.tr}';
        }

        // أقل من شهر
        if (absDifference.inDays < 30) {
          final weeks = (absDifference.inDays / 7).floor();
          return '${'since'.tr} $weeks ${'weeks'.tr}';
        }
      } else {
        // التاريخ في المستقبل

        // نفس اليوم
        if (difference.inDays == 0) {
          final hour = localDateTime.hour;
          final minute = localDateTime.minute.toString().padLeft(2, '0');
          String period = hour < 12 ? 'am'.tr : 'pm'.tr;
          int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '${'today'.tr} ${displayHour}:${minute} $period';
        }

        // غداً
        if (difference.inDays == 1) {
          final hour = localDateTime.hour;
          final minute = localDateTime.minute.toString().padLeft(2, '0');
          String period = hour < 12 ? 'am'.tr : 'pm'.tr;
          int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '${'tomorrow'.tr} ${displayHour}:${minute} $period';
        }

        // أقل من أسبوع
        if (difference.inDays < 7) {
          return '${'after'.tr} ${difference.inDays} ${'days'.tr}';
        }

        // أقل من شهر
        if (difference.inDays < 30) {
          final weeks = (difference.inDays / 7).floor();
          return '${'after'.tr} $weeks ${'weeks'.tr}';
        }
      }

      // تاريخ مفصل للتواريخ البعيدة
      final day = localDateTime.day.toString().padLeft(2, '0');
      final month = localDateTime.month.toString().padLeft(2, '0');
      final year = localDateTime.year;
      final hour = localDateTime.hour;
      final minute = localDateTime.minute.toString().padLeft(2, '0');

      String period = hour < 12 ? 'am'.tr : 'pm'.tr;
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$day/$month/$year - ${displayHour}:${minute} $period';
    } catch (e) {
      print('Error parsing date: $e');
      return 'invalid_date'.tr;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
          ),
          const SizedBox(height: 16),
          Text(
            'loading_notifications'.tr,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_pending_requests'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'new_requests_will_appear_here'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: controller.refreshNotifications,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'refresh'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = dateTime.difference(now); // عكس العملية لتكون موجبة

    // إذا كان التاريخ في المستقبل
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

}
