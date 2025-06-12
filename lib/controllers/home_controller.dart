import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Observable variables
  var isLoading = false.obs;
  var servicesCount = 6.obs;
  var requestsCount = 12.obs;
  var customerRating = 5.0.obs;
  var totalIncome = 0.0.obs;
  var offersCount = 0.obs;

  // User data
  var userName = ''.obs;
  var userType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadDashboardData();
  }

  // Load user data from storage
  void _loadUserData() {
    try {
      final userData = _storageService.userData;
      if (userData.isNotEmpty) {
        userName.value = userData['name'] ?? '';
        userType.value = userData['user_type'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
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
        customerRating.value = (data['rating'] ?? 5.0).toDouble();
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
    customerRating.value = 5.0;
    totalIncome.value = 0.0;
    offersCount.value = 0;
  }

  // Navigation methods
  void navigateToServices() {
    // Get.toNamed('/services');
    // Temporary snackbar for demonstration
    Get.snackbar(
      'الخدمات',
      'عدد الخدمات: ${servicesCount.value}',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToRequests() {
    // Get.toNamed('/requests');
    // Temporary snackbar for demonstration
    Get.snackbar(
      'الطلبات',
      'عدد الطلبات: ${requestsCount.value}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToIncome() {
    // Get.toNamed('/income');
    // Temporary snackbar for demonstration
    Get.snackbar(
      'الدخل',
      'إجمالي الدخل: \$${totalIncome.value.toStringAsFixed(2)}',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void navigateToOffers() {
    // Get.toNamed('/offers');
    // Temporary snackbar for demonstration
    Get.snackbar(
      'العروض',
      'عدد العروض المتاحة: ${offersCount.value}',
      backgroundColor: Colors.purple,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
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
    // Get.toNamed('/notifications');
    Get.snackbar(
      'الإشعارات',
      'لديك إشعارات جديدة',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Profile handler
  void handleProfileTap() {
    // Get.toNamed('/profile');
    Get.snackbar(
      'الملف الشخصي',
      'مرحباً ${userName.value}',
      backgroundColor: Colors.indigo,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  // WhatsApp handler
  void handleWhatsAppTap() {
    // Here you would typically open WhatsApp or a chat feature
    Get.snackbar(
      'التواصل',
      'فتح محادثة الدعم',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
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
    await _loadDashboardData();
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