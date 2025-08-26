import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/service_model.dart';
import 'ServicesController.dart';

class AddServiceController extends GetxController {
  final ServicesController _servicesController = Get.find<ServicesController>();

  // Observable lists
  var availableServices = <ServiceModel>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  var categories = <CategoryModel>[].obs;

  // Selection states
  var selectedServices = <bool>[].obs;
  var selectedCategoryId = Rxn<int>();

  // Controllers
  List<TextEditingController> priceControllers = [];
  final TextEditingController searchController = TextEditingController();

  // Loading states
  var isLoading = false.obs;
  var isAddingServices = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
    setupSearchListener();
  }

  @override
  void onClose() {
    // تنظيف الكونترولرز
    for (var controller in priceControllers) {
      controller.dispose();
    }
    searchController.dispose();
    super.onClose();
  }

  // تحميل البيانات الأولية
  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      // التأكد من وجود الكونترولر الرئيسي
      if (!Get.isRegistered<ServicesController>()) {
        _showErrorSnackbar('خطأ', 'لم يتم العثور على بيانات الخدمات');
        return;
      }

      // الحصول على الخدمات المتاحة من الكونترولر الرئيسي
      availableServices.value = _servicesController.getAvailableServices();
      filteredServices.value = List.from(availableServices);

      // الحصول على الأصناف
      categories.value = List.from(_servicesController.categories);

      initializeControllers();
    } catch (e) {
      print('Error loading initial data: $e');
      _showErrorSnackbar('خطأ', 'فشل في تحميل البيانات');
    } finally {
      isLoading.value = false;
    }
  }

  // تهيئة الكونترولرز
  void initializeControllers() {
    // إعادة تعيين قوائم التحديد
    selectedServices.value = List.generate(availableServices.length, (index) => false);

    // تنظيف الكونترولرز القديمة
    for (var controller in priceControllers) {
      controller.dispose();
    }

    // إنشاء كونترولرز جديدة للأسعار
    priceControllers = availableServices.map((service) => TextEditingController()).toList();
  }

  // إعداد مستمع البحث
  void setupSearchListener() {
    searchController.addListener(() {
      filterServices(searchController.text);
    });
  }

  // تصفية الخدمات حسب البحث والصنف
  void filterServices(String query) {
    var services = availableServices.where((service) {
      // تصفية حسب النص
      final matchesQuery = query.isEmpty ||
          service.title.toLowerCase().contains(query.toLowerCase()) ||
          service.description.toLowerCase().contains(query.toLowerCase());

      // تصفية حسب الصنف
      final matchesCategory = selectedCategoryId.value == null ||
          service.categoryId == selectedCategoryId.value;

      return matchesQuery && matchesCategory;
    }).toList();

    filteredServices.value = services;
  }

  // تبديل اختيار خدمة
  void toggleService(int filteredIndex) {
    try {
      if (filteredIndex < 0 || filteredIndex >= filteredServices.length) {
        print('Invalid filtered index: $filteredIndex');
        return;
      }

      final filteredService = filteredServices[filteredIndex];
      final originalIndex = availableServices.indexWhere((s) => s.id == filteredService.id);

      selectedServices[originalIndex] = !selectedServices[originalIndex];

      // مسح السعر إذا تم إلغاء التحديد
      if (!selectedServices[originalIndex]) {
        priceControllers[originalIndex].clear();
      }

      // إجبار التحديث
      selectedServices.refresh();

    } catch (e) {
      print('Error in toggleService: $e');
      _showErrorSnackbar('خطأ', 'حدث خطأ غير متوقع');
    }
  }

  // الحصول على حالة التحديد للخدمة المفلترة
  bool isServiceSelected(int filteredIndex) {
    try {
      if (filteredIndex < 0 || filteredIndex >= filteredServices.length) return false;

      final filteredService = filteredServices[filteredIndex];
      final originalIndex = availableServices.indexWhere((s) => s.id == filteredService.id);

      if (originalIndex == -1 || originalIndex >= selectedServices.length) return false;

      return selectedServices[originalIndex];
    } catch (e) {
      print('Error in isServiceSelected: $e');
      return false;
    }
  }

  // الحصول على كونترولر السعر للخدمة المفلترة
  TextEditingController? getPriceController(int filteredIndex) {
    try {
      if (filteredIndex < 0 || filteredIndex >= filteredServices.length) return null;

      final filteredService = filteredServices[filteredIndex];
      final originalIndex = availableServices.indexWhere((s) => s.id == filteredService.id);

      if (originalIndex == -1 || originalIndex >= priceControllers.length) return null;

      return priceControllers[originalIndex];
    } catch (e) {
      print('Error in getPriceController: $e');
      return null;
    }
  }

  // التحقق من وجود خدمات محددة
  bool get hasSelectedServices {
    return selectedServices.any((selected) => selected);
  }

  // الحصول على عدد الخدمات المحددة
  int get selectedCount {
    return selectedServices.where((selected) => selected).length;
  }

  // التحقق من صحة الخدمات المحددة
  bool validateSelectedServices() {
    try {
      for (int i = 0; i < availableServices.length; i++) {
        if (i < selectedServices.length && selectedServices[i]) {
          if (i >= priceControllers.length) return false;

          final priceText = priceControllers[i].text.trim();
          if (priceText.isEmpty) return false;

          final price = double.tryParse(priceText);
          if (price == null || price <= 0) return false;
        }
      }
      return true;
    } catch (e) {
      print('Error validating services: $e');
      return false;
    }
  }

  // إضافة الخدمات المحددة - مع الإشعار والتصفير
  Future<void> addSelectedServices() async {
    if (!hasSelectedServices) {
      _showErrorSnackbar('خطأ', 'يرجى اختيار خدمة واحدة على الأقل');
      return;
    }

    List<AddServiceRequest> servicesToAdd = [];
    int selectedServicesCount = 0;

    try {
      for (int i = 0; i < availableServices.length; i++) {
        if (i < selectedServices.length && selectedServices[i]) {
          if (i >= priceControllers.length) {
            _showErrorSnackbar('خطأ', 'خطأ في البيانات، يرجى المحاولة مرة أخرى');
            return;
          }

          final priceText = priceControllers[i].text.trim();
          if (priceText.isEmpty) {
            _showErrorSnackbar(
              'خطأ',
              'يرجى إدخال سعر للخدمة: ${availableServices[i].title}',
            );
            return;
          }

          final price = double.tryParse(priceText);
          if (price == null || price <= 0) {
            _showErrorSnackbar(
              'خطأ',
              'يرجى إدخال سعر صحيح للخدمة: ${availableServices[i].title}',
            );
            return;
          }

          servicesToAdd.add(AddServiceRequest(
            serviceId: availableServices[i].id,
            price: price,
            isActive: true,
          ));
          selectedServicesCount++;
        }
      }

      if (servicesToAdd.isNotEmpty) {
        isAddingServices.value = true;

        // إضافة الخدمات
        await _servicesController.addMultipleServices(servicesToAdd);

        // إظهار إشعار النجاح
        _showSuccessSnackbar(
          'تم بنجاح',
          'تم إضافة $selectedServicesCount خدمة بنجاح',
        );

        // تصفير جميع الحقول والتحديدات
        _resetAllFields();

        // تحديث البيانات
        await refreshAvailableServices();
      }
    } catch (e) {
      print('Error adding services: $e');
      _showErrorSnackbar('خطأ', 'حدث خطأ أثناء إضافة الخدمات');
    } finally {
      isAddingServices.value = false;
    }
  }

  // تصفير جميع الحقول والتحديدات
  void _resetAllFields() {
    try {
      // تصفير جميع الحقول والتحديدات
      void _resetAllFields() {
        try {
          // مسح جميع التحديدات
          for (int i = 0; i < selectedServices.length; i++) {
            selectedServices[i] = false;
          }

          // مسح جميع أسعار الخدمات
          for (var controller in priceControllers) {
            controller.clear();
          }

          // مسح البحث
          searchController.clear();

          // إعادة تعيين الصنف المحدد
          selectedCategoryId.value = null;

          // إجبار التحديث
          selectedServices.refresh();

          // إعادة تطبيق التصفية
          filteredServices.value = List.from(availableServices);

        } catch (e) {
          print('Error resetting fields: $e');
        }
      }

      // مسح جميع التحديدات
      for (int i = 0; i < selectedServices.length; i++) {
        selectedServices[i] = false;
      }

      // مسح جميع أسعار الخدمات
      for (var controller in priceControllers) {
        controller.clear();
      }

      // مسح البحث
      searchController.clear();

      // إعادة تعيين الصنف المحدد
      selectedCategoryId.value = null;

      // إجبار التحديث
      selectedServices.refresh();

      // إعادة تطبيق التصفية
      filteredServices.value = List.from(availableServices);

    } catch (e) {
      print('Error resetting fields: $e');
    }
  }

  // اختيار صنف مع تحديث القوائم
  void selectCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;

    // تطبيق التصفية
    if (categoryId == null) {
      // عرض جميع الخدمات
      filteredServices.value = List.from(availableServices);
    } else {
      // تصفية حسب الصنف
      filteredServices.value = availableServices
          .where((service) => service.categoryId == categoryId)
          .toList();
    }
  }

  // مسح جميع التحديدات
  void clearAllSelections() {
    for (int i = 0; i < selectedServices.length; i++) {
      selectedServices[i] = false;
    }
    for (var controller in priceControllers) {
      controller.clear();
    }
    selectedServices.refresh();
  }

  // اختيار جميع الخدمات المتاحة
  void selectAllServices() {
    for (int i = 0; i < selectedServices.length; i++) {
      selectedServices[i] = true;
    }
    selectedServices.refresh();
  }

  // تحديث قائمة الخدمات المتاحة
  Future<void> refreshAvailableServices() async {
    try {
      availableServices.value = _servicesController.getAvailableServices();

      // إعادة تهيئة القوائم والكونترولرز
      initializeControllers();

      // إعادة تطبيق التصفية إذا كان هناك صنف محدد
      if (selectedCategoryId.value != null) {
        selectCategory(selectedCategoryId.value);
      } else {
        filteredServices.value = List.from(availableServices);
      }
    } catch (e) {
      print('Error refreshing available services: $e');
    }
  }

  // الحصول على اسم الصنف
  String getCategoryName(int categoryId) {
    final category = categories.firstWhereOrNull((cat) => cat.id == categoryId);
    return category?.titleAr ?? category?.titleEn ?? 'غير محدد';
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
}