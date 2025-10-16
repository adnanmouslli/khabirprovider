import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:khabir/utils/colors.dart';

class TopBar extends StatelessWidget {
  final bool showNotification;
  final bool showProfile;
  final bool showWhatsApp;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onLogoTap;
  final int notificationCount;

  const TopBar({
    Key? key,
    this.showNotification = true,
    this.showProfile = true,
    this.showWhatsApp = true,
    this.onNotificationTap,
    this.onProfileTap,
    this.onWhatsAppTap,
    this.onLogoTap,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // Left side icons
          Row(
            children: [
              // Notification icon
              if (showNotification)
                GestureDetector(
                  onTap: onNotificationTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.black54,
                            size: 24,
                          ),
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  notificationCount > 9 ? '9+' : '$notificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              if (showNotification && (showProfile || showWhatsApp))
                const SizedBox(width: 16),

              // Profile icon
              if (showProfile)
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                  ),
                ),

              if (showProfile && showWhatsApp)
                const SizedBox(width: 16),

              // WhatsApp icon
              if (showWhatsApp)
                GestureDetector(
                  onTap: onWhatsAppTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Bootstrap.whatsapp,
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Logo/Brand
          GestureDetector(
            onTap: onLogoTap,
            child: Container(
              height: 40,
              child: Image.asset(
                'assets/icons/logo_sm.png',
                height: 40,  // تكبير من 50 إلى 65
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback widget in case logo fails to load
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,  // تكبير من 40 إلى 50
                        height: 50, // تكبير من 40 إلى 50
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.build,
                            color: Colors.white,
                            size: 30,  // تكبير من 24 إلى 30
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
                              fontSize: 18,  // تكبير من 16 إلى 18
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEF4444),
                              height: 1.0,
                            ),
                          ),
                          const Text(
                            'khabir',
                            style: TextStyle(
                              fontSize: 16,  // تكبير من 14 إلى 16
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
}