import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/services/language_service.dart';

class AccountPendingApprovalDialog extends StatelessWidget {
  AccountPendingApprovalDialog({Key? key}) : super(key: key);

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
        padding: const EdgeInsets.all(24),
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
            // Close button (top right)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    // الانتقال لصفحة تسجيل الدخول بعد إغلاق الـ dialog
                    Get.offAllNamed('/login'); // أو مسار صفحة تسجيل الدخول
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Logo
            Image.asset(
              'assets/icons/khabir_logo.png',
              width: 100,
              height: 80,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              isArabic
                  ? 'تم تسجيل بياناتك\nبنجاح'
                  : 'Your data has been\nsuccessfully recorded',
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
                  ? 'يرجى انتظار تواصل فريق الدعم التقني\nمعك لاعتماد طلبك'
                  : 'Please wait until the technical support\nteam contacts you for approval',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            // OK Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  // الانتقال لصفحة تسجيل الدخول
                  Get.offAllNamed('/login'); // أو استخدم AppRoutes.LOGIN
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFEF4444), // نفس اللون الأحمر في الصورة
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
      AccountPendingApprovalDialog(),
      barrierDismissible: false, // لا يمكن إغلاقه بالنقر خارجه
    );
  }
}
