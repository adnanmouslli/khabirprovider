import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:khabir/controllers/ProfileController.dart';
import 'package:khabir/utils/app_config.dart';
import '../../utils/colors.dart';

class ProfileView extends GetView<ProfileController> {
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

            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Profile Header
                        _buildProfileHeader(),

                        const SizedBox(height: 30),

                        // Profile Options
                        _buildProfileOptions(),

                        const SizedBox(height: 30),

                        // Social Media Icons
                        _buildSocialMediaIcons(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              }),
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
                'profile'.tr,
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
              Get.snackbar(
                'خبير',
                'welcome_message'.tr,
              );
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

  Widget _buildProfileHeader() {
    return Obx(() => Container(
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
                  // Profile Image with camera icon
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border:
                              Border.all(color: Colors.grey[300]!, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(38),
                          child: controller.user.value?.image != null &&
                                  controller.user.value!.image!.isNotEmpty
                              ? Image.network(
                                  controller.user.value!.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultProfileImage();
                                  },
                                )
                              : _buildDefaultProfileImage(),
                        ),
                      ),
                      // Camera icon for updating image
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: controller.updateProfileImage,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                      // Verified badge
                      if (controller.isVerified)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Name and Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.userName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.userPhone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit button
                  GestureDetector(
                    onTap: controller.editProfile,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'edit'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildDefaultProfileImage() {
    // إذا كان لديك رابط الصورة، قم بتحميلها

    if (controller.user.value?.image != null &&
        controller.user.value!.image!.isNotEmpty) {
      // تأكد من أن الرابط كامل (يحتوي على http/https)
      String imageUrl = controller.user.value!.image!;

      if (!imageUrl.startsWith('http')) {
        // إضافة base URL إذا لم يكن الرابط كاملاً
        imageUrl = '${AppConfig.imageBaseUrl}${controller.user.value!.image!}';
      }

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFEF4444),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // في حالة فشل تحميل الصورة، عرض الأيقونة الافتراضية
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.person,
              color: Colors.grey[400],
              size: 35,
            ),
          );
        },
      );
    }

    // إذا لم يكن هناك رابط صورة، عرض الأيقونة الافتراضية
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        color: Colors.grey[400],
        size: 35,
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildProfileOption(
          icon: Icons.language,
          title: 'language'.tr,
          trailing: Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.selectedLanguage == 'ar'
                        ? 'arabic_lang'.tr
                        : 'english_lang'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              )),
          onTap: controller.changeLanguage,
        ),

        _buildProfileOption(
          icon: Icons.description_outlined,
          title: 'description'.tr,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'edit'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.edit,
                size: 16,
                color: Colors.grey[600],
              ),
            ],
          ),
          onTap: controller.editDescription,
        ),

        _buildProfileOption(
          icon: Icons.circle_outlined,
          title: 'state'.tr,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => Text(
                    controller.onlineStatus ? 'online'.tr : 'offline'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  )),
              const SizedBox(width: 12),
              Obx(() => Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          controller.onlineStatus ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          left: controller.onlineStatus ? 18 : 2,
                          top: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          onTap: controller.toggleOnlineStatus,
        ),

        const SizedBox(height: 20),

        // تحديث للشروط والأحكام مع إظهار حالة التحميل
        Obx(() => _buildProfileOption(
              icon: Icons.description,
              title: 'terms_and_conditions'.tr,
              trailing: controller.isLoadingTerms.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                      ),
                    )
                  : !controller.hasTermsUrl
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.isArabic
                                  ? 'غير متوفر'
                                  : 'Not available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        )
                      : const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
              onTap: controller.hasTermsUrl && !controller.isLoadingTerms.value
                  ? controller.openTermsAndConditions
                  : null,
            )),

        // تحديث لسياسة الخصوصية مع إظهار حالة التحميل
        Obx(() => _buildProfileOption(
              icon: Icons.privacy_tip_outlined,
              title: 'privacy_policy'.tr,
              trailing: controller.isLoadingTerms.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                      ),
                    )
                  : !controller.hasPrivacyUrl
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.isArabic
                                  ? 'غير متوفر'
                                  : 'Not available',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        )
                      : const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
              onTap:
                  controller.hasPrivacyUrl && !controller.isLoadingTerms.value
                      ? controller.openPrivacyPolicy
                      : null,
            )),

        _buildProfileOption(
          icon: Icons.support_agent,
          title: 'support'.tr,
          onTap: controller.contactSupport,
        ),

        const SizedBox(height: 20),

        _buildProfileOption(
          icon: Icons.delete_outline,
          title: 'delete_account'.tr,
          titleColor: const Color(0xFFEF4444),
          iconColor: const Color(0xFFEF4444),
          onTap: controller.deleteAccount,
        ),

        _buildProfileOption(
          icon: Icons.logout,
          title: 'log_out'.tr,
          titleColor: const Color(0xFFEF4444),
          iconColor: const Color(0xFFEF4444),
          onTap: controller.logout,
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 24,
                  height: 24,
                  child: Icon(
                    icon,
                    color: iconColor ?? const Color(0xFFEF4444),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                ),

                // Trailing
                if (trailing != null) trailing,
                if (trailing == null)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaIcons() {
    return Obx(() {
      final socialMedia = controller.systemInfo.value?.socialMedia;
      if (socialMedia == null) return const SizedBox.shrink();

      return Column(
        children: [
          Text(
            'follow_us'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              // WhatsApp
              if (socialMedia.whatsapp != null &&
                  socialMedia.whatsapp!.isNotEmpty)
                _buildSocialIcon(
                  color: const Color(0xFF25D366),
                  icon: Bootstrap.whatsapp,
                  onTap: controller.openWhatsApp,
                ),

              // Instagram
              if (socialMedia.instagram != null &&
                  socialMedia.instagram!.isNotEmpty)
                _buildSocialIcon(
                  color: const Color(0xFFE4405F),
                  icon: Bootstrap.instagram,
                  onTap: controller.openInstagram,
                ),

              // Facebook
              if (socialMedia.facebook != null &&
                  socialMedia.facebook!.isNotEmpty)
                _buildSocialIcon(
                  color: const Color(0xFF1877F2),
                  icon: Bootstrap.facebook,
                  onTap: controller.openFacebook,
                ),

              // Snapchat
              if (socialMedia.snapchat != null &&
                  socialMedia.snapchat!.isNotEmpty)
                _buildSocialIcon(
                  color: const Color(0xFFFFFC00),
                  icon: Bootstrap.snapchat,
                  onTap: controller.openSnapchat,
                ),

              // TikTok
              if (socialMedia.tiktok != null && socialMedia.tiktok!.isNotEmpty)
                _buildSocialIcon(
                  color: const Color(0xFF000000),
                  icon: Bootstrap.tiktok,
                  onTap: controller.openTikTok,
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSocialIcon({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color == const Color(0xFFFFFC00) ? Colors.black : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
