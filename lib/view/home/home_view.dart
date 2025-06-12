import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../utils/colors.dart';
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
            TopBar(
              notificationCount: 3,
              onNotificationTap: () {
                // Handle notification tap
                Get.snackbar('إشعارات', 'تم النقر على الإشعارات');
              },
              onProfileTap: () {
                // Handle profile tap
                Get.snackbar('الملف الشخصي', 'تم النقر على الملف الشخصي');
              },
              onWhatsAppTap: () {
                // Handle WhatsApp tap
                Get.snackbar('واتساب', 'تم النقر على واتساب');
              },
              onLogoTap: () {
                // Handle logo tap
                Get.snackbar('خبير', 'مرحباً بك في خبير');
              },
            ),

            const SizedBox(height: 40),


            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Grid Cards
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          // Services Card
                          _buildGridCard(
                            imagePath: 'assets/images/grid1.png',
                            title: 'Services',
                            subtitle: 'Num: 6',
                            onTap: () => controller.navigateToServices(),
                          ),

                          // Requests Card
                          _buildGridCard(
                            imagePath: 'assets/images/grid2.png',
                            title: 'Requests',
                            subtitle: 'Num: 12',
                            onTap: () => controller.navigateToRequests(),
                          ),

                          // Income Card
                          _buildGridCard(
                            imagePath: 'assets/images/grid3.png',
                            title: 'Income',
                            subtitle: '',
                            onTap: () => controller.navigateToIncome(),
                          ),

                          // Offers Card
                          _buildGridCard(
                            imagePath: 'assets/images/grid4.png',
                            title: 'Offers',
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image container
            Container(
              width: 180,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 65,  // حجم أصغر للصورة
                  height: 65, // حجم أصغر للصورة
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 20, // حجم أصغر للأيقونة
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            // Subtitle
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
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
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Star icon
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
              children: [
                const Text(
                  'Customer Reviews',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Rating stars
                Row(
                  children: [
                    // 5 stars
                    Row(
                      children: List.generate(5, (index) {
                        return const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),

                    const SizedBox(width: 8),

                    // Rating value
                    const Text(
                      '5.0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}