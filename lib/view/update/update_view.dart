import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE53E3E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.system_update,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'تحديث متوفر',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 16),
              Text(
                'يتوفر إصدار جديد من التطبيق\nيرجى التحديث للحصول على أحدث الميزات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Cairo',
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => openPlayStore(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE53E3E),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'تحديث الآن',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // فتح Google Play Store
  Future<void> openPlayStore() async {
    const String packageName = 'com.akwan.khabirprovider_new';

    try {
      // رابط Google Play Store
      final Uri playStoreUri = Uri.parse('market://details?id=$packageName');
      final Uri browserUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=$packageName');

      // محاولة فتح التطبيق في Google Play Store
      if (Platform.isAndroid) {
        bool launched = await launchUrl(
          playStoreUri,
          mode: LaunchMode.externalApplication,
        );

        // إذا فشل فتح التطبيق، افتح في المتصفح
        if (!launched) {
          await launchUrl(
            browserUri,
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        // للمنصات الأخرى، افتح في المتصفح
        await launchUrl(
          browserUri,
          mode: LaunchMode.externalApplication,
        );
      }

      Get.snackbar(
        'جاري التحديث',
        'تم فتح متجر التطبيقات',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('خطأ في فتح متجر التطبيقات: $e');

      Get.snackbar(
        'خطأ',
        'لا يمكن فتح متجر التطبيقات. يرجى البحث عن "خبير" في متجر التطبيقات يدوياً',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
      );
    }
  }
}
