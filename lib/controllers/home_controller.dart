import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:khabir/utils/app_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/provider_ratings_service.dart';
import '../routes/app_routes.dart';
import '../widgets/WelcomeDialog.dart'; // إضافة import للواجهة الترحيبية

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ProviderRatingsService _ratingsService = ProviderRatingsService();

  // مفتاح التخزين لمعرفة ما إذا تم عرض واجهة الترحيب من قبل
  static const String _welcomeShownKey = 'welcome_dialog_shown';

  // Observable variables
  var isLoading = false.obs;
  var isLoadingRating = false.obs;
  var servicesCount = 0.obs;
  var customerRating = 5.0.obs;
  var totalIncome = 0.0.obs;
  var offersCount = 0.obs;

  var notificationsCount = 0.obs;

  var supportPhone = "".obs;

  // User data
  var userName = ''.obs;
  var userType = ''.obs;
  var id = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    // تأخير تحميل التقييم قليلاً للتأكد من تحميل بيانات المستخدم أولاً
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadProviderRating();
      _loadPendingOrdersCount();
    });

    // عرض واجهة الترحيب إذا لم يتم عرضها من قبل
    _checkAndShowWelcomeDialog();
  }

  // التحقق من عرض واجهة الترحيب
  void _checkAndShowWelcomeDialog() {
    // تأخير قصير للتأكد من تحميل الواجهة بالكامل
    Future.delayed(const Duration(milliseconds: 500), () {
      final hasShownWelcome = _storageService.read(_welcomeShownKey) ?? false;

      if (!hasShownWelcome) {
        // عرض واجهة الترحيب
        WelcomeDialog.show();

        // حفظ أن واجهة الترحيب تم عرضها
        _storageService.write(_welcomeShownKey, true);
      }
    });
  }

  // Load user data from storage
  void _loadUserData() {
    try {
      final userData = _storageService.userData;
      print('Raw user data: $userData');

      if (userData.isNotEmpty) {
        // Handle both int and String types for id
        final userIdValue = userData['id'];
        print('User ID value: $userIdValue (type: ${userIdValue.runtimeType})');

        if (userIdValue is int) {
          id.value = userIdValue.toString();
        } else if (userIdValue is String) {
          id.value = userIdValue;
        } else {
          id.value = '';
        }

        userName.value = userData['name']?.toString() ?? '';
        userType.value = userData['user_type']?.toString() ?? '';

        print(
            'Processed - ID: ${id.value}, Name: ${userName.value}, Type: ${userType.value}');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Load provider rating from API
  Future<void> _loadProviderRating() async {
    if (id.value.isEmpty) {
      print('Provider ID is empty, skipping rating load');
      return;
    }

    try {
      isLoadingRating.value = true;

      final providerId = int.tryParse(id.value);
      if (providerId == null) {
        print('Invalid provider ID: ${id.value}');
        customerRating.value = 5.0; // Default value
        return;
      }

      print('Loading rating for provider ID: $providerId');
      final rating = await _ratingsService.getProviderAverageRating(providerId);
      customerRating.value = rating;
      print('Loaded rating: $rating');
    } catch (e) {
      print('Error loading provider rating: $e');
      // Keep default value if API fails
      customerRating.value = 5.0;
    } finally {
      isLoadingRating.value = false;
    }
  }

  // Load pending orders count (notifications)
  Future<void> _loadPendingOrdersCount() async {
    if (id.value.isEmpty) {
      print('Provider ID is empty, skipping pending orders load');
      return;
    }

    try {
      final providerId = id.value;
      final response =
          await _ratingsService.getNotificationCount(int.parse(providerId));

      print('Full API Response: $response');

      if (response != null) {
        notificationsCount.value = response['pendingOrdersCount'] ?? 0;
        servicesCount.value = response['servicesCount'] ?? 0;
        supportPhone.value = response['support']?.toString() ?? "";

        print('Updated notificationsCount: ${notificationsCount.value}');
        print('Updated servicesCount: ${servicesCount.value}');
        print('Updated supportPhone: ${supportPhone.value}');
      } else {
        print('Response is null');
        notificationsCount.value = 0;
        servicesCount.value = 0;
      }
    } catch (e) {
      print('Error loading pending orders count: $e');
      notificationsCount.value = 0;
      servicesCount.value = 0;
    }
  }

  // Navigation methods
  void navigateToServices() {
    Get.toNamed(AppRoutes.SERVICES, arguments: {
      'supportPhone': supportPhone.value,
    });
  }

  void navigateToRequests() {
    Get.toNamed(AppRoutes.REQUESTS);
  }

  void navigateToIncome() {
    Get.toNamed(AppRoutes.INCOME, arguments: {
      'supportPhone': supportPhone.value,
    });
  }

  void navigateToOffers() {
    Get.toNamed(AppRoutes.OFFERS);
  }

  void navigateToReviews() {
    Get.snackbar(
      'reviews'.tr,
      '${'average_rating'.tr}: ${customerRating.value}/5.0',
      backgroundColor: Colors.amber,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Notification handler
  void handleNotificationTap() {
    Get.toNamed(AppRoutes.NOTIFICATIONS);
  }

  // Profile handler
  void handleProfileTap() {
    Get.toNamed(AppRoutes.PROFILE);
  }

  // WhatsApp handler
  Future<void> handleWhatsAppTap() async {
    try {
      final String supportNumber = supportPhone.value;
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

  // Logo tap handler
  void handleLogoTap() {
    Get.snackbar(
      'hello'.tr,
      'welcome_to_khabir_app'.tr,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await Future.wait([
      _loadProviderRating(),
    ]);

    Get.snackbar(
      'updated'.tr,
      'data_updated_successfully'.tr,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Getters for formatted data
  String get formattedIncome => '\$${totalIncome.value.toStringAsFixed(2)}';
  String get formattedRating => customerRating.value.toStringAsFixed(1);

  // Check if user is service provider
  bool get isServiceProvider => userType.value.toLowerCase() == 'provider';

  // Check if user is customer
  bool get isCustomer => userType.value.toLowerCase() == 'customer';
}
