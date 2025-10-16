import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/controllers/ServicesController.dart';
import '../../utils/colors.dart';

class ServicesView extends GetView<ServicesController> {
  final ServicesController controller = Get.put(ServicesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with back button, Add Service button, and logo
            _buildTopBar(),

            const SizedBox(height: 20),

            // Services List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Services List
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (controller.providerServices.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: controller.refreshData,
                          child: ListView.builder(
                            itemCount: controller.providerServices.length,
                            itemBuilder: (context, index) {
                              final service =
                                  controller.providerServices[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildServiceCard(service),
                              );
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Bottom Add Service Button
                    _buildAddServiceButton(),

                    const SizedBox(height: 20),
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
          // Left side - Back button and Add Service button
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

              const SizedBox(width: 12),

              // Add Service button with loading state
              Obx(() => GestureDetector(
                    onTap: (controller.isLoading.value ||
                            controller.isAddingServices.value)
                        ? null
                        : () => controller.navigateToAddService(),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: (controller.isLoading.value ||
                                controller.isAddingServices.value)
                            ? Colors.grey[400]
                            : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.isAddingServices.value)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            'add'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(width: 16),

              // Services title with count
              Obx(() => Text(
                    "${'services_count'.tr} ${controller.providerServices.length.toString()} ",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  )),
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

  Widget _buildServiceCard(dynamic service) {
    final serviceModel = service.service;
    final isActive = service.isActive ?? false;
    final serviceId = service.id;

    return Obx(() {
      final isDeleting = controller.isServiceLoading(serviceId, 'delete');

      return AnimatedOpacity(
        opacity: isDeleting ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.orange,
              width: isActive ? 0 : 2,
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
              // Deleting indicator
              if (isDeleting)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'deleting'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // Status indicator
              if (!isActive && !isDeleting)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'service_disabled'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

              Row(
                children: [
                  // Service info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service name
                        Text(
                          serviceModel?.getTitle(controller.isArabic) ??
                              'undefined_service'.tr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.black87 : Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Service description - استخدام الوصف حسب اللغة
                        if (serviceModel?.getDescription(controller.isArabic) !=
                                null &&
                            serviceModel!
                                .getDescription(controller.isArabic)!
                                .isNotEmpty)
                          Text(
                            serviceModel.getDescription(controller.isArabic)!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const SizedBox(height: 8),

                        // Commission info
                        if (serviceModel?.commission != null)
                          Text(
                            "${'commission_info'.tr}${serviceModel!.commission.toString()} ${'omr'.tr}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Price and buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Price label and value
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'price'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${service.price} ${"omr".tr}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  isActive ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
                      _buildActionButtons(service),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons(dynamic service) {
    final serviceId = service.id;
    final isActive = service.isActive ?? false;

    return Obx(() {
      final isTogglingStatus = controller.isServiceLoading(serviceId, 'status');
      final isUpdatingPrice = controller.isServiceLoading(serviceId, 'price');
      final isDeleting = controller.isServiceLoading(serviceId, 'delete');
      final isAnyLoading = isTogglingStatus || isUpdatingPrice || isDeleting;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle status button
          GestureDetector(
            onTap: isAnyLoading
                ? null
                : () => controller.toggleServiceStatus(serviceId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAnyLoading
                    ? Colors.grey[400]
                    : (isActive ? Colors.orange : Colors.green),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTogglingStatus)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Text(
                      isActive ? 'disable'.tr : 'enable'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Edit price button
          GestureDetector(
            onTap: isAnyLoading
                ? null
                : () => controller.editServicePrice(service),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAnyLoading ? Colors.grey[400] : Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUpdatingPrice)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Text(
                      'edit'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Delete button
          GestureDetector(
            onTap:
                isAnyLoading ? null : () => controller.deleteService(serviceId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isAnyLoading ? Colors.grey[400] : const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isDeleting)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Text(
                      'delete'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.build_circle_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'no_services'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'add_first_service'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => GestureDetector(
                onTap: controller.isLoading.value
                    ? null
                    : () => controller.navigateToAddService(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.isLoading.value
                        ? Colors.grey[400]
                        : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.isLoading.value)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Text(
                          'add'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAddServiceButton() {
    return GestureDetector(
      onTap: () => controller.showAddServiceDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'request_unlisted_service'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
