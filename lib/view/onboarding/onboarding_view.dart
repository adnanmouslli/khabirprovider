import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/onboarding_controller.dart';
import '../../utils/colors.dart';
import '../../widgets/rtl_support.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            _buildHeader(),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.currentPage.value = index;
                },
                itemCount: controller.onboardingPages.length,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return OnboardingPage1(
                        page: controller.onboardingPages[index],
                        onNext: controller.nextPage,
                      );
                    case 1:
                      return OnboardingPage2(
                        page: controller.onboardingPages[index],
                        onNext: controller.nextPage,
                        onBack: controller.goBack,
                      );
                    case 2:
                      return OnboardingPage3(
                        page: controller.onboardingPages[index],
                        onSelectProvider: controller.selectProvider,
                        onSelectUser: controller.selectUser,
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [

          Center(child: _buildLanguageSelector()),
          Positioned(
            right: 0,
            top: 0,
            child: TextButton(
              onPressed: controller.skipOnboarding,
              child: Text(
                'skip'.tr,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    // Force LTR direction for language selector
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GetBuilder<OnboardingController>(
        builder: (controller) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.greyLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // English button (always on the left in LTR)
              _buildLanguageButton(
                language: 'en',
                displayText: 'EN',
                isSelected: controller.isEnglish,
                isFirst: true,
                onTap: () => controller.changeLanguage('en'),
              ),
              // Divider
              Container(
                width: 1,
                height: 30,
                color: AppColors.greyLight,
              ),
              // Arabic button (always on the right in LTR)
              _buildLanguageButton(
                language: 'ar',
                displayText: 'عربي',
                isSelected: controller.isArabic,
                isFirst: false,
                onTap: () => controller.changeLanguage('ar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required String language,
    required String displayText,
    required bool isSelected,
    required bool isFirst,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 25 : 0),
            bottomLeft: Radius.circular(isFirst ? 25 : 0),
            topRight: Radius.circular(!isFirst ? 25 : 0),
            bottomRight: Radius.circular(!isFirst ? 25 : 0),
          ),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: language == 'en' ? 0.5 : 0,
          ),
        ),
      ),
    );
  }
}


// onboarding_page1.dart
class OnboardingPage1 extends StatelessWidget {
  final OnboardingModel page;
  final VoidCallback onNext;

  const OnboardingPage1({
    Key? key,
    required this.page,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Image
          SizedBox(
            height: Get.height * 0.6,
            width: Get.width * 0.8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  page.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),


          // Dots indicator
          _buildDotsIndicator(0),

          const SizedBox(height: 30),

          // Title
          Text(
            page.titleKey.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitleKey.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const Spacer(),

          // Next button only
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'next'.tr,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.greyLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// onboarding_page2.dart
class OnboardingPage2 extends StatelessWidget {
  final OnboardingModel page;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingPage2({
    Key? key,
    required this.page,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Image
          SizedBox(
            height: Get.height * 0.6,
            width: Get.width * 0.8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  page.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),


          // Dots indicator
          _buildDotsIndicator(1),

          const SizedBox(height: 30),

          // Title
          Text(
            page.titleKey.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitleKey.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),

          const Spacer(),

          // Back and Next buttons
          Row(
            children: [
              // Back button
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'back'.tr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Next button
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'next'.tr,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.greyLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// onboarding_page3.dart
class OnboardingPage3 extends StatelessWidget {
  final OnboardingModel page;
  final VoidCallback onSelectProvider;
  final VoidCallback onSelectUser;

  const OnboardingPage3({
    Key? key,
    required this.page,
    required this.onSelectProvider,
    required this.onSelectUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Image
          SizedBox(
            height: Get.height * 0.6,
            width: Get.width * 0.6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  page.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),



          // Dots indicator
          _buildDotsIndicator(2),

          const SizedBox(height: 30),

          // Title
          Text(
            page.titleKey.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle (if available)
          if (page.subtitleKey.isNotEmpty)
            Text(
              page.subtitleKey.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),

          const Spacer(),

          // Provider and User buttons
          Row(
            children: [
              // Provider button
              Expanded(
                child: ElevatedButton(
                  onPressed: onSelectProvider,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'provider'.tr,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // User button
              Expanded(
                child: ElevatedButton(
                  onPressed: onSelectUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'user'.tr,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.greyLight,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}