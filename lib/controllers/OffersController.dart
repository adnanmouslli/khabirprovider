import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:khabir/services/language_service.dart';
import '../models/offer_model.dart';
import '../services/offers_service.dart';

class OffersController extends GetxController {
  final OffersService _offersService = OffersService();

  final LanguageService _languageService = Get.find<LanguageService>();

  bool get isArabic => _languageService.isArabic;

  // القوائم القابلة للمراقبة
  var providerServices = <ProviderServiceModel>[].obs;
  var myOffers = <OfferModel>[].obs;

  // حالات التحميل
  var isLoading = false.obs;
  var isLoadingOffers = false.obs;
  var isCreatingOffer = false.obs;
  var isDeletingOffer = false.obs;

  // حالات التحميل الخاصة بالخدمة
  var creatingOfferServiceId = Rxn<int>();
  var deletingOfferId = Rxn<int>();

  var isEditingOffer = false.obs;
  var editingOfferId = Rxn<int>();

  // دالة تعديل العرض - جديدة
  void editOffer(OfferModel offer) {
    
    final TextEditingController descriptionController = TextEditingController(
      text: offer.description,
    );
    final TextEditingController offerPriceController = TextEditingController(
      text: offer.offerPrice.toString(),
    );

    // متغير لحفظ تاريخ انتهاء العرض
    DateTime? selectedEndDate = offer.endDate; // استخدام التاريخ الحالي

    Get.dialog(
      _buildCustomDialog(
        title: '${isArabic ? 'تعديل العرض' : 'Edit Offer'}',
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              
                // حقل الوصف
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'description'.tr,
                    hintText: offer.description ,
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
                    prefixIcon:
                        Icon(Icons.description, color: Colors.grey[600]),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // حقل سعر العرض
                TextField(
                  controller: offerPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'offer_price'.tr,
                    suffixText: 'omr'.tr,
                    helperText:
                        '${'original_price'.tr}: ${offer.originalPrice} ' +
                            'omr'.tr,
                    helperStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
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
                    prefixIcon:
                        Icon(Icons.attach_money, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 16),

                // منتقي تاريخ الانتهاء - جديد
                InkWell(
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime initialDate =
                        selectedEndDate ?? now.add(const Duration(days: 1));

                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate.isAfter(now)
                          ? initialDate
                          : now.add(const Duration(days: 1)),
                      firstDate: now.add(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 365)),
                      locale: const Locale('ar'),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFFEF4444),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEndDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedEndDate != null
                            ? const Color(0xFFEF4444).withOpacity(0.3)
                            : Colors.grey[300]!,
                        width: selectedEndDate != null ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: selectedEndDate != null
                          ? const Color(0xFFEF4444).withOpacity(0.05)
                          : Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: selectedEndDate != null
                              ? const Color(0xFFEF4444)
                              : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'expires_in'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedEndDate != null
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedEndDate != null
                                    ? _formatDate(selectedEndDate!)
                                    : isArabic
                                        ? 'اختر تاريخ الانتهاء'
                                        : 'Select expiry date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedEndDate != null
                                      ? Colors.black87
                                      : Colors.grey[500],
                                  fontWeight: selectedEndDate != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: selectedEndDate != null
                              ? const Color(0xFFEF4444)
                              : Colors.grey[400],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          _buildCustomButton(
            text: 'cancel'.tr,
            onPressed: () => Get.back(),
          ),
          Obx(() => _buildCustomButton(
                text: 'update'.tr,
                isPrimary: true,
                onPressed: (isEditingOffer.value &&
                        editingOfferId.value == offer.id)
                    ? null
                    : () {
                        final description = descriptionController.text.trim();
                        final offerPriceText = offerPriceController.text.trim();

                    

                        if (description.isEmpty) {
                          _showErrorSnackbar(
                              'error'.tr, 'description_required'.tr);
                          return;
                        }

                        if (offerPriceText.isEmpty) {
                          _showErrorSnackbar('error'.tr, 'price_required'.tr);
                          return;
                        }

                        final offerPrice = double.tryParse(offerPriceText);
                        if (offerPrice == null || offerPrice <= 0) {
                          _showErrorSnackbar(
                              'error'.tr, 'enter_valid_price'.tr);
                          return;
                        }

                        if (offerPrice >= offer.originalPrice) {
                          _showErrorSnackbar(
                              'error'.tr, 'offer_price_must_be_less'.tr);
                          return;
                        }

                        if (selectedEndDate == null) {
                          _showErrorSnackbar('error'.tr, 'select_end_date'.tr);
                          return;
                        }

                        if (selectedEndDate!.isBefore(DateTime.now())) {
                          _showErrorSnackbar(
                              'error'.tr, 'end_date_must_be_future'.tr);
                          return;
                        }

                        Get.back();
                        _updateOffer(offer, description, offerPrice,
                            selectedEndDate!);
                      },
                child:
                    (isEditingOffer.value && editingOfferId.value == offer.id)
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

  // تنفيذ تحديث العرض - جديدة
  Future<void> _updateOffer(
    OfferModel offer,
    String description,
    double offerPrice,
    DateTime endDate, // إضافة تاريخ الانتهاء
  ) async {
    try {
      isEditingOffer.value = true;
      editingOfferId.value = offer.id;

      final request = UpdateOfferRequest(
        description: description,
        offerPrice: offerPrice,
        endDate: endDate, // إضافة تاريخ الانتهاء
      );

      final updatedOffer = await _offersService.updateOffer(offer.id, request);

      // تحديث قائمة العروض الشخصية
      final offerIndex = myOffers.indexWhere((o) => o.id == offer.id);
      if (offerIndex != -1) {
        myOffers[offerIndex] = updatedOffer;
      }

      // تحديث خدمة مقدم الخدمة
      final serviceIndex =
          providerServices.indexWhere((s) => s.serviceId == offer.serviceId);
      if (serviceIndex != -1) {
        final updatedService = providerServices[serviceIndex];
        providerServices[serviceIndex] = ProviderServiceModel(
          id: updatedService.id,
          serviceId: updatedService.serviceId,
          providerId: updatedService.providerId,
          price: updatedService.price,
          isActive: updatedService.isActive,
          service: updatedService.service,
          activeOffer: updatedOffer,
        );
      }

      _showSuccessSnackbar('success'.tr, 'offer_updated_successfully'.tr);
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isEditingOffer.value = false;
      editingOfferId.value = null;
    }
  }

  // تحديث دالة isOfferLoading لتشمل التعديل
  bool isOfferLoading(int offerId, String operation) {
    switch (operation) {
      case 'delete':
        return isDeletingOffer.value && deletingOfferId.value == offerId;
      case 'edit':
        return isEditingOffer.value && editingOfferId.value == offerId;
      default:
        return false;
    }
  }

  // Custom Dialog Widget المحسن للسكرول
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
      // إضافة insetPadding لتجنب overflow عند ظهور الكيبورد
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      child: Container(
        // استخدام constraints لتحديد الحد الأقصى للارتفاع
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان ثابت
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),

            // المحتوى قابل للتمرير
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: content,
              ),
            ),

            const SizedBox(height: 24),

            // الأزرار ثابتة في الأسفل
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

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  // تحميل البيانات الأولية
  Future<void> loadInitialData() async {
    loadProviderServices();
  }

  // جلب خدمات مقدم الخدمة
  Future<void> loadProviderServices() async {
    try {
      isLoading.value = true;
      final services = await _offersService.getProviderServicesForOffers();

      // التأكد من تحديث كل خدمة بالعرض النشط إذا كان موجودًا
      providerServices.value = services.map((service) {
        final hasActiveOffer =
            service.activeOffer != null && service.activeOffer! != null;
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
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // إضافة عرض لخدمة
  void addOfferToService(ProviderServiceModel service) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController offerPriceController = TextEditingController();

    // متغير لحفظ تاريخ انتهاء العرض
    DateTime? selectedEndDate;

    // تعيين السعر الأصلي افتراضيًا
    final originalPrice = service.price;

    Get.dialog(
      _buildCustomDialog(
        title:
            '${isArabic ? 'إضافة عرض' : 'Add Offer'}: ${service.service?.getTitle(isArabic) ?? (isArabic ? 'خدمة' : 'Service')}',
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'description'.tr,
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
                      prefixIcon:
                          Icon(Icons.description, color: Colors.grey[600]),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: offerPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'offer_price'.tr,
                      suffixText: 'omr'.tr,
                      helperText:
                          '${'original_price'.tr}: $originalPrice ' + 'omr'.tr,
                      helperStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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
                      prefixIcon:
                          Icon(Icons.attach_money, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // منتقي التاريخ لتاريخ الانتهاء
                  InkWell(
                    onTap: () async {
                      final DateTime now = DateTime.now();

                      DateTime initialDate = now.add(const Duration(days: 1));

                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: now.add(const Duration(days: 1)),
                        lastDate: now.add(const Duration(days: 365)),
                        locale: const Locale('ar'),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: const Color(0xFFEF4444),
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedEndDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'expires_in'.tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedEndDate != null
                                      ? _formatDate(selectedEndDate!)
                                      : isArabic
                                          ? 'اختر تاريخ الانتهاء'
                                          : 'Select expiry date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: selectedEndDate != null
                                        ? Colors.black87
                                        : Colors.grey[500],
                                    fontWeight: selectedEndDate != null
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          _buildCustomButton(
            text: 'cancel'.tr,
            onPressed: () => Get.back(),
          ),
          Obx(() => _buildCustomButton(
                text: 'add'.tr,
                isPrimary: true,
                onPressed: (isCreatingOffer.value &&
                        creatingOfferServiceId.value == service.id)
                    ? null
                    : () {
                        final description = descriptionController.text.trim();
                        final offerPriceText = offerPriceController.text.trim();

                      

                        if (description.isEmpty) {
                          _showErrorSnackbar('error'.tr, 'field_required'.tr);
                          return;
                        }

                        if (offerPriceText.isEmpty) {
                          _showErrorSnackbar('error'.tr, 'field_required'.tr);
                          return;
                        }

                        final offerPrice = double.tryParse(offerPriceText);
                        if (offerPrice == null || offerPrice <= 0) {
                          _showErrorSnackbar('error'.tr, 'field_required'.tr);
                          return;
                        }

                        if (offerPrice >= originalPrice) {
                          _showErrorSnackbar('error'.tr, 'field_required'.tr);
                          return;
                        }

                        if (selectedEndDate == null) {
                          _showErrorSnackbar('error'.tr, 'field_required'.tr);
                          return;
                        }

                        // التأكد من أن تاريخ الانتهاء في المستقبل
                        if (selectedEndDate!.isBefore(DateTime.now())) {
                          _showErrorSnackbar('error'.tr, 'field_required'.tr);
                          return;
                        }

                        Get.back();
                        _createOffer(service, description, originalPrice,
                            offerPrice, selectedEndDate!);
                      },
                child: (isCreatingOffer.value &&
                        creatingOfferServiceId.value == service.id)
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

  // إنشاء عرض جديد
  Future<void> _createOffer(
    ProviderServiceModel service,
    String description,
    double originalPrice,
    double offerPrice,
    DateTime endDate,
  ) async {
    try {
      isCreatingOffer.value = true;
      creatingOfferServiceId.value = service.id;

      final request = CreateOfferRequest(
        serviceId: service.serviceId,
        description: description,
        originalPrice: originalPrice,
        offerPrice: offerPrice,
        startDate: DateTime.now(), // بداية العرض هو الوقت الحالي
        endDate: endDate, // تاريخ الانتهاء المحدد من المستخدم
      );

      final newOffer = await _offersService.createOffer(request);

      // تحديث قائمة العروض الشخصية
      myOffers.add(newOffer);

      // تحديث خدمة مقدم الخدمة بحيث تحتوي على العرض النشط
      final serviceIndex =
          providerServices.indexWhere((s) => s.id == service.id);
      if (serviceIndex != -1) {
        final updatedService = providerServices[serviceIndex];

        providerServices[serviceIndex] = ProviderServiceModel(
          id: updatedService.id,
          serviceId: updatedService.serviceId,
          providerId: updatedService.providerId,
          price: updatedService.price,
          isActive: updatedService.isActive,
          service: updatedService.service,
          activeOffer: newOffer,
        );
      }

      _showSuccessSnackbar('success'.tr, 'success'.tr + ' ' + 'add_offer'.tr);
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isCreatingOffer.value = false;
      creatingOfferServiceId.value = null;
    }
  }

  // حذف عرض
  void deleteOffer(OfferModel offer) {
    Get.dialog(
      _buildCustomDialog(
        title: 'delete_offer'.tr,
        content: Column(
          children: [
            Center(
              child: Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'confirm'.tr + ' ' + 'delete'.tr + ' ?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
              Get.back();
              await _deleteOffer(offer);
            },
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

      // تحديث خدمة مقدم الخدمة - جعل العرض null
      final serviceIndex =
          providerServices.indexWhere((s) => s.serviceId == offer.serviceId);
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

      _showSuccessSnackbar(
          'success'.tr, 'delete_offer'.tr + ' ' + 'success'.tr);
    } catch (e) {
      _showErrorSnackbar('error'.tr, e.toString());
    } finally {
      isDeletingOffer.value = false;
      deletingOfferId.value = null;
    }
  }

  // دوال مساعدة
  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  // التحقق من حالة التحميل لخدمة معينة
  bool isServiceLoading(int serviceId, String operation) {
    switch (operation) {
      case 'createOffer':
        return isCreatingOffer.value &&
            creatingOfferServiceId.value == serviceId;
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
