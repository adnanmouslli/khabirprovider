import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:khabir/controllers/auth_controller.dart';
import 'package:khabir/routes/app_routes.dart';
import 'package:khabir/utils/colors.dart';
import 'package:khabir/utils/openPrivacyPolicyUrl.dart';
import 'package:khabir/widgets/PhoneField.dart';
import '../services/language_service.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

import '../utils/app_config.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final LanguageService _languageService = Get.find<LanguageService>();
  final ImagePicker _imagePicker = ImagePicker();

  // متغيرات روابط الشروط والأحكام (إضافة جديدة)
  var termsUrls = <String, String?>{}.obs;
  var isLoadingTerms = false.obs;
  var currentTermsUrl = ''.obs;

  // Observable user data
  var user = Rxn<User>();
  var systemInfo = Rxn<SystemInfo>();
  var isLoading = false.obs;

  var isUpdatingImage = false.obs;
  var isOnline = false.obs;

  // Getters for easy access
  String get userName => user.value?.name ?? 'مستخدم';

  String get userPhone => user.value?.phone ?? '';

  String get userState => isOnline.value ? 'Online' : 'Offline';

  String get profileImage =>
      user.value?.image ?? 'assets/images/profile_user.jpg';

  String get userDescription => user.value?.description ?? '';

  String get userAddress => user.value?.address ?? '';

  bool get isVerified => user.value?.isActive ?? false;

  // Language getters
  String get selectedLanguage => _languageService.getCurrentLanguage;

  bool get isArabic => _languageService.isArabic;

  bool get isEnglish => _languageService.isEnglish;

  List<Map<String, String>> get supportedLanguages =>
      _languageService.supportedLanguages;

  bool get onlineStatus => user.value?.onlineStatus ?? false;

  // متغيرات لتغيير رقم الهاتف
  var isRequestingPhoneChange = false.obs;
  var isVerifyingPhoneChange = false.obs;
  var pendingPhoneNumber = ''.obs;
  var otpSent = false.obs;

  // Getters للشروط والأحكام (إضافة جديدة)
  bool get hasTermsUrl => getTermsUrl()?.isNotEmpty ?? false;
  bool get hasPrivacyUrl => getPrivacyUrl()?.isNotEmpty ?? false;

  // الحصول على رابط الشروط والأحكام حسب اللغة الحالية
  String? getTermsUrl() {
    if (termsUrls.isEmpty) return null;
    return isArabic ? termsUrls['terms_ar'] : termsUrls['terms_en'];
  }

  // الحصول على رابط سياسة الخصوصية حسب اللغة الحالية
  String? getPrivacyUrl() {
    if (termsUrls.isEmpty) return null;
    return isArabic ? termsUrls['privacy_ar'] : termsUrls['privacy_en'];
  }

  // دالة مساعدة للحصول على نص حالة الشروط
  String get termsStatusText {
    if (isLoadingTerms.value) {
      return isArabic ? 'جاري التحميل...' : 'Loading...';
    }
    if (!hasTermsUrl) {
      return isArabic ? 'غير متوفر' : 'Not available';
    }
    return isArabic ? 'الشروط والأحكام' : 'Terms and Conditions';
  }

  // دالة مساعدة للحصول على نص حالة سياسة الخصوصية
  String get privacyStatusText {
    if (isLoadingTerms.value) {
      return isArabic ? 'جاري التحميل...' : 'Loading...';
    }
    if (!hasPrivacyUrl) {
      return isArabic ? 'غير متوفر' : 'Not available';
    }
    return isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';
  }

// Timer للعد التنازلي
  var resendTimer = 60.obs;
  Timer? _resendTimer;

  Future<void> requestPhoneChange(String newPhoneNumber) async {
    try {
      // التحقق من صحة الرقم
      if (newPhoneNumber.trim().isEmpty) {
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic
              ? 'يرجى إدخال رقم هاتف صحيح'
              : 'Please enter a valid phone number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // التحقق من أن الرقم مختلف عن الرقم الحالي
      if (newPhoneNumber == userPhone) {
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic
              ? 'هذا هو رقمك الحالي بالفعل'
              : 'This is already your current number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      isRequestingPhoneChange.value = true;

      Get.snackbar(
        isArabic ? 'جاري الإرسال...' : 'Sending...',
        isArabic ? 'يتم إرسال رمز التحقق' : 'Sending verification code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      final response = await _profileService.requestPhoneChange(newPhoneNumber);

      // حفظ الرقم الجديد مؤقتاً
      pendingPhoneNumber.value = newPhoneNumber;
      otpSent.value = true;

      // بدء العد التنازلي
      _startResendTimer();

      Get.snackbar(
        isArabic ? 'تم الإرسال' : 'Sent',
        isArabic
            ? 'تم إرسال رمز التحقق إلى $newPhoneNumber'
            : 'Verification code sent to $newPhoneNumber',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error requesting phone change: $e');

      String errorMessage = isArabic
          ? 'فشل في إرسال رمز التحقق: ${e.toString()}'
          : 'Failed to send verification code: ${e.toString()}';

      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isRequestingPhoneChange.value = false;
    }
  }

// دالة بدء العد التنازلي لإعادة الإرسال
  void _startResendTimer() {
    resendTimer.value = 60;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

// دالة إعادة إرسال OTP
  Future<void> resendOTP() async {
    if (resendTimer.value > 0) {
      Get.snackbar(
        isArabic ? 'تنبيه' : 'Notice',
        isArabic
            ? 'يرجى الانتظار ${resendTimer.value} ثانية'
            : 'Please wait ${resendTimer.value} seconds',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    await requestPhoneChange(pendingPhoneNumber.value);
  }

  Future<void> verifyPhoneChange(String otp) async {
    try {
      // التحقق من صحة OTP
      if (otp.trim().isEmpty || otp.length < 4) {
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic
              ? 'يرجى إدخال رمز التحقق الصحيح'
              : 'Please enter valid verification code',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isVerifyingPhoneChange.value = true;

      Get.snackbar(
        isArabic ? 'جاري التحقق...' : 'Verifying...',
        isArabic ? 'يتم التحقق من الرمز' : 'Verifying code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      final response = await _profileService.verifyPhoneChange(
        newPhoneNumber: pendingPhoneNumber.value,
        otp: otp,
      );

      // تحديث بيانات المستخدم المحلية
      if (user.value != null) {
        user.value = user.value!.copyWith(phone: pendingPhoneNumber.value);
      }

      // إيقاف المؤقت وإعادة تعيين الحالة
      _resendTimer?.cancel();
      otpSent.value = false;
      pendingPhoneNumber.value = '';

      Get.back(); // إغلاق نافذة التحقق

      Get.snackbar(
        isArabic ? 'تم التحديث' : 'Updated',
        isArabic
            ? 'تم تغيير رقم الهاتف بنجاح'
            : 'Phone number changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // تحديث البروفايل
      await loadUserProfile();
    } catch (e) {
      print('Error verifying phone change: $e');

      String errorMessage;
      if (e.toString().contains('Invalid OTP') ||
          e.toString().contains('غير صحيح')) {
        errorMessage =
            isArabic ? 'رمز التحقق غير صحيح' : 'Invalid verification code';
      } else if (e.toString().contains('expired') ||
          e.toString().contains('منتهي')) {
        errorMessage =
            isArabic ? 'انتهت صلاحية رمز التحقق' : 'Verification code expired';
      } else {
        errorMessage =
            isArabic ? 'فشل في التحقق من الرمز' : 'Failed to verify code';
      }

      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isVerifyingPhoneChange.value = false;
    }
  }

  // Custom Dialog Widget
  Widget _buildCustomDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            content,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions.asMap().entries.map((entry) {
                int index = entry.key;
                Widget action = entry.value;
                return Container(
                  margin: EdgeInsets.only(
                    left: isArabic && index > 0 ? 0 : (index > 0 ? 12 : 0),
                    right: isArabic && index > 0 ? 12 : 0,
                  ),
                  child: action,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Button Widget
  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor:
            isPrimary ? const Color(0xFFEF4444) : Colors.transparent,
        foregroundColor: isPrimary ? Colors.white : Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Custom ListTile Widget
  Widget _buildCustomListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFEF4444),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadTermsAndConditions();

    ever(_languageService.currentLanguage, (_) => update());

    // تحديث isOnline عند تغيير user
    ever(user, (User? newUser) {
      if (newUser != null) {
        isOnline.value = newUser.onlineStatus!;
      }
    });
  }

  // تحميل الشروط والأحكام (إضافة جديدة)
  Future<void> loadTermsAndConditions() async {
    try {
      isLoadingTerms.value = true;

      final terms = await _profileService.getTermsAndConditions();
      termsUrls.value = terms;

      print('Terms loaded successfully in ProfileController');
    } catch (e) {
      print('Error loading terms and conditions in ProfileController: $e');
      termsUrls.value = {
        'terms_ar': null,
        'terms_en': null,
        'privacy_en': null,
        'privacy_ar': null
      };
      currentTermsUrl.value = '';
    } finally {
      isLoadingTerms.value = false;
    }
  }

  // فتح صفحة الشروط والأحكام (تحديث الدالة الموجودة)
  Future<void> openTermsAndConditions() async {
    try {
      if (termsUrls.isEmpty || isLoadingTerms.value) {
        await loadTermsAndConditions();
      }

      final termsUrl = getTermsUrl();

      if (termsUrl == null || termsUrl.isEmpty) {
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic
              ? 'رابط الشروط والأحكام غير متوفر حالياً'
              : 'Terms and conditions link is not available currently',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

    final termsTitle = isArabic ? 'الشروط والأحكام' : 'Terms and Conditions';

      openPrivacyPolicyUrl(termsUrl, termsTitle);
    } catch (e) {
      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // فتح صفحة سياسة الخصوصية (تحديث الدالة الموجودة)
  Future<void> openPrivacyPolicy() async {
    try {
      if (termsUrls.isEmpty || isLoadingTerms.value) {
        await loadTermsAndConditions();
      }

      final privacyUrl = getPrivacyUrl();

      if (privacyUrl == null || privacyUrl.isEmpty) {
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic
              ? 'رابط سياسة الخصوصية غير متوفر حالياً'
              : 'Privacy policy link is not available currently',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final privacyTitle = isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';

      openPrivacyPolicyUrl(privacyUrl, privacyTitle);
    } catch (e) {
      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProfileImage() async {
    try {
      // Show image source selection dialog
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      // Pick image from selected source
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // التحقق من حجم الملف قبل الرفع
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > 5 * 1024 * 1024) {
        // 5 ميجا
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic
              ? 'حجم الصورة كبير جداً. يجب أن يكون أقل من 5 ميجا'
              : 'Image size is too large. Must be less than 5MB',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      isUpdatingImage.value = true;

      Get.snackbar(
        isArabic ? 'جاري التحديث...' : 'Updating...',
        isArabic ? 'يتم تحديث صورة الملف الشخصي' : 'Updating profile image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // تحديث البروفايل مع الصورة الجديدة
      await updateProfile(imageFile: file);

      Get.snackbar(
        isArabic ? 'تم التحديث' : 'Updated',
        isArabic
            ? 'تم تحديث صورة الملف الشخصي بنجاح'
            : 'Profile image updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error updating profile image: $e');

      String errorMessage;
      if (e.toString().contains('حجم الصورة كبير')) {
        errorMessage =
            isArabic ? 'حجم الصورة كبير جداً' : 'Image size is too large';
      } else if (e.toString().contains('نوع ملف غير مدعوم')) {
        errorMessage =
            isArabic ? 'نوع الصورة غير مدعوم' : 'Unsupported image type';
      } else if (e.toString().contains('لا يوجد اتصال')) {
        errorMessage =
            isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
      } else {
        errorMessage =
            isArabic ? 'فشل في تحديث الصورة' : 'Failed to update image';
      }

      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isUpdatingImage.value = false;
    }
  }

  // Show image source selection dialog
  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      _buildCustomDialog(
        title: isArabic ? 'اختيار الصورة' : 'Select Image',
        content: Column(
          children: [
            _buildCustomListTile(
              icon: Icons.photo_camera,
              title: isArabic ? 'الكاميرا' : 'Camera',
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            _buildCustomListTile(
              icon: Icons.photo_library,
              title: isArabic ? 'معرض الصور' : 'Gallery',
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          _buildCustomButton(
            text: isArabic ? 'إلغاء' : 'Cancel',
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  // Edit address
  void editAddress() {
    final addressController = TextEditingController(text: userAddress);

    Get.dialog(
      _buildCustomDialog(
        title: isArabic ? 'تعديل العنوان' : 'Edit Address',
        content: TextField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: isArabic ? 'العنوان' : 'Address',
            hintText:
                isArabic ? 'أدخل عنوانك الكامل' : 'Enter your full address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            prefixIcon:
                Icon(Icons.location_on_outlined, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          _buildCustomButton(
            text: isArabic ? 'إلغاء' : 'Cancel',
            onPressed: () => Get.back(),
          ),
          _buildCustomButton(
            text: isArabic ? 'حفظ' : 'Save',
            isPrimary: true,
            onPressed: () async {
              if (addressController.text.trim().isEmpty) {
                Get.snackbar(
                  isArabic ? 'خطأ' : 'Error',
                  isArabic
                      ? 'يرجى إدخال عنوان صحيح'
                      : 'Please enter a valid address',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();
              await updateProfile(address: addressController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  // Load user profile data from API
  Future<void> openSnapchat() async {
    final snapchatUrl = systemInfo.value?.socialMedia.snapchat;
    if (snapchatUrl != null && snapchatUrl.isNotEmpty) {
      await _openUrl(snapchatUrl);
    } else {
      Get.snackbar(
        isArabic ? 'سناب شات' : 'Snapchat',
        isArabic ? 'سيتم فتح سناب شات' : 'Snapchat will be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFFC00),
        colorText: Colors.black,
      );
    }
  }

  Future<void> openTikTok() async {
    final tiktokUrl = systemInfo.value?.socialMedia.tiktok;
    if (tiktokUrl != null && tiktokUrl.isNotEmpty) {
      await _openUrl(tiktokUrl);
    } else {
      Get.snackbar(
        isArabic ? 'تيك توك' : 'TikTok',
        isArabic ? 'سيتم فتح تيك توك' : 'TikTok will be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    }
  }

  Future<void> openFacebook() async {
    final facebookUrl = systemInfo.value?.socialMedia.facebook;
    if (facebookUrl != null && facebookUrl.isNotEmpty) {
      await _openUrl(facebookUrl);
    } else {
      Get.snackbar(
        isArabic ? 'فيسبوك' : 'Facebook',
        isArabic ? 'سيتم فتح فيسبوك' : 'Facebook will be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1877F2),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      // إصلاح الرابط
      if (url.startsWith('/uploads')) {
        url = '${AppConfig.fileUrl}$url';
      } else if (url.startsWith('///')) {
        url = '${AppConfig.fileUrl}${url.substring(2)}';
      } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
        if (url.startsWith('www.') ||
            url.contains('.com') ||
            url.contains('.org')) {
          url = 'https://$url';
        } else {
          url = '${AppConfig.fileUrl}/$url';
        }
      }

      print('Opening URL: $url');

      // التحقق من نوع الملف
      if (url.toLowerCase().endsWith('.pdf')) {
        await _handlePDFUrl(url);
      } else {
        await _handleRegularUrl(url);
      }
    } catch (e) {
      print('Error opening URL: $e');
      _showUrlError(e.toString());
    }
  }

  // التعامل مع روابط PDF
  Future<void> _handlePDFUrl(String url) async {
    await _openInBrowser(url);
  }

  // التعامل مع الروابط العادية
  Future<void> _handleRegularUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
    } else {
      // إذا فشل، جرب في المتصفح
      await _openInBrowser(url);
    }
  }

  // فتح في المتصفح
  Future<void> _openInBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      // إذا فشل، جرب مع intent إضافي (للأندرويد)
      await _tryAlternativeMethod(url);
    }
  }

  // طريقة بديلة لفتح الرابط
  Future<void> _tryAlternativeMethod(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    } catch (e) {
      _showUrlError('Cannot open this link: $e');
    }
  }

  // عرض رسالة خطأ
  void _showUrlError(String error) {
    Get.snackbar(
      isArabic ? 'خطأ' : 'Error',
      isArabic ? 'لا يمكن فتح الرابط: $error' : 'Cannot open link: $error',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // Get user statistics (can be extended later)
  Map<String, dynamic> getUserStats() {
    return {
      'completedJobs': 45,
      'totalEarnings': 2400,
      'rating': 4.8,
      'responseTime': '15 min',
    };
  }

  // Get notification settings (can be extended later)
  Map<String, bool> getNotificationSettings() {
    return {
      'newRequests': true,
      'paymentUpdates': true,
      'promotions': false,
      'systemUpdates': true,
    };
  }

  // Update notification settings
  void updateNotificationSettings(String setting, bool value) {
    // TODO: Update in backend
    Get.snackbar(
      isArabic ? 'تم التحديث' : 'Updated',
      isArabic ? 'تم تحديث إعدادات الإشعارات' : 'Notification settings updated',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  loadUserProfile() async {
    try {
      isLoading.value = true;

      print('Loading user profile...');
      final response = await _profileService.getProfile();

      print('Raw API Response: $response');

      if (response == null || !response.containsKey('provider')) {
        throw Exception('بيانات المستخدم غير موجودة في الاستجابة');
      }

      if (response['provider'] == null) {
        throw Exception('بيانات المزود فارغة');
      }

      print('Creating ProfileResponse from JSON...');
      final profileResponse = ProfileResponse.fromJson(response);

      user.value = profileResponse.user;
      systemInfo.value = profileResponse.systemInfo;

      // ✅ تحديث حالة الاتصال من onlineStatus وليس isActive
      isOnline.value = profileResponse.user.onlineStatus!;

      await _profileService.saveProfileToStorage(response);

      print('Profile loaded successfully');
      print('Online Status: ${profileResponse.user.onlineStatus}');
    } catch (e, stackTrace) {
      print('Error loading profile: $e');
      // باقي معالجة الأخطاء...
    } finally {
      isLoading.value = false;
    }
  }

  // Edit profile
  void editProfile() {
    final nameController = TextEditingController(text: userName);
    final phoneController = TextEditingController(text: userPhone);

    Get.dialog(
      _buildCustomDialog(
        title: isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile',
        content: Column(
          children: [
            // حقل الاسم
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: isArabic ? 'الاسم' : 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                ),
                prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),

            // حقل رقم الهاتف (للعرض فقط)
            TextField(
              controller: phoneController,
              enabled: false, // غير قابل للتعديل مباشرة
              decoration: InputDecoration(
                labelText: isArabic ? 'رقم الهاتف' : 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),

            // زر تغيير رقم الهاتف
            Align(
              alignment:
                  isArabic ? Alignment.centerRight : Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Get.back(); // إغلاق نافذة التعديل
                  _showPhoneChangeDialog(); // فتح نافذة تغيير الرقم
                },
                icon: const Icon(Icons.edit, size: 16),
                label: Text(
                  isArabic ? 'تغيير رقم الهاتف' : 'Change Phone Number',
                  style: const TextStyle(fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
        actions: [
          _buildCustomButton(
            text: isArabic ? 'إلغاء' : 'Cancel',
            onPressed: () => Get.back(),
          ),
          _buildCustomButton(
            text: isArabic ? 'حفظ' : 'Save',
            isPrimary: true,
            onPressed: () async {
              Get.back();
              // تحديث الاسم فقط
              await updateProfile(
                name: nameController.text.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPhoneChangeDialog() {
    final newPhoneController = TextEditingController();
    final otpController = TextEditingController();

    // متغيرات reactive لحالة الأخطاء
    var phoneError = ''.obs;
    var otpError = ''.obs;

    Get.dialog(
      Obx(() => _buildCustomDialog(
            title: isArabic ? 'تغيير رقم الهاتف' : 'Change Phone Number',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // حقل رقم الهاتف الجديد باستخدام PhoneField
                ObxPhoneField(
                  controller: newPhoneController,
                  hintText: isArabic ? '12345678' : '12345678',
                  enabled: !otpSent.value,
                  errorText: phoneError,
                  showValidIcon: true,
                  onChanged: (value) {
                    // مسح رسالة الخطأ عند الكتابة
                    if (phoneError.value.isNotEmpty) {
                      phoneError.value = '';
                    }
                    // التحقق من صحة الرقم
                    if (value.length >= 8) {
                      phoneError.value = '';
                    }
                  },
                ),

                // حقل OTP (يظهر فقط بعد إرسال الرمز)
                if (otpSent.value) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'رمز التحقق' : 'Verification Code',
                      hintText: isArabic
                          ? 'أدخل الرمز المرسل'
                          : 'Enter the code sent',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: otpError.value.isNotEmpty
                              ? Colors.red
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: otpError.value.isNotEmpty
                              ? Colors.red
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.verified_user_outlined,
                        color: otpError.value.isNotEmpty
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      // رسالة الخطأ
                      errorText:
                          otpError.value.isNotEmpty ? otpError.value : null,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (value) {
                      // مسح رسالة الخطأ عند الكتابة
                      if (otpError.value.isNotEmpty) {
                        otpError.value = '';
                      }
                    },
                  ),

                  // زر إعادة الإرسال
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isArabic
                            ? 'لم يصلك الرمز؟'
                            : "Didn't receive the code?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: resendTimer.value == 0
                            ? () async {
                                await resendOTP();
                              }
                            : null,
                        child: Text(
                          resendTimer.value > 0
                              ? '${resendTimer.value}s'
                              : (isArabic ? 'إعادة إرسال' : 'Resend'),
                          style: TextStyle(
                            fontSize: 14,
                            color: resendTimer.value > 0
                                ? Colors.grey[400]
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // رسالة تنبيهية
                if (!otpSent.value) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isArabic
                                ? 'سيتم إرسال رمز التحقق إلى الرقم الجديد'
                                : 'A verification code will be sent to the new number',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              _buildCustomButton(
                text: isArabic ? 'إلغاء' : 'Cancel',
                onPressed: () {
                  _resendTimer?.cancel();
                  otpSent.value = false;
                  pendingPhoneNumber.value = '';
                  phoneError.value = '';
                  otpError.value = '';
                  Get.back();
                },
              ),
              Obx(() => otpSent.value
                  ? _buildCustomButton(
                      text: isVerifyingPhoneChange.value
                          ? (isArabic ? 'جاري التحقق...' : 'Verifying...')
                          : (isArabic ? 'تأكيد' : 'Verify'),
                      isPrimary: true,
                      onPressed: isVerifyingPhoneChange.value
                          ? () {}
                          : () async {
                              // التحقق من صحة OTP
                              if (otpController.text.trim().isEmpty) {
                                otpError.value = isArabic
                                    ? 'يرجى إدخال رمز التحقق'
                                    : 'Please enter verification code';
                                return;
                              }
                              if (otpController.text.trim().length < 4) {
                                otpError.value = isArabic
                                    ? 'رمز التحقق غير صحيح'
                                    : 'Invalid verification code';
                                return;
                              }

                              await verifyPhoneChange(
                                  otpController.text.trim());
                            },
                    )
                  : _buildCustomButton(
                      text: isRequestingPhoneChange.value
                          ? (isArabic ? 'جاري الإرسال...' : 'Sending...')
                          : (isArabic ? 'إرسال الرمز' : 'Send Code'),
                      isPrimary: true,
                      onPressed: isRequestingPhoneChange.value
                          ? () {}
                          : () async {
                              // التحقق من صحة رقم الهاتف
                              final phoneNumber =
                                  newPhoneController.text.trim();

                              if (phoneNumber.isEmpty) {
                                phoneError.value = isArabic
                                    ? 'يرجى إدخال رقم الهاتف'
                                    : 'Please enter phone number';
                                return;
                              }

                              if (phoneNumber.length < 8) {
                                phoneError.value = isArabic
                                    ? 'رقم الهاتف قصير جداً'
                                    : 'Phone number is too short';
                                return;
                              }

                              // إضافة رمز البلد إلى الرقم
                              final fullPhoneNumber = '+968$phoneNumber';
                              await requestPhoneChange(fullPhoneNumber);
                            },
                    )),
            ],
          )),
    );
  }

  // Update profile via API
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? state,
    String? city,
    String? description,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;

      final response = await _profileService.updateProfile(
        name: name,
        phone: phone,
        address: address,
        state: state,
        city: city,
        description: description,
        imageFile: imageFile,
      );

      // تحديث البيانات المحلية في الكنترولر
      if (user.value != null) {
        String? newImageUrl;

        // الحصول على رابط الصورة الجديدة من الاستجابة
        if (imageFile != null) {
          if (response is Map<String, dynamic>) {
            // البحث عن رابط الصورة في مواقع مختلفة في الاستجابة
            var data = response['data'];
            if (data is Map<String, dynamic>) {
              newImageUrl = data['image'] ?? data['image_url'] ?? data['url'];
            }
            newImageUrl ??=
                response['image'] ?? response['image_url'] ?? response['url'];

            // التأكد من أن الرابط صحيح
            if (newImageUrl != null && !newImageUrl.startsWith('http')) {
              newImageUrl = '${AppConfig.baseUrl}$newImageUrl';
            }
          }
        }

        // تحديث بيانات المستخدم المحلية
        user.value = user.value!.copyWith(
          name: name ?? user.value!.name,
          phone: phone ?? user.value!.phone,
          address: address ?? user.value!.address,
          description: description ?? user.value!.description,
          image: newImageUrl ?? user.value!.image,
        );

        print('User data updated locally');
        print('New image URL: $newImageUrl');
      }

      // عرض رسالة نجاح فقط إذا لم تكن تحديث صورة (لتجنب التكرار)
      if (imageFile == null) {
        Get.snackbar(
          isArabic ? 'تم التحديث' : 'Updated',
          isArabic
              ? 'تم تحديث معلومات الملف الشخصي بنجاح'
              : 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating profile: $e');

      String errorMessage;
      if (e.toString().contains('لا يمكن العثور على معرف المزود')) {
        errorMessage = isArabic
            ? 'خطأ في بيانات المستخدم. يرجى إعادة تسجيل الدخول'
            : 'User data error. Please login again';
      } else if (e.toString().contains('لا يوجد اتصال')) {
        errorMessage =
            isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
      } else if (e.toString().contains('انتهت مهلة')) {
        errorMessage = isArabic ? 'انتهت مهلة الاتصال' : 'Connection timeout';
      } else {
        errorMessage =
            isArabic ? 'فشل في تحديث الملف الشخصي' : 'Failed to update profile';
      }

      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Change language
  Future<void> changeLanguage() async {
    Get.dialog(
      _buildCustomDialog(
        title: isArabic ? 'اختيار اللغة' : 'Choose Language',
        content: Column(
          children: supportedLanguages.map((language) {
            return _buildCustomListTile(
              icon: Icons.language,
              title: language['name']!,
              trailing: selectedLanguage == language['code']
                  ? const Icon(Icons.check, color: Color(0xFFEF4444))
                  : null,
              onTap: () async {
                Get.back();
                await updateLanguage(language['code']!);
              },
            );
          }).toList(),
        ),
        actions: [
          _buildCustomButton(
            text: isArabic ? 'إلغاء' : 'Cancel',
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  // Update language
  Future<void> updateLanguage(String languageCode) async {
    try {
      await _languageService.changeLanguage(languageCode);
      Get.snackbar(
        isArabic ? 'تم التغيير' : 'Changed',
        isArabic ? 'تم تغيير اللغة بنجاح' : 'Language changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error changing language: $e');
      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        isArabic ? 'حدث خطأ في تغيير اللغة' : 'Error changing language',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Edit description
  void editDescription() {
    final descriptionController = TextEditingController(text: userDescription);

    Get.dialog(
      _buildCustomDialog(
        title: isArabic ? 'تعديل الوصف' : 'Edit Description',
        content: TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: isArabic ? 'وصف الملف الشخصي' : 'Profile Description',
            hintText: isArabic
                ? 'اكتب وصفاً عن نفسك وخدماتك'
                : 'Write a description about yourself and your services',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 4,
        ),
        actions: [
          _buildCustomButton(
            text: isArabic ? 'إلغاء' : 'Cancel',
            onPressed: () => Get.back(),
          ),
          _buildCustomButton(
            text: isArabic ? 'حفظ' : 'Save',
            isPrimary: true,
            onPressed: () async {
              Get.back();
              await updateProfile(
                  description: descriptionController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  // Toggle online status
  Future<void> toggleOnlineStatus() async {
    try {
      final providerId = _profileService.getProviderIdFromStorage();
      if (providerId == null) {
        throw Exception(
            'لا يمكن العثور على معرف المزود. يرجى إعادة تسجيل الدخول.');
      }

      print('Current online status: ${isOnline.value}');

      // حفظ الحالة القديمة
      final oldStatus = isOnline.value;

      // تغيير الحالة مؤقتاً
      final newStatus = !oldStatus;
      isOnline.value = newStatus;

      Get.snackbar(
        isArabic ? 'جاري التحديث...' : 'Updating...',
        isArabic ? 'يتم تحديث حالتك' : 'Updating your status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      // ✅ استدعاء API لتحديث onlineStatus
      await _profileService.updateProviderStatus(newStatus);

      // تحديث بيانات المستخدم المحلية
      if (user.value != null) {
        user.value = user.value!.copyWith(onlineStatus: newStatus);
      }

      Get.snackbar(
        isArabic ? 'تم التحديث' : 'Updated',
        isArabic
            ? 'أنت الآن ${newStatus ? "متصل" : "غير متصل"}'
            : 'You are now ${newStatus ? "online" : "offline"}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: newStatus ? Colors.green : Colors.grey,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      print('Online status updated to: $newStatus');
    } catch (e) {
      // إرجاع الحالة القديمة في حالة فشل API
      isOnline.value = !isOnline.value;

      print('Error updating online status: $e');

      String errorMessage =
          isArabic ? 'فشل في تحديث الحالة: $e' : 'Failed to update status: $e';

      Get.snackbar(
        isArabic ? 'خطأ' : 'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // WhatsApp handler
  Future<void> handleWhatsAppTap(String phoneNumber) async {
    try {
      final String supportNumber = phoneNumber;
      final String message = Uri.encodeComponent('whatsapp_help_message'.tr);

      final String whatsappUrl = 'https://wa.me/$supportNumber?text=$message';

      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'whatsapp_error_message'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Contact Support
  Future<void> contactSupport() async {
    final whatsappSupport = systemInfo.value?.support.whatsappSupport;

    try {
      await handleWhatsAppTap(whatsappSupport!);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        "الرقم غير متوفر",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      print("Error: ${e}");
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    Get.dialog(
      _buildCustomDialog(
        title: "",
        content: Center(
          child: Column(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'هل أنت متأكد من حذف حسابك؟'
                    : 'Are you sure you want to delete your account?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isArabic
                    ? 'سيتم حذف جميع بياناتك بشكل نهائي ولا يمكن استرجاعها.'
                    : 'All your data will be permanently deleted and cannot be recovered.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          _buildCustomButton(
            text: isArabic ? 'إلغاء' : 'Cancel',
            onPressed: () => Get.back(),
          ),
          _buildCustomButton(
            text: isArabic ? 'متابعة' : 'Continue',
            isPrimary: true,
            onPressed: () {
              Get.back();
              _showDeleteConfirmation();
            },
          ),
        ],
      ),
    );
  }

  // Show delete confirmation with password
  void _showDeleteConfirmation() {
    final passwordController = TextEditingController();
    final passwordError = RxString('');
    final isDeleting = RxBool(false);

    Get.dialog(
      WillPopScope(
        onWillPop: () async => !isDeleting.value,
        child: Obx(
          () => _buildCustomDialog(
            title: isArabic ? 'تأكيد الحذف' : 'Confirm Deletion',
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'تحذير: هذا الإجراء لا يمكن التراجع عنه!'
                          : 'Warning: This action cannot be undone!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              _buildCustomButton(
                text: isArabic ? 'إلغاء' : 'Cancel',
                onPressed: isDeleting.value
                    ? () {}
                    : () {
                        passwordController.dispose();
                        Get.back();
                      },
              ),
              _buildCustomButton(
                text: isDeleting.value
                    ? (isArabic ? 'جاري الحذف...' : 'Deleting...')
                    : (isArabic ? 'حذف الحساب' : 'Delete Account'),
                isPrimary: true,
                onPressed: isDeleting.value
                    ? () {}
                    : () async {
                        await _performAccountDeletion(isDeleting);
                      },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

// تنفيذ حذف الحساب
Future<void> _performAccountDeletion(RxBool isDeleting) async {
  try {
    isDeleting.value = true;

    // عرض رسالة انتظار
    Get.snackbar(
      isArabic ? 'جاري المعالجة...' : 'Processing...',
      isArabic ? 'يتم حذف حسابك' : 'Deleting your account',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // استدعاء API لحذف الحساب
    final response = await _profileService.deleteAccount();

    // إغلاق نافذة التأكيد
    Get.back();

    // ✅ التحقق من النجاح
    if (response['success'] == true) {
      // عرض رسالة نجاح
      Get.snackbar(
        isArabic ? 'تم الحذف بنجاح' : 'Successfully Deleted',
        response['message'] ?? 
          (isArabic
              ? 'تم حذف حسابك بنجاح'
              : 'Your account has been deleted successfully'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // الانتظار قليلاً ثم تسجيل الخروج
      await Future.delayed(const Duration(seconds: 2));

      // تسجيل الخروج وحذف البيانات المحلية
      try {
        final authController = Get.find<AuthController>();
        await authController.logout();
      } catch (e) {
        print('Error during logout: $e');
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    }
  } on AccountDeletionException catch (e) {
    print('AccountDeletionException: ${e.message}');

    String title;
    String message;
    Color backgroundColor;
    IconData icon;

    switch (e.type) {
      case AccountDeletionErrorType.unpaidInvoices:
        title = isArabic ? 'فواتير غير مدفوعة' : 'Unpaid Invoices';
        message = _formatUnpaidInvoicesMessage(e.message);
        backgroundColor = Colors.orange;
        icon = Icons.receipt_long;
        
        // إظهار dialog مع تفاصيل الفواتير
        _showUnpaidInvoicesDialog(e.message);
        return;

      case AccountDeletionErrorType.pendingOrders:
        title = isArabic ? 'طلبات معلقة' : 'Pending Orders';
        message = _formatPendingOrdersMessage(e.message);
        backgroundColor = Colors.orange;
        icon = Icons.pending_actions;
        
        // إظهار dialog مع تفاصيل الطلبات
        _showPendingOrdersDialog(e.message);
        return;

      case AccountDeletionErrorType.unauthorized:
        title = isArabic ? 'انتهت الجلسة' : 'Session Expired';
        message = isArabic
            ? 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى'
            : 'Your session has expired. Please login again';
        backgroundColor = Colors.red;
        icon = Icons.lock_outline;
        
        // تسجيل الخروج تلقائياً
        Future.delayed(const Duration(seconds: 2), () {
          final authController = Get.find<AuthController>();
          authController.logout();
        });
        break;

      case AccountDeletionErrorType.forbidden:
        title = isArabic ? 'غير مسموح' : 'Forbidden';
        message = isArabic
            ? 'ليس لديك صلاحية لحذف هذا الحساب'
            : 'You do not have permission to delete this account';
        backgroundColor = Colors.red;
        icon = Icons.block;
        break;

      case AccountDeletionErrorType.notFound:
        title = isArabic ? 'حساب غير موجود' : 'Account Not Found';
        message = isArabic
            ? 'الحساب غير موجود في النظام'
            : 'Account does not exist in the system';
        backgroundColor = Colors.red;
        icon = Icons.person_off;
        break;

      case AccountDeletionErrorType.serverError:
        title = isArabic ? 'خطأ في السيرفر' : 'Server Error';
        message = isArabic
            ? 'حدث خطأ في السيرفر. يرجى المحاولة لاحقاً'
            : 'A server error occurred. Please try again later';
        backgroundColor = Colors.red;
        icon = Icons.error_outline;
        break;

      case AccountDeletionErrorType.unknown:
      default:
        title = isArabic ? 'خطأ' : 'Error';
        message = e.message;
        backgroundColor = Colors.red;
        icon = Icons.warning_amber;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(16),
    );
  } catch (e) {
    print('Unexpected error deleting account: $e');

    String errorMessage;

    if (e.toString().contains('لا يوجد اتصال') ||
        e.toString().contains('No internet') ||
        e.toString().contains('Network')) {
      errorMessage =
          isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
    } else if (e.toString().contains('timeout') ||
        e.toString().contains('انتهت مهلة')) {
      errorMessage = isArabic
          ? 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى'
          : 'Connection timeout. Please try again';
    } else {
      errorMessage = isArabic
          ? 'فشل في حذف الحساب. يرجى المحاولة مرة أخرى'
          : 'Failed to delete account. Please try again';
    }

    Get.snackbar(
      isArabic ? 'خطأ' : 'Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  } finally {
    isDeleting.value = false;
  }
}


  // ✅ دالة لتنسيق رسالة الفواتير غير المدفوعة
String _formatUnpaidInvoicesMessage(String originalMessage) {
  if (isArabic) {
    // استخراج الأرقام من الرسالة الإنجليزية وعرضها بالعربي
    final regex = RegExp(r'(\d+)\s+unpaid invoice.*?(\d+\.?\d*)\s+SAR.*?(\d+\.?\d*)\s+SAR');
    final match = regex.firstMatch(originalMessage);
    
    if (match != null) {
      final count = match.group(1);
      final commission = match.group(2);
      final total = match.group(3);
      
      return 'لديك $count فاتورة غير مدفوعة بعمولة إجمالية $commission ريال ومبلغ إجمالي $total ريال. يرجى تسوية جميع المدفوعات المعلقة قبل حذف الحساب.';
    }
  }
  
  return originalMessage;
}

// ✅ دالة لتنسيق رسالة الطلبات المعلقة
String _formatPendingOrdersMessage(String originalMessage) {
  if (isArabic) {
    final regex = RegExp(r'(\d+)\s+pending order.*?(\d+\.?\d*)\s+SAR');
    final match = regex.firstMatch(originalMessage);
    
    if (match != null) {
      final count = match.group(1);
      final total = match.group(2);
      
      return 'لديك $count طلب معلق بفواتير غير مدفوعة بمبلغ إجمالي $total ريال. يرجى إكمال أو إلغاء جميع الطلبات المعلقة قبل حذف الحساب.';
    }
  }
  
  return originalMessage;
}

// ✅ Dialog للفواتير غير المدفوعة مع خيار الانتقال للفواتير
void _showUnpaidInvoicesDialog(String message) {
  Get.dialog(
    _buildCustomDialog(
      title: isArabic ? 'فواتير غير مدفوعة' : 'Unpaid Invoices',
      content: Column(
        children: [
          Icon(Icons.receipt_long, color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          Text(
            _formatUnpaidInvoicesMessage(message),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        _buildCustomButton(
          text: isArabic ? 'إغلاق' : 'Close',
          onPressed: () => Get.back(),
        ),
        _buildCustomButton(
          text: isArabic ? 'عرض الفواتير' : 'View Invoices',
          isPrimary: true,
          onPressed: () {
            Get.back();
            Get.back(); // إغلاق dialog حذف الحساب أيضاً
            // التنقل إلى صفحة الفواتير
            Get.toNamed(AppRoutes.INCOME); // أضف المسار المناسب
          },
        ),
      ],
    ),
  );
}

// ✅ Dialog للطلبات المعلقة مع خيار الانتقال للطلبات
void _showPendingOrdersDialog(String message) {
  Get.dialog(
    _buildCustomDialog(
      title: isArabic ? 'طلبات معلقة' : 'Pending Orders',
      content: Column(
        children: [
          Icon(Icons.pending_actions, color: Colors.orange, size: 48),
          const SizedBox(height: 16),
          Text(
            _formatPendingOrdersMessage(message),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        _buildCustomButton(
          text: isArabic ? 'إغلاق' : 'Close',
          onPressed: () => Get.back(),
        ),
        _buildCustomButton(
          text: isArabic ? 'عرض الطلبات' : 'View Orders',
          isPrimary: true,
          onPressed: () {
            Get.back();
            Get.back(); // إغلاق dialog حذف الحساب أيضاً
            // التنقل إلى صفحة الطلبات
            Get.toNamed(AppRoutes.REQUESTS); // أضف المسار المناسب
          },
        ),
      ],
    ),
  );
}

  // Logout
  void logout() {
    final authController = Get.find<AuthController>();
    authController.logout();
  }

  // Social media methods
  Future<void> openWhatsApp() async {
    final whatsappUrl = systemInfo.value?.socialMedia.whatsapp;
    if (whatsappUrl != null && whatsappUrl.isNotEmpty) {
      await _openUrl(whatsappUrl);
    } else {
      Get.snackbar(
        isArabic ? 'واتساب' : 'WhatsApp',
        isArabic ? 'سيتم فتح واتساب' : 'WhatsApp will be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF25D366),
        colorText: Colors.white,
      );
    }
  }

  Future<void> openInstagram() async {
    final instagramUrl = systemInfo.value?.socialMedia.instagram;
    if (instagramUrl != null && instagramUrl.isNotEmpty) {
      await _openUrl(instagramUrl);
    } else {
      Get.snackbar(
        isArabic ? 'إنستغرام' : 'Instagram',
        isArabic ? 'سيتم فتح إنستغرام' : 'Instagram will be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE4405F),
        colorText: Colors.white,
      );
    }
  }
}
