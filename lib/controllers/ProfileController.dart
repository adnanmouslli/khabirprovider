import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:khabir/controllers/auth_controller.dart';
import '../services/language_service.dart';
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../utils/app_config.dart';
import '../view/profile/PDFViewerScreen.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final LanguageService _languageService = Get.find<LanguageService>();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable user data
  var user = Rxn<User>();
  var systemInfo = Rxn<SystemInfo>();
  var isLoading = false.obs;
  var isOnline = false.obs;
  var isUpdatingImage = false.obs;

  // Getters for easy access
  String get userName => user.value?.name ?? 'مستخدم';

  String get userPhone => user.value?.phone ?? '';

  String get userEmail => user.value?.email ?? '';

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

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    ever(_languageService.currentLanguage, (_) => update());
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

      if (fileSize > 5 * 1024 * 1024) { // 5 ميجا
        Get.snackbar(
          isArabic ? 'خطأ' : 'Error',
          isArabic ? 'حجم الصورة كبير جداً. يجب أن يكون أقل من 5 ميجا' : 'Image size is too large. Must be less than 5MB',
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
        isArabic ? 'تم تحديث صورة الملف الشخصي بنجاح' : 'Profile image updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      print('Error updating profile image: $e');

      String errorMessage;
      if (e.toString().contains('حجم الصورة كبير')) {
        errorMessage = isArabic ? 'حجم الصورة كبير جداً' : 'Image size is too large';
      } else if (e.toString().contains('نوع ملف غير مدعوم')) {
        errorMessage = isArabic ? 'نوع الصورة غير مدعوم' : 'Unsupported image type';
      } else if (e.toString().contains('لا يوجد اتصال')) {
        errorMessage = isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
      } else {
        errorMessage = isArabic ? 'فشل في تحديث الصورة' : 'Failed to update image';
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
      AlertDialog(
        title: Text(isArabic ? 'اختيار الصورة' : 'Select Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFFEF4444)),
              title: Text(isArabic ? 'الكاميرا' : 'Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFEF4444)),
              title: Text(isArabic ? 'معرض الصور' : 'Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  // Edit address
  void editAddress() {
    final addressController = TextEditingController(text: userAddress);

    Get.dialog(
      AlertDialog(
        title: Text(isArabic ? 'تعديل العنوان' : 'Edit Address'),
        content: TextField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: isArabic ? 'العنوان' : 'Address',
            hintText: isArabic ? 'أدخل عنوانك الكامل' : 'Enter your full address',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (addressController.text.trim().isEmpty) {
                Get.snackbar(
                  isArabic ? 'خطأ' : 'Error',
                  isArabic ? 'يرجى إدخال عنوان صحيح' : 'Please enter a valid address',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();
              await updateProfile(address: addressController.text.trim());
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
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
      }
      else if (url.startsWith('///')) {
        url = '${AppConfig.fileUrl}${url.substring(2)}';
      }
      else if (!url.startsWith('http://') && !url.startsWith('https://')) {
        if (url.startsWith('www.') || url.contains('.com') || url.contains('.org')) {
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

      // التحقق من وجود البيانات المطلوبة
      if (response == null) {
        throw Exception('لا توجد بيانات من الخادم');
      }

      if (!response.containsKey('provider')) {
        throw Exception('بيانات المستخدم غير موجودة في الاستجابة');
      }

      if (!response.containsKey('systemInfo')) {
        throw Exception('معلومات النظام غير موجودة في الاستجابة');
      }

      // التحقق من أن بيانات provider ليست null
      if (response['provider'] == null) {
        throw Exception('بيانات المزود فارغة');
      }

      print('Creating ProfileResponse from JSON...');
      final profileResponse = ProfileResponse.fromJson(response);

      print('ProfileResponse created successfully');
      print('User: ${profileResponse.user.name}');
      print('Email: ${profileResponse.user.email}');
      print('User ID: ${profileResponse.user.id}');

      user.value = profileResponse.user;
      systemInfo.value = profileResponse.systemInfo;

      // Set online status based on user activity
      isOnline.value = profileResponse.user.isActive;

      // حفظ بيانات البروفايل في التخزين المحلي
      await _profileService.saveProfileToStorage(response);

      print('Profile loaded and saved successfully');

    } catch (e, stackTrace) {
      print('Error loading profile: $e');
      print('Stack trace: $stackTrace');

      String errorMessage;
      if (e.toString().contains('type \'Null\' is not a subtype')) {
        errorMessage = 'خطأ في تحليل البيانات من الخادم';
      } else if (e.toString().contains('لا توجد بيانات')) {
        errorMessage = 'لا توجد بيانات من الخادم';
      } else if (e.toString().contains('بيانات المستخدم غير موجودة')) {
        errorMessage = 'بيانات المستخدم غير موجودة في الاستجابة';
      } else {
        errorMessage = 'فشل في تحميل بيانات الملف الشخصي: $e';
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Edit profile
  void editProfile() {
    final nameController = TextEditingController(text: userName);
    final phoneController = TextEditingController(text: userPhone);
    final emailController = TextEditingController(text: userEmail);

    Get.dialog(
      AlertDialog(
        title: Text(isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'الاسم' : 'Name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'رقم الهاتف' : 'Phone Number',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await updateProfile(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim(),
              );
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  // Update profile via API
  Future<void> updateProfile({
    String? name,
    String? email,
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
        email: email,
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
            newImageUrl ??= response['image'] ?? response['image_url'] ?? response['url'];

            // التأكد من أن الرابط صحيح
            if (newImageUrl != null && !newImageUrl.startsWith('http')) {
              newImageUrl = '${AppConfig.baseUrl}$newImageUrl';
            }
          }
        }

        // تحديث بيانات المستخدم المحلية
        user.value = user.value!.copyWith(
          name: name ?? user.value!.name,
          email: email ?? user.value!.email,
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
        errorMessage = isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
      } else if (e.toString().contains('انتهت مهلة')) {
        errorMessage = isArabic ? 'انتهت مهلة الاتصال' : 'Connection timeout';
      } else {
        errorMessage = isArabic
            ? 'فشل في تحديث الملف الشخصي'
            : 'Failed to update profile';
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
      AlertDialog(
        title: Text(isArabic ? 'اختيار اللغة' : 'Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLanguages.map((language) {
            return ListTile(
              title: Text(language['name']!),
              trailing: selectedLanguage == language['code']
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () async {
                Get.back();
                await updateLanguage(language['code']!);
              },
            );
          }).toList(),
        ),
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
      AlertDialog(
        title: Text(isArabic ? 'تعديل الوصف' : 'Edit Description'),
        content: TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: isArabic ? 'وصف الملف الشخصي' : 'Profile Description',
            hintText: isArabic ? 'اكتب وصفاً عن نفسك وخدماتك' : 'Write a description about yourself and your services',
            border: const OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await updateProfile(description: descriptionController.text.trim());
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  // Toggle online status
  Future<void> toggleOnlineStatus() async {
    try {
      // التحقق من وجود ID المزود قبل محاولة التحديث
      final providerId = _profileService.getProviderIdFromStorage();
      if (providerId == null) {
        throw Exception('لا يمكن العثور على معرف المزود. يرجى إعادة تسجيل الدخول.');
      }

      print('Provider ID found: $providerId');

      // حفظ الحالة القديمة في حالة فشل API
      final oldStatus = isOnline.value;

      // تغيير الحالة مؤقتاً لإظهار التغيير فوراً
      isOnline.value = !isOnline.value;

      // إظهار رسالة تحميل
      Get.snackbar(
        isArabic ? 'جاري التحديث...' : 'Updating...',
        isArabic ? 'يتم تحديث حالتك' : 'Updating your status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      // استدعاء API لتحديث الحالة
      await _profileService.updateProviderStatus(isOnline.value);

      // تحديث بيانات المستخدم المحلية
      if (user.value != null) {
        user.value = user.value!.copyWith(isActive: isOnline.value);
      }

      // إظهار رسالة نجاح
      Get.snackbar(
        isArabic ? 'تم التحديث' : 'Updated',
        isArabic
            ? 'أنت الآن ${isOnline.value ? "متصل" : "غير متصل"}'
            : 'You are now ${isOnline.value ? "online" : "offline"}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isOnline.value ? Colors.green : Colors.grey,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      // في حالة فشل API، إرجاع الحالة القديمة
      isOnline.value = !isOnline.value;

      print('Error updating provider status: $e');

      String errorMessage;
      if (e.toString().contains('لا يمكن العثور على معرف المزود')) {
        errorMessage = isArabic
            ? 'خطأ في بيانات المستخدم. يرجى إعادة تسجيل الدخول.'
            : 'User data error. Please login again.';
      } else {
        errorMessage = isArabic
            ? 'فشل في تحديث الحالة: $e'
            : 'Failed to update status: $e';
      }

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

  // Open Terms and Conditions
  Future<void> openTermsAndConditions() async {
    final termsUrl = isArabic
        ? systemInfo.value?.legalDocuments.termsAr
        : systemInfo.value?.legalDocuments.termsEn;

    if (termsUrl != null && termsUrl.isNotEmpty) {
      await _openUrl(termsUrl);
    } else {
      Get.snackbar(
        isArabic ? 'الشروط والأحكام' : 'Terms and Conditions',
        isArabic
            ? 'سيتم فتح صفحة الشروط والأحكام'
            : 'Terms page will be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  // Open Privacy Policy
  Future<void> openPrivacyPolicy() async {
    final privacyUrl = isArabic
        ? systemInfo.value?.legalDocuments.privacyAr
        : systemInfo.value?.legalDocuments.privacyEn;

    if (privacyUrl != null && privacyUrl.isNotEmpty) {
      await _openUrl(privacyUrl);
    } else {
      Get.snackbar(
        isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
        isArabic
            ? 'سيتم فتح صفحة سياسة الخصوصية'
            : 'Privacy page will be opened',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  // Contact Support
  Future<void> contactSupport() async {
    final whatsappSupport = systemInfo.value?.support.whatsappSupport;

    Get.dialog(
      AlertDialog(
        title: Text(isArabic ? 'الدعم الفني' : 'Technical Support'),
        content: Text(isArabic
            ? 'اختر طريقة التواصل مع الدعم الفني:'
            : 'Choose how to contact technical support:'),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              if (whatsappSupport != null && whatsappSupport.isNotEmpty) {
                await _openUrl(whatsappSupport);
              } else {
                Get.snackbar(
                  isArabic ? 'واتساب' : 'WhatsApp',
                  isArabic
                      ? 'سيتم فتح محادثة واتساب مع الدعم الفني'
                      : 'WhatsApp support will be opened',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: Text(isArabic ? 'واتساب' : 'WhatsApp'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                isArabic ? 'البريد الإلكتروني' : 'Email',
                isArabic
                    ? 'سيتم فتح تطبيق البريد الإلكتروني'
                    : 'Email app will be opened',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            child: Text(isArabic ? 'البريد الإلكتروني' : 'Email'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  // Delete Account
  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: Text(isArabic ? 'حذف الحساب' : 'Delete Account'),
        content: Text(isArabic
            ? 'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.'
            : 'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showDeleteConfirmation();
            },
            child: Text(
              isArabic ? 'حذف' : 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Show delete confirmation
  void _showDeleteConfirmation() {
    final deleteController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(isArabic ? 'تأكيد الحذف' : 'Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isArabic
                ? 'اكتب "DELETE" لتأكيد حذف الحساب:'
                : 'Type "DELETE" to confirm account deletion:'),
            const SizedBox(height: 16),
            TextField(
              controller: deleteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (deleteController.text == 'DELETE') {
                Get.back();
                // TODO: Implement account deletion API call
                Get.snackbar(
                  isArabic ? 'تم الحذف' : 'Deleted',
                  isArabic
                      ? 'تم حذف حسابك بنجاح'
                      : 'Your account has been deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  isArabic ? 'خطأ' : 'Error',
                  isArabic
                      ? 'يجب كتابة DELETE بالضبط'
                      : 'You must type DELETE exactly',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: Text(
              isArabic ? 'تأكيد الحذف' : 'Confirm Delete',
              style: const TextStyle(color: Colors.red),
            ),
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