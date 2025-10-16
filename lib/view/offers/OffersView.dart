import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/controllers/OffersController.dart';
import '../../utils/colors.dart';

class OffersView extends GetView<OffersController> {
  final OffersController controller = Get.put(OffersController());

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

            // Services with Offers List
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

              // Title with offers count
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'offers_management'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'services_active_offers'.trParams({
                          '0': controller.providerServices.length.toString(),
                          '1': controller.activeOffersCount.toString(),
                        }),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )),
            ],
          ),

          // Logo
          GestureDetector(
            onTap: () {
              Get.snackbar('خبير', 'مرحباً بك في خبير');
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
                            Icons.local_offer,
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
    final hasActiveOffer = service.hasActiveOffer;
    final activeOffer = service.activeOffer;

    return Obx(() {
      final isCreatingOffer =
          controller.isServiceLoading(serviceId, 'createOffer');

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasActiveOffer
                ? Colors.green
                : (isActive ? Colors.transparent : Colors.orange),
            width: hasActiveOffer || !isActive ? 2 : 0,
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
            // Offer indicator
            if (hasActiveOffer)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_offer,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'active_offer_discount'.trParams({
                        '0': (activeOffer?.discountPercentage ?? 0).toString(),
                      }),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Status indicator for inactive services
            if (!isActive && !hasActiveOffer)
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
                            (controller.isArabic
                                ? 'خدمة غير محددة'
                                : 'Undefined Service'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.black87 : Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Service description
                      Text(
                        serviceModel?.description ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
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
                    // Price section
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

                        // Original price (crossed if has offer)
                        if (hasActiveOffer) ...[
                          Text(
                            '${service.price} ${"omr".tr}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Offer price
                          Text(
                            '${activeOffer?.offerPrice ?? service.price} ${"omr".tr}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ] else
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

            // Show active offers list if any
            // if (service.offers != null && service.offers!.isNotEmpty)
            //   _buildOffersSection(service.offers!),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons(dynamic service) {
    final serviceId = service.id;
    final hasActiveOffer = service.hasActiveOffer;
    final activeOffer = service.activeOffer;

    return Obx(() {
      final isCreatingOffer =
          controller.isServiceLoading(serviceId, 'createOffer');

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add Offer button (only if no active offer)
          if (!hasActiveOffer)
            GestureDetector(
              onTap: isCreatingOffer
                  ? null
                  : () => controller.addOfferToService(service),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCreatingOffer
                      ? Colors.grey[400]
                      : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCreatingOffer)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      const Icon(Icons.local_offer,
                          color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'add_offer'.tr,
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

          // Edit and Delete buttons (only if has active offer)
          if (hasActiveOffer && activeOffer != null) ...[
            // Edit Offer button - جديد
            Obx(() {
              final isEditingOffer =
                  controller.isOfferLoading(activeOffer.id, 'edit');

              return GestureDetector(
                onTap: isEditingOffer
                    ? null
                    : () => controller.editOffer(activeOffer),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: isEditingOffer ? Colors.grey[400] : Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEditingOffer)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(Icons.edit, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
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
              );
            }),

            // Delete Offer button
            Obx(() {
              final isDeletingOffer =
                  controller.isOfferLoading(activeOffer.id, 'delete');

              return GestureDetector(
                onTap: isDeletingOffer
                    ? null
                    : () => controller.deleteOffer(activeOffer),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: isDeletingOffer ? Colors.grey[400] : Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDeletingOffer)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(Icons.delete, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'delete_offer'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
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
              Icons.local_offer_outlined,
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
            'add_services_first'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
