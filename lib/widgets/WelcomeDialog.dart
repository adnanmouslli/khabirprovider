import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/services/language_service.dart';

class WelcomeDialog extends StatelessWidget {
  WelcomeDialog({Key? key}) : super(key: key);

  // تحديد اللغة الحالية
  final LanguageService _languageService = Get.find<LanguageService>();

  String get selectedLanguage => _languageService.getCurrentLanguage;

  bool get isArabic => _languageService.isArabic;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Image.asset(
              'assets/icons/khabir_logo.png',
              width: 100,
              height: 80,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              isArabic
                  ? 'مرحباً بك في تطبيق خبير'
                  : 'Welcome to the khabir app',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              isArabic
                  ? 'نحن سعداء بانضمامك إلى\nعائلة خبير'
                  : 'We are happy to welcome you to the\nkhabir family',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 40),

            // OK Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isArabic ? 'موافق' : 'OK',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة static لعرض الـ dialog بسهولة
  static void show() {
    Get.dialog(
       WelcomeDialog(),
      barrierDismissible: false, // لا يمكن إغلاقه بالنقر خارجه
    );
  }
}
