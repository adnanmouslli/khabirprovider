import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/offer_model.dart';
import '../services/offers_service.dart';

class OffersController extends GetxController {
  final OffersService _offersService = OffersService();

  // Observable lists
  var providerServices = <ProviderServiceModel>[].obs;
  var myOffers = <OfferModel>[].obs;

  // Loading states
  var isLoading = false.obs;
  var isLoadingOffers = false.obs;
  var isCreatingOffer = false.obs;
  var isDeletingOffer = false.obs;

  // Service-specific loading states
  var creatingOfferServiceId = Rxn<int>();
  var deletingOfferId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // تحميل البيانات الأولية
  Future<void> loadInitialData() async {
    loadProviderServices();

    // await Future.wait([
    //   loadMyOffers(),
    //   loadProviderServices(),
    // ]);
    // // ربط العروض بالخدمات بعد تحميل البيانات
    // _linkOffersToServices();
  }

  // جلب خدمات المزود
  // عند جلب خدمات المزود
  Future<void> loadProviderServices() async {
    try {
      isLoading.value = true;
      final services = await _offersService.getProviderServicesForOffers();

      // تأكد أن كل خدمة محدثة بالـ activeOffer إذا فيه
      providerServices.value = services.map((service) {
        final hasActiveOffer = service.activeOffer != null && service.activeOffer! != null;
        return ProviderServiceModel(
          id: service.id,
          serviceId: service.serviceId,
          providerId: service.providerId,
          price: service.price,
          isActive: service.isActive,
          service: service.service,
          activeOffer: hasActiveOffer ? service.activeOffer : null,
        );
      }).toList();
    } catch (e) {
      _showErrorSnackbar('خطأ في جلب خدماتك', e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  // // جلب عروضي
  // Future<void> loadMyOffers() async {
  //   try {
  //     isLoadingOffers.value = true;
  //     final offers = await _offersService.getMyOffers();
  //     myOffers.value = offers;
  //   } catch (e) {
  //     _showErrorSnackbar('خطأ في جلب عروضك', e.toString());
  //   } finally {
  //     isLoadingOffers.value = false;
  //   }
  // }


  // إضافة عرض لخدمة
  void addOfferToService(ProviderServiceModel service) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController offerPriceController = TextEditingController();

    // تعيين السعر الأصلي افتراضياً
    final originalPrice = service.price;

    Get.dialog(
      AlertDialog(
        title: Text('إضافة عرض للخدمة: ${service.service?.title ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان العرض',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف العرض',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: offerPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'سعر العرض',
                  suffixText: 'OMR',
                  helperText: 'السعر الأصلي: $originalPrice OMR',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          Obx(() => TextButton(
            onPressed: (isCreatingOffer.value && creatingOfferServiceId.value == service.id)
                ? null
                : () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final offerPriceText = offerPriceController.text.trim();

              if (title.isEmpty) {
                _showErrorSnackbar('خطأ', 'يرجى إدخال عنوان العرض');
                return;
              }

              if (description.isEmpty) {
                _showErrorSnackbar('خطأ', 'يرجى إدخال وصف العرض');
                return;
              }

              if (offerPriceText.isEmpty) {
                _showErrorSnackbar('خطأ', 'يرجى إدخال سعر العرض');
                return;
              }

              final offerPrice = double.tryParse(offerPriceText);
              if (offerPrice == null || offerPrice <= 0) {
                _showErrorSnackbar('خطأ', 'يرجى إدخال سعر صحيح');
                return;
              }

              if (offerPrice >= originalPrice) {
                _showErrorSnackbar('خطأ', 'سعر العرض يجب أن يكون أقل من السعر الأصلي');
                return;
              }

              Get.back();
              _createOffer(service, title, description, originalPrice, offerPrice);
            },
            child: (isCreatingOffer.value && creatingOfferServiceId.value == service.id)
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text('إضافة'),
          )),
        ],
      ),
    );
  }

  // إنشاء عرض جديد
  Future<void> _createOffer(
      ProviderServiceModel service,
      String title,
      String description,
      double originalPrice,
      double offerPrice,
      ) async {
    try {
      isCreatingOffer.value = true;
      creatingOfferServiceId.value = service.id;

      final request = CreateOfferRequest(
        serviceId: service.serviceId,
        title: title,
        description: description,
        originalPrice: originalPrice,
        offerPrice: offerPrice,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)), // عرض لمدة شهر
      );

      final newOffer = await _offersService.createOffer(request);

      // تحديث قائمة العروض الشخصية
      myOffers.add(newOffer);

      // تحديث خدمة المزود بحيث يكون عندها activeOffer
      final serviceIndex = providerServices.indexWhere((s) => s.id == service.id);
      if (serviceIndex != -1) {
        final updatedService = providerServices[serviceIndex];

        providerServices[serviceIndex] = ProviderServiceModel(
          id: updatedService.id,
          serviceId: updatedService.serviceId,
          providerId: updatedService.providerId,
          price: updatedService.price,
          isActive: updatedService.isActive,
          service: updatedService.service,
          activeOffer: newOffer, // هنا بنخزن العرض الجديد مباشرة
        );
      }

      _showSuccessSnackbar('تم بنجاح', 'تم إضافة العرض بنجاح');
    } catch (e) {
      _showErrorSnackbar('خطأ في إضافة العرض', e.toString());
    } finally {
      isCreatingOffer.value = false;
      creatingOfferServiceId.value = null;
    }
  }

  // حذف عرض
  void deleteOffer(OfferModel offer) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف العرض'),
        content: Text('هل أنت متأكد من حذف عرض "${offer.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _deleteOffer(offer);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // تنفيذ حذف العرض
  Future<void> _deleteOffer(OfferModel offer) async {
    try {
      isDeletingOffer.value = true;
      deletingOfferId.value = offer.id;

      await _offersService.deleteOffer(offer.id);

      // إزالة العرض من قائمة العروض الشخصية
      myOffers.removeWhere((o) => o.id == offer.id);

      // تحديث خدمة المزود - نخلي العرض null
      final serviceIndex = providerServices.indexWhere((s) => s.serviceId == offer.serviceId);
      if (serviceIndex != -1) {
        final updatedService = providerServices[serviceIndex];

        final newService = ProviderServiceModel(
          id: updatedService.id,
          serviceId: updatedService.serviceId,
          providerId: updatedService.providerId,
          price: updatedService.price,
          isActive: updatedService.isActive,
          service: updatedService.service,
          activeOffer: null, // حذف العرض
        );

        providerServices[serviceIndex] = newService;
        providerServices.refresh();
      }

      _showSuccessSnackbar('تم الحذف', 'تم حذف العرض بنجاح');
    } catch (e) {
      _showErrorSnackbar('خطأ في حذف العرض', e.toString());
    } finally {
      isDeletingOffer.value = false;
      deletingOfferId.value = null;
    }
  }

  // التحقق من loading state لعرض معين
  bool isOfferLoading(int offerId, String operation) {
    switch (operation) {
      case 'delete':
        return isDeletingOffer.value && deletingOfferId.value == offerId;
      default:
        return false;
    }
  }

  // التحقق من loading state لخدمة معينة
  bool isServiceLoading(int serviceId, String operation) {
    switch (operation) {
      case 'createOffer':
        return isCreatingOffer.value && creatingOfferServiceId.value == serviceId;
      default:
        return false;
    }
  }

  // إعادة تحميل البيانات
  Future<void> refreshData() async {
    await loadInitialData();
  }

  // الحصول على عدد العروض النشطة
  int get activeOffersCount {
    return myOffers.where((offer) => offer.isActive).length;
  }

  // الحصول على عدد العروض المنتهية
  int get expiredOffersCount {
    return myOffers.where((offer) => offer.isExpired).length;
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