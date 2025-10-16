import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/TopBar.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Obx(() => TopBar(
              notificationCount: controller.notificationsCount.value,
              onNotificationTap: () {
                controller.handleNotificationTap();
              },
              onProfileTap: () {
                controller.handleProfileTap();
              },
              onWhatsAppTap: () {
                controller.handleWhatsAppTap();
              },
              onLogoTap: () {
                Get.snackbar('خبير', 'welcome_message'.tr);
              },
            )),

            const SizedBox(height: 30),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Grid Cards
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // نسبة أصغر لارتفاع أكبر
                        children: [

                          Obx(() => _buildGridCard(
                            imagePath: 'assets/images/grid1.png',
                            title: 'services'.tr,
                            subtitle: 'num : ${controller.servicesCount.value}',
                            onTap: () => controller.navigateToServices(),
                          )),

                          // Requests Card
                          Obx(() => _buildGridCard(
                            imagePath: 'assets/images/grid2.png',
                            title: 'requests'.tr,
                            subtitle: 'num : ${controller.notificationsCount.value}',
                            onTap: () => controller.navigateToRequests(),
                          )),

                          // Income Card
                          _buildGridCard(
                            imagePath: 'assets/images/grid3.png',
                            title: 'income'.tr,
                            subtitle: '',
                            onTap: () => controller.navigateToIncome(),
                          ),

                          // Offers Card
                          _buildGridCard(
                            imagePath: 'assets/images/grid4.png',
                            title: 'offers'.tr,
                            subtitle: '',
                            onTap: () => controller.navigateToOffers(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Customer Reviews Section
                    _buildReviewsCard(),

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

  Widget _buildGridCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image container with better proportions
            LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth =
                    constraints.maxWidth * 0.9; // 90% من عرض الكونتينر
                return Container(
                  width: containerWidth,
                  height: containerWidth, // لجعله مربع
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      width: containerWidth * 0.5, // 50% من عرض الحاوية
                      height: containerWidth * 0.5,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: containerWidth * 0.375, // 37.5% من عرض الحاوية
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Title with better text style
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle with consistent spacing
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const SizedBox(
                  height: 16), // مساحة ثابتة حتى لو لم يكن هناك subtitle
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsCard() {
    return Container(
      width: double.infinity,
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
      child: Row(
        children: [
          // Star icon container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.red,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Reviews content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                  'customer_reviews'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Rating stars row
                Obx(() {
                  if (controller.isLoadingRating.value) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'loading'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }

                  final rating = controller.customerRating.value;
                  final fullStars = rating.floor();
                  final hasHalfStar = (rating - fullStars) >= 0.5;

                  return Row(
                    children: [
                      // Stars display
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          if (index < fullStars) {
                            // Full star
                            return const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            );
                          } else if (index == fullStars && hasHalfStar) {
                            // Half star
                            return const Icon(
                              Icons.star_half,
                              color: Colors.amber,
                              size: 16,
                            );
                          } else {
                            // Empty star
                            return const Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }
                        }),
                      ),

                      const SizedBox(width: 8),

                      // Rating value
                      Text(
                        controller.formattedRating,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
