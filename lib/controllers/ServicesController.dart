import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/services/language_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/service_model.dart';
import '../services/services_service.dart';
import '../routes/app_routes.dart';

class ServicesController extends GetxController {
  final ServicesService _servicesService = ServicesService();

  final LanguageService _languageService = Get.find<LanguageService>();

  bool get isArabic => _languageService.isArabic;

  // القوائم القابلة للمراقبة
  var providerServices = <ProviderServiceModel>[].obs;
  var allServices = <ServiceModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var servicesByCategory = <ServiceModel>[].obs;

  // حالات التحميل
  var isLoading = false.obs;
  var isLoadingServicesAndCategories = false.obs;
  var isAddingServices = false.obs;
  var isUpdatingPrice = false.obs;
  var isTogglingStatus = false.obs;
  var isDeletingService = false.obs;
  var isRefreshing = false.obs;

  // حالات التحميل الخاصة بالخدمة
  var updatingPriceServiceId = Rxn<int>();
  var togglingStatusServiceId = Rxn<int>();
  var deletingServiceId = Rxn<int>();

  // الصنف المختار
  var selectedCategoryId = Rxn<int>();

  var supportPhone = ''.obs;

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
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
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
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
    Widget? child,
  }) {
    Color backgroundColor = Colors.transparent;
    Color foregroundColor = Colors.grey[600]!;
    BorderSide borderSide = BorderSide(color: Colors.grey[300]!, width: 1);

    if (isPrimary) {
      backgroundColor = const Color(0xFFEF4444);
      foregroundColor = Colors.white;
      borderSide = BorderSide.none;
    } else if (isDestructive) {
      backgroundColor = Colors.transparent;
      foregroundColor = Colors.red;
      borderSide = BorderSide(color: Colors.red[300]!, width: 1);
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: borderSide,
        ),
        elevation: 0,
      ),
      child: child ??
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
    );
  }

  // Custom Loading Dialog
  void _showCustomLoadingDialog(String message) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFEF4444),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onInit() {
    super.onInit();

    // الحصول على رقم الدعم من المعاملات المُمررة
    if (Get.arguments != null && Get.arguments['supportPhone'] != null) {
      supportPhone.value = Get.arguments['supportPhone'];
    }

    loadInitialData();
  }

  // تحميل البيانات الأولية
  Future<void> loadInitialData() async {
    await Future.wait([
      loadProviderServices(),
      loadServicesAndCategories(),
    ]);
  }

  void filterServicesByCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;

    if (categoryId == null) {
      // عرض جميع الخدمات
      servicesByCategory.value = List.from(allServices);
    } else {
      // تصفية حسب الصنف
      servicesByCategory.value = allServices
          .where((service) => service.categoryId == categoryId)
          .toList();
    }
  }

  // جلب خدمات مقدم الخدمة (مع العروض الفعالة)
  Future<void> loadProviderServices() async {
    try {
      isLoading.value = true;
      final services = await _servicesService.getProviderServices();
      providerServices.value = services;
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // جلب جميع الخدمات والفئات المتاحة للمزود
  Future<void> loadServicesAndCategories() async {
    try {
      isLoadingServicesAndCategories.value = true;
      final response = await _servicesService.getServicesWithCategories();

      // تصفية الخدمات لاستبعاد نوع KHABEER
      final nonKhabeerServices =
          response.services.where((s) => s.serviceType != "KHABEER").toList();

      allServices.value = nonKhabeerServices;
      categories.value = response.categories;
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isLoadingServicesAndCategories.value = false;
    }
  }

  // جلب الخدمات حسب الصنف
  Future<void> loadServicesByCategory(int categoryId) async {
    try {
      selectedCategoryId.value = categoryId;
      isLoadingServicesAndCategories.value = true;
      final services = await _servicesService.getServicesByCategory(categoryId);
      servicesByCategory.value = services;
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isLoadingServicesAndCategories.value = false;
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

      // إظهار حوار التحميل
      _showCustomLoadingDialog('loading'.tr);

      final response = await _servicesService.addMultipleServices(services);

      // تحديث القائمة المحلية
      providerServices.addAll(response.services);

      // إغلاق حوار التحميل
      Get.back();

      _showSuccessSnackbar('success'.tr, response.message);

      // العودة إلى الصفحة السابقة
      Get.back(result: true);
    } catch (e) {
      // إغلاق حوار التحميل في حالة الخطأ
      if (Get.isDialogOpen ?? false) Get.back();
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isAddingServices.value = false;
    }
  }

  // تحديث سعر خدمة
  Future<void> updateServicePrice(
      int providerServiceId, double newPrice) async {
    try {
      isUpdatingPrice.value = true;
      updatingPriceServiceId.value = providerServiceId;

      final updatedService = await _servicesService.updateProviderServicePrice(
        providerServiceId,
        newPrice,
      );

      // تحديث الخدمة في القائمة المحلية
      final index =
          providerServices.indexWhere((s) => s.id == providerServiceId);
      if (index != -1) {
        providerServices[index] = updatedService;
      }

      _showSuccessSnackbar('success'.tr, 'update'.tr);
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
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
      final index =
          providerServices.indexWhere((s) => s.id == providerServiceId);
      if (index != -1) {
        providerServices[index] = updatedService;
      }

      final statusText = updatedService.isActive ? 'enabled'.tr : 'disabled'.tr;
      _showSuccessSnackbar('success'.tr, 'status'.tr + ' ' + statusText);
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isTogglingStatus.value = false;
      togglingStatusServiceId.value = null;
    }
  }

  // حذف خدمة
  void deleteService(int providerServiceId) {
    Get.dialog(
      _buildCustomDialog(
        title: 'delete'.tr,
        content: Text(
          'confirm'.tr,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        actions: [
          _buildCustomButton(
            text: 'cancel'.tr,
            onPressed: () => Get.back(),
          ),
          _buildCustomButton(
            text: 'delete'.tr,
            isDestructive: true,
            onPressed: () async {
              Get.back(); // إغلاق الحوار أولاً
              await _deleteService(providerServiceId);
            },
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
      providerServices
          .removeWhere((service) => service.id == providerServiceId);

      _showSuccessSnackbar('success'.tr, 'delete'.tr);
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
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
      _buildCustomDialog(
        title: 'update'.tr + ' ' + (service.service!.getTitle(isArabic)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // إظهار معلومات العرض الحالي إذا كان موجود
            if (service.hasActiveOffer) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'current_offer'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildOfferInfoRow(
                      'offer_price'.tr,
                      '${service.activeOffer!.offerPrice} ' + 'omr'.tr,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildOfferInfoRow(
                      'original_price'.tr,
                      '${service.activeOffer!.originalPrice} ' + 'omr'.tr,
                      Colors.grey[600]!,
                    ),
                    if (service.activeOffer!.description != null) ...[
                      const SizedBox(height: 8),
                      _buildOfferInfoRow(
                        'description'.tr,
                        service.activeOffer!.description!,
                        Colors.grey[600]!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'new_price'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'price'.tr,
                suffixText: 'omr'.tr,
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
                prefixIcon: Icon(Icons.attach_money, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        actions: [
          _buildCustomButton(
            text: 'cancel'.tr,
            onPressed: () => Get.back(),
          ),
          Obx(() => _buildCustomButton(
                text: 'update'.tr,
                isPrimary: true,
                onPressed: isUpdatingPrice.value
                    ? null
                    : () {
                        final newPrice = double.tryParse(priceController.text);
                        if (newPrice != null && newPrice > 0) {
                          Get.back();
                          updateServicePrice(service.id, newPrice);
                        } else {
                          _showErrorSnackbar('error'.tr, 'field_required'.tr);
                        }
                      },
                child: isUpdatingPrice.value &&
                        updatingPriceServiceId.value == service.id
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : null,
              )),
        ],
      ),
    );
  }

  // Widget helper for offer information rows
  Widget _buildOfferInfoRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // إظهار حوار طلب خدمة جديدة
  void showAddServiceDialog() {
    _contactAdminForNewService();
  }

  // إضافة دالة للتواصل مع الإدارة:
  Future<void> _contactAdminForNewService() async {
    try {
      if (supportPhone.value.isEmpty) {
        _showErrorSnackbar('error'.tr, 'رقم الدعم غير متوفر');
        return;
      }

      final String message = Uri.encodeComponent(
          'مرحباً، أود طلب إضافة خدمة جديدة غير متوفرة في التطبيق');

      final String whatsappUrl =
          'https://wa.me/${supportPhone.value}?text=$message';

      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      _showErrorSnackbar('error'.tr, 'حدث خطأ أثناء محاولة فتح واتساب');
    }
  }

  // الحصول على الخدمات المتاحة للإضافة (غير مضافة بعد)
  List<ServiceModel> getAvailableServices() {
    final providerServiceIds =
        providerServices.map((ps) => ps.serviceId).toSet();
    return allServices
        .where((service) => !providerServiceIds.contains(service.id))
        .toList();
  }

  // الحصول على السعر الفعال للخدمة (مع العرض أو بدونه)
  double getEffectivePrice(ProviderServiceModel service) {
    return service.effectivePrice;
  }

  // التحقق من وجود عرض فعال
  bool hasActiveOffer(ProviderServiceModel service) {
    return service.hasActiveOffer;
  }

  // الحصول على نسبة الخصم
  double getDiscountPercentage(ProviderServiceModel service) {
    if (!service.hasActiveOffer) return 0;

    final originalPrice = service.activeOffer!.originalPrice;
    final offerPrice = service.activeOffer!.offerPrice;

    if (originalPrice <= 0) return 0;

    return ((originalPrice - offerPrice) / originalPrice) * 100;
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

  // التحقق من حالة التحميل لخدمة معينة
  bool isServiceLoading(int serviceId, String operation) {
    switch (operation) {
      case 'price':
        return isUpdatingPrice.value &&
            updatingPriceServiceId.value == serviceId;
      case 'status':
        return isTogglingStatus.value &&
            togglingStatusServiceId.value == serviceId;
      case 'delete':
        return isDeletingService.value && deletingServiceId.value == serviceId;
      default:
        return false;
    }
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

  // دالة مساعدة لعرض معلومات العرض في واجهة المستخدم
  Widget buildOfferBadge(ProviderServiceModel service) {
    if (!service.hasActiveOffer) {
      return const SizedBox.shrink();
    }

    final discountPercentage = getDiscountPercentage(service);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${discountPercentage.toStringAsFixed(0)}% خصم',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // دالة مساعدة لعرض السعر مع العرض
  Widget buildPriceWithOffer(ProviderServiceModel service) {
    if (!service.hasActiveOffer) {
      return Text(
        '${service.price} ' + 'omr'.tr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${service.activeOffer!.offerPrice} ' + 'omr'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        Text(
          '${service.activeOffer!.originalPrice} ' + 'omr'.tr,
          style: const TextStyle(
            fontSize: 14,
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
