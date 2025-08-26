// Extension لمساعدة في التعامل الآمن مع القوائم
extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

// نموذج العرض الرئيسي
class OfferModel {
  final int id;
  final int providerId;
  final int serviceId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double originalPrice;
  final double offerPrice;
  final bool isActive;
  final ProviderModel? provider;
  final ServiceModel? service;

  OfferModel({
    required this.id,
    required this.providerId,
    required this.serviceId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.originalPrice,
    required this.offerPrice,
    required this.isActive,
    this.provider,
    this.service,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? 0,
      providerId: json['providerId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true, // لو جا من الـ API ناقص نخليه true
      provider: json['provider'] != null ? ProviderModel.fromJson(json['provider']) : null,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'serviceId': serviceId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'originalPrice': originalPrice,
      'offerPrice': offerPrice,
      'isActive': isActive,
      'provider': provider?.toJson(),
      'service': service?.toJson(),
    };
  }

  // حساب نسبة الخصم
  int get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((originalPrice - offerPrice) / originalPrice * 100).round();
  }

  // حساب مبلغ التوفير
  double get savingsAmount => originalPrice - offerPrice;

  // التحقق من انتهاء العرض
  bool get isExpired => DateTime.now().isAfter(endDate);

  // التحقق من بداية العرض
  bool get hasStarted => DateTime.now().isAfter(startDate);

  // التحقق من صلاحية العرض
  bool get isValid => hasStarted && !isExpired && isActive;
}

// نموذج المزود
class ProviderModel {
  final int id;
  final String name;
  final String image;

  ProviderModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

// نموذج الخدمة
class ServiceModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final int? categoryId;
  final double? commission;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.categoryId,
    this.commission,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      categoryId: json['categoryId'],
      commission: json['commission']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'categoryId': categoryId,
      'commission': commission,
    };
  }
}

// نموذج خدمة المزود (مع العرض)
class ProviderServiceModel {
  final int id;
  final int serviceId;
  final int providerId;
  final double price;
  final bool isActive;
  final ServiceModel? service;
  final OfferModel? activeOffer; // العرض الحالي (ممكن null)

  ProviderServiceModel({
    required this.id,
    required this.serviceId,
    required this.providerId,
    required this.price,
    required this.isActive,
    this.service,
    this.activeOffer,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    return ProviderServiceModel(
      id: json['id'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      providerId: json['providerId'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? false,
      service: json['service'] != null ? ServiceModel.fromJson(json['service']) : null,
      activeOffer: json['activeOffer'] != null
          ? OfferModel.fromJson(json['activeOffer'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'providerId': providerId,
      'price': price,
      'isActive': isActive,
      'service': service?.toJson(),
      'activeOffer': activeOffer?.toJson(),
    };
  }

  // التحقق من وجود عرض نشط
  bool get hasActiveOffer => activeOffer?.isValid ?? false;

  // السعر الفعال (مع العرض أو بدونه)
  double get effectivePrice {
    if (activeOffer != null && activeOffer!.isValid) {
      return activeOffer!.offerPrice;
    }
    return price;
  }
}


// طلب إنشاء عرض جديد
class CreateOfferRequest {
  final int serviceId;
  final String title;
  final String description;
  final double originalPrice;
  final double offerPrice;
  final DateTime startDate;
  final DateTime endDate;

  CreateOfferRequest({
    required this.serviceId,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.offerPrice,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'title': title,
      'description': description,
      'originalPrice': originalPrice,
      'offerPrice': offerPrice,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

// طلب تحديث عرض
class UpdateOfferRequest {
  final String? title;
  final String? description;
  final double? originalPrice;
  final double? offerPrice;
  final DateTime? startDate;
  final DateTime? endDate;

  UpdateOfferRequest({
    this.title,
    this.description,
    this.originalPrice,
    this.offerPrice,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (originalPrice != null) json['originalPrice'] = originalPrice;
    if (offerPrice != null) json['offerPrice'] = offerPrice;
    if (startDate != null) json['startDate'] = startDate!.toIso8601String();
    if (endDate != null) json['endDate'] = endDate!.toIso8601String();

    return json;
  }
}