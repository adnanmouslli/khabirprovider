class ServiceModel {
  final int id;
  final String? image;
  final String titleAr;
  final String titleEn;
    final String? descriptionAr;  // إضافة الوصف العربي
  final String? descriptionEn;  // إضافة الوصف الإنجليزي

  final double commission;
  final String? whatsapp;
  final int categoryId;
  final String? serviceType;
  final CategoryModel? category; // إضافة هذا الحقل

  ServiceModel({
    required this.id,
    this.image,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.commission,
    this.whatsapp,
    required this.categoryId,
    this.serviceType,
    this.category, // إضافة هذا
  });

  String getTitle(bool isArabic) => isArabic ? titleAr : titleEn;
  String? getDescription(bool isArabic) => isArabic ? descriptionAr : descriptionEn;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      image: json['image'],
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      descriptionAr: json['descriptionAr'],  // إضافة
      descriptionEn: json['descriptionEn'],  // إضافة
      commission: (json['commission'] ?? 0).toDouble(),
      whatsapp: json['whatsapp'],
      categoryId: json['categoryId'] ?? 0,
      serviceType: json['serviceType'],
      category: json['category'] != null 
          ? CategoryModel.fromJson(json['category']) 
          : null, // إضافة هذا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'descriptionAr': descriptionAr,  // إضافة
      'descriptionEn': descriptionEn,  // إضافة
      'commission': commission,
      'whatsapp': whatsapp,
      'categoryId': categoryId,
      'serviceType': serviceType,
      'category': category?.toJson(), // إضافة هذا
    };
  }
}
class CategoryModel {
  final int id;
  final String? image;
  final String titleAr;
  final String titleEn;
  final String state;

  CategoryModel({
    required this.id,
    this.image,
    required this.titleAr,
    required this.titleEn,
    required this.state,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      image: json['image'],
      titleAr: json['titleAr'] ?? '',
      titleEn: json['titleEn'] ?? '',
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'state': state,
    };
  }
}

class ActiveOfferModel {
  final int id;
  final String startDate;
  final String endDate;
  final String? description;
  final double offerPrice;
  final double originalPrice;

  ActiveOfferModel({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.offerPrice,
    required this.originalPrice,
  });

  factory ActiveOfferModel.fromJson(Map<String, dynamic> json) {
    return ActiveOfferModel(
      id: json['id'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      description: json['description'],
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'offerPrice': offerPrice,
      'originalPrice': originalPrice,
    };
  }

  // للتحقق من صحة العرض حسب التاريخ
  bool get isValid {
    try {
      final now = DateTime.now();
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      return false;
    }
  }
}

class ProviderServiceModel {
  final int id;
  final int providerId;
  final int serviceId;
  final double price;
  final bool isActive;
  final ProviderModel? provider;
  final ServiceModel? service;
  final ActiveOfferModel? activeOffer;

  ProviderServiceModel({
    required this.id,
    required this.providerId,
    required this.serviceId,
    required this.price,
    required this.isActive,
    this.provider,
    this.service,
    this.activeOffer,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceModel(
      id: json['id'] ?? 0,
      providerId: json['providerId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      provider: json['provider'] != null
          ? ProviderModel.fromJson(json['provider'])
          : null,
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
      activeOffer: json['activeOffer'] != null
          ? ActiveOfferModel.fromJson(json['activeOffer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'serviceId': serviceId,
      'price': price,
      'isActive': isActive,
      'provider': provider?.toJson(),
      'service': service?.toJson(),
      'activeOffer': activeOffer?.toJson(),
    };
  }

  // للحصول على السعر الفعال (سعر العرض أو السعر العادي)
  double get effectivePrice {
    if (activeOffer != null && activeOffer!.isValid) {
      return activeOffer!.offerPrice;
    }
    return price;
  }

  // للتحقق من وجود عرض فعال
  bool get hasActiveOffer {
    return activeOffer != null && activeOffer!.isValid;
  }
}

class ProviderModel {
  final int id;
  final String name;
  final String? image;
  final bool isVerified;
  final bool isActive;

  ProviderModel({
    required this.id,
    required this.name,
    this.image,
    required this.isVerified,
    required this.isActive,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'isVerified': isVerified,
      'isActive': isActive,
    };
  }
}

class AddServiceRequest {
  final int serviceId;
  final double price;
  final bool isActive;

  AddServiceRequest({
    required this.serviceId,
    required this.price,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'price': price,
      'isActive': isActive,
    };
  }
}

class AddMultipleServicesRequest {
  final List<AddServiceRequest> services;

  AddMultipleServicesRequest({
    required this.services,
  });

  Map<String, dynamic> toJson() {
    return {
      'services': services.map((service) => service.toJson()).toList(),
    };
  }
}

class AddMultipleServicesResponse {
  final String message;
  final List<ProviderServiceModel> services;

  AddMultipleServicesResponse({
    required this.message,
    required this.services,
  });

  factory AddMultipleServicesResponse.fromJson(Map<String, dynamic> json) {
    return AddMultipleServicesResponse(
      message: json['message'] ?? '',
      services: (json['services'] as List<dynamic>?)
          ?.map((item) => ProviderServiceModel.fromJson(item))
          .toList() ??
          [],
    );
  }
}

// إضافة نموذج للاستجابة الجديدة من /services
class ServicesWithCategoriesResponse {
  final List<ServiceModel> services;
  final List<CategoryModel> categories;

  ServicesWithCategoriesResponse({
    required this.services,
    required this.categories,
  });

  factory ServicesWithCategoriesResponse.fromJson(List<dynamic> servicesJson) {
    // تحويل الخدمات
    final services = servicesJson
        .map((item) => ServiceModel.fromJson(item))
        .toList();

    // استخراج الفئات من الخدمات (إزالة المكررات)
    final categoriesMap = <int, CategoryModel>{};
    for (var service in services) {
      if (service.category != null) {
        categoriesMap[service.category!.id] = service.category!;
      }
    }
    final categories = categoriesMap.values.toList();

    return ServicesWithCategoriesResponse(
      services: services,
      categories: categories,
    );
  }
}