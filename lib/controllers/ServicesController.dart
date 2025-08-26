import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/service_model.dart';
import '../services/services_service.dart';
import '../routes/app_routes.dart';

class ServicesController extends GetxController {
  final ServicesService _servicesService = ServicesService();

  // Observable lists
  var providerServices = <ProviderServiceModel>[].obs;
  var allServices = <ServiceModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var servicesByCategory = <ServiceModel>[].obs;

  // Loading states
  var isLoading = false.obs;
  var isLoadingCategories = false.obs;
  var isLoadingServices = false.obs;
  var isAddingServices = false.obs;
  var isUpdatingPrice = false.obs;
  var isTogglingStatus = false.obs;
  var isDeletingService = false.obs;
  var isRefreshing = false.obs;

  // Service-specific loading states
  var updatingPriceServiceId = Rxn<int>();
  var togglingStatusServiceId = Rxn<int>();
  var deletingServiceId = Rxn<int>();

  // Selected category
  var selectedCategoryId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // تحميل البيانات الأولية
  Future<void> loadInitialData() async {
    await Future.wait([
      loadProviderServices(),
      loadCategories(),
      loadAllServices(),
    ]);
  }

  // جلب خدمات المزود
  Future<void> loadProviderServices() async {
    try {
      isLoading.value = true;
      final services = await _servicesService.getProviderServices();
      providerServices.value = services;
    } catch (e) {
      _showErrorSnackbar('خطأ في جلب خدماتك', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // جلب جميع الأصناف
  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final categoriesList = await _servicesService.getAllCategories();
      categories.value = categoriesList;
    } catch (e) {
      _showErrorSnackbar('خطأ في جلب الأصناف', e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // جلب جميع الخدمات
  Future<void> loadAllServices() async {
    try {
      isLoadingServices.value = true;
      final services = await _servicesService.getAllServices();
      allServices.value = services;
    } catch (e) {
      _showErrorSnackbar('خطأ في جلب الخدمات', e.toString());
    } finally {
      isLoadingServices.value = false;
    }
  }

  // جلب الخدمات حسب الصنف
  Future<void> loadServicesByCategory(int categoryId) async {
    try {
      selectedCategoryId.value = categoryId;
      isLoadingServices.value = true;
      final services = await _servicesService.getServicesByCategory(categoryId);
      servicesByCategory.value = services;
    } catch (e) {
      _showErrorSnackbar('خطأ في جلب خدمات الصنف', e.toString());
    } finally {
      isLoadingServices.value = false;
    }
  }

  // التنقل إلى صفحة إضافة خدمة
  void navigateToAddService() {
    Get.toNamed(AppRoutes.ADD_SERVICE)?.then((result) {
      if (result != null) {
        // تحديث القائمة بعد إضافة خدمات جديدة
        loadProviderServices();
      }
    });
  }

  // إضافة خدمات متعددة
  Future<void> addMultipleServices(List<AddServiceRequest> services) async {
    try {
      isAddingServices.value = true;

      // إظهار Loading Dialog
      _showLoadingDialog('جاري إضافة الخدمات...');

      final response = await _servicesService.addMultipleServices(services);

      // تحديث القائمة المحلية
      providerServices.addAll(response.services);

      // إغلاق Loading Dialog
      Get.back();

      _showSuccessSnackbar('تم بنجاح', response.message);

      // العودة إلى الصفحة السابقة
      Get.back(result: true);
    } catch (e) {
      // إغلاق Loading Dialog في حالة الخطأ
      if (Get.isDialogOpen ?? false) Get.back();
      _showErrorSnackbar('خطأ في إضافة الخدمات', e.toString());
    } finally {
      isAddingServices.value = false;
    }
  }

  // تحديث سعر خدمة
  Future<void> updateServicePrice(int providerServiceId, double newPrice) async {
    try {
      isUpdatingPrice.value = true;
      updatingPriceServiceId.value = providerServiceId;

      final updatedService = await _servicesService.updateProviderServicePrice(
        providerServiceId,
        newPrice,
      );

      // تحديث الخدمة في القائمة المحلية
      final index = providerServices.indexWhere((s) => s.id == providerServiceId);
      if (index != -1) {
        providerServices[index] = updatedService;
      }

      _showSuccessSnackbar('تم التحديث', 'تم تحديث سعر الخدمة بنجاح');
    } catch (e) {
      _showErrorSnackbar('خطأ في تحديث السعر', e.toString());
    } finally {
      isUpdatingPrice.value = false;
      updatingPriceServiceId.value = null;
    }
  }

  // تبديل حالة الخدمة
  Future<void> toggleServiceStatus(int providerServiceId) async {
    try {
      isTogglingStatus.value = true;
      togglingStatusServiceId.value = providerServiceId;

      final updatedService = await _servicesService.toggleProviderServiceStatus(
        providerServiceId,
      );

      // تحديث الخدمة في القائمة المحلية
      final index = providerServices.indexWhere((s) => s.id == providerServiceId);
      if (index != -1) {
        providerServices[index] = updatedService;
      }

      final statusText = updatedService.isActive ? 'مفعلة' : 'معطلة';
      _showSuccessSnackbar('تم التحديث', 'الخدمة الآن $statusText');
    } catch (e) {
      _showErrorSnackbar('خطأ في تحديث حالة الخدمة', e.toString());
    } finally {
      isTogglingStatus.value = false;
      togglingStatusServiceId.value = null;
    }
  }

  // حذف خدمة
  void deleteService(int providerServiceId) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف الخدمة'),
        content: const Text('هل أنت متأكد من حذف هذه الخدمة؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // إغلاق الحوار أولاً
              await _deleteService(providerServiceId);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // تنفيذ حذف الخدمة
  Future<void> _deleteService(int providerServiceId) async {
    try {
      isDeletingService.value = true;
      deletingServiceId.value = providerServiceId;

      await _servicesService.deleteProviderService(providerServiceId);

      // إزالة الخدمة من القائمة المحلية
      providerServices.removeWhere((service) => service.id == providerServiceId);

      _showSuccessSnackbar('تم الحذف', 'تم حذف الخدمة بنجاح');
    } catch (e) {
      _showErrorSnackbar('خطأ في حذف الخدمة', e.toString());
    } finally {
      isDeletingService.value = false;
      deletingServiceId.value = null;
    }
  }

  // تحديث سعر خدمة مع إظهار حوار
  void editServicePrice(ProviderServiceModel service) {
    final TextEditingController priceController = TextEditingController(
      text: service.price.toString(),
    );

    Get.dialog(
      AlertDialog(
        title: Text('تعديل سعر ${service.service?.title ?? 'الخدمة'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر الجديد',
                suffixText: 'OMR',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          Obx(() => TextButton(
            onPressed: isUpdatingPrice.value ? null : () {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null && newPrice > 0) {
                Get.back();
                updateServicePrice(service.id, newPrice);
              } else {
                _showErrorSnackbar('خطأ', 'يرجى إدخال سعر صحيح');
              }
            },
            child: isUpdatingPrice.value && updatingPriceServiceId.value == service.id
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('تحديث'),
          )),
        ],
      ),
    );
  }

  // إظهار حوار طلب خدمة جديدة
  void showAddServiceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('طلب خدمة جديدة'),
        content: const Text(
            'هل تريد طلب إضافة خدمة غير موجودة في القائمة؟'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showContactAdminSnackbar();
            },
            child: const Text('طلب'),
          ),
        ],
      ),
    );
  }

  // الحصول على الخدمات المتاحة للإضافة (غير مضافة بعد)
  List<ServiceModel> getAvailableServices() {
    final providerServiceIds = providerServices.map((ps) => ps.serviceId).toSet();
    return allServices.where((service) => !providerServiceIds.contains(service.id)).toList();
  }

  // إعادة تحميل البيانات
  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;
      await loadInitialData();
    } finally {
      isRefreshing.value = false;
    }
  }

  // التحقق من loading state لخدمة معينة
  bool isServiceLoading(int serviceId, String operation) {
    switch (operation) {
      case 'price':
        return isUpdatingPrice.value && updatingPriceServiceId.value == serviceId;
      case 'status':
        return isTogglingStatus.value && togglingStatusServiceId.value == serviceId;
      case 'delete':
        return isDeletingService.value && deletingServiceId.value == serviceId;
      default:
        return false;
    }
  }

  // إظهار Loading Dialog
  void _showLoadingDialog(String message) {
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // إظهار رسالة نجاح
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // إظهار رسالة خطأ
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  // إظهار رسالة للتواصل مع الإدارة
  void _showContactAdminSnackbar() {
    Get.snackbar(
      'تواصل مع الإدارة',
      'يرجى التواصل مع فريق الدعم لإضافة خدمة جديدة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }
}