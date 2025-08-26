import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/provider_ratings_service.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ProviderRatingsService _ratingsService = ProviderRatingsService();

  // Observable variables
  var isLoading = false.obs;
  var isLoadingRating = false.obs;
  var servicesCount = 6.obs;
  var requestsCount = 12.obs;
  var customerRating = 5.0.obs;
  var totalIncome = 0.0.obs;
  var offersCount = 0.obs;

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
    });
    // _loadDashboardData();
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

        print('Processed - ID: ${id.value}, Name: ${userName.value}, Type: ${userType.value}');
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

  // Load dashboard data from API
  Future<void> _loadDashboardData() async {
    try {
      isLoading.value = true;

      final response = await _apiService.get('dashboard');

      if (response.body['success'] == true) {
        final data = response.body['data'];

        servicesCount.value = data['services_count'] ?? 6;
        requestsCount.value = data['requests_count'] ?? 12;
        totalIncome.value = (data['total_income'] ?? 0.0).toDouble();
        offersCount.value = data['offers_count'] ?? 0;
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      // Use default values if API fails
      _setDefaultValues();
    } finally {
      isLoading.value = false;
    }
  }

  // Set default values
  void _setDefaultValues() {
    servicesCount.value = 6;
    requestsCount.value = 12;
    totalIncome.value = 0.0;
    offersCount.value = 0;
  }

  // Navigation methods
  void navigateToServices() {
    Get.toNamed(AppRoutes.SERVICES);
  }

  void navigateToRequests() {
    Get.toNamed(AppRoutes.REQUESTS);
  }

  void navigateToIncome() {
    Get.toNamed(AppRoutes.INCOME);
  }

  void navigateToOffers() {
    Get.toNamed(AppRoutes.OFFERS);
  }

  void navigateToReviews() {
    // Get.toNamed('/reviews');
    // Temporary snackbar for demonstration
    Get.snackbar(
      'التقييمات',
      'متوسط التقييم: ${customerRating.value}/5.0',
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
      const String supportNumber = '+963999999999';
      final String message = Uri.encodeComponent(
          'مرحباً، أحتاج للمساعدة في تطبيق خبير'
      );

      final String whatsappUrl = 'https://wa.me/$supportNumber?text=$message';

      // Try to launch WhatsApp
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );

      } else {
        // Fallback if WhatsApp is not installed
        Get.snackbar(
          'خطأ',
          'لا يمكن فتح واتساب. تأكد من وجود التطبيق على جهازك',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء محاولة فتح واتساب',
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
      'مرحباً',
      'مرحباً بك في تطبيق خبير',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    await Future.wait([
      _loadDashboardData(),
      _loadProviderRating(),
    ]);

    Get.snackbar(
      'تم التحديث',
      'تم تحديث البيانات بنجاح',
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