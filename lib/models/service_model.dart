class ServiceModel {
  final int id;
  final String? image;
  final String title;
  final String description;
  final double commission;
  final String? whatsapp;
  final int categoryId;

  ServiceModel({
    required this.id,
    this.image,
    required this.title,
    required this.description,
    required this.commission,
    this.whatsapp,
    required this.categoryId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      image: json['image'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      commission: (json['commission'] ?? 0).toDouble(),
      whatsapp: json['whatsapp'],
      categoryId: json['categoryId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'description': description,
      'commission': commission,
      'whatsapp': whatsapp,
      'categoryId': categoryId,
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

class ProviderServiceModel {
  final int id;
  final int providerId;
  final int serviceId;
  final double price;
  final bool isActive;
  final ProviderModel? provider;
  final ServiceModel? service;

  ProviderServiceModel({
    required this.id,
    required this.providerId,
    required this.serviceId,
    required this.price,
    required this.isActive,
    this.provider,
    this.service,
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
    };
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