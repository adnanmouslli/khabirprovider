// Order Models
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:khabir/services/language_service.dart';

class OrderModel {
  final int id;
  final String bookingId;
  final int userId;
  final int providerId;
  final int serviceId; // Keep for backward compatibility
  final String status;
  final DateTime orderDate;
  final DateTime? scheduledDate;
  final String? location;
  final String? locationDetails;
  final ProviderLocationModel? providerLocation;
  final int quantity;
  final double totalAmount;
  final double providerAmount;
  final double commissionAmount;
  final UserModel user;
  final ProviderModel provider;
  final InvoiceModel? invoice;
  final String? duration;
  // New fields for multiple services
  final bool isMultipleServices;
  final List<ServiceBreakdown> servicesBreakdown;
  final List<OrderServiceModel> services;

  OrderModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.status,
    required this.orderDate,
    this.scheduledDate,
    this.location,
    this.locationDetails,
    this.providerLocation,
    required this.quantity,
    required this.totalAmount,
    required this.providerAmount,
    required this.commissionAmount,
    required this.user,
    required this.provider,
    this.invoice,
    this.duration,
    this.isMultipleServices = false,
    this.servicesBreakdown = const [],
    this.services = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      bookingId: json['bookingId'] ?? '',
      userId: json['userId'] ?? 0,
      providerId: json['providerId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      status: json['status'] ?? 'pending',
      orderDate:
          DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      location: json['location'],
      locationDetails: json['locationDetails'],
      providerLocation: json['providerLocation'] != null
          ? ProviderLocationModel.fromJson(json['providerLocation'])
          : null,
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      providerAmount: (json['providerAmount'] ?? 0).toDouble(),
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      user: UserModel.fromJson(json['user'] ?? {}),
      provider: ProviderModel.fromJson(json['provider'] ?? {}),
      invoice: json['invoice'] != null
          ? InvoiceModel.fromJson(json['invoice'])
          : null,
      duration: json['duration'],
      isMultipleServices: json['isMultipleServices'] ?? false,
      servicesBreakdown: json['servicesBreakdown'] != null
          ? (json['servicesBreakdown'] as List)
              .map((service) => ServiceBreakdown.fromJson(service))
              .toList()
          : [],
      services: json['services'] != null
          ? (json['services'] as List)
              .map((service) => OrderServiceModel.fromJson(service))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toRequestFormat() {
    // Get primary service info (first service or fallback)
    String primaryCategory = '';
    String primaryType = '';

    if (services.isNotEmpty) {
      // ✅ استخدام دالة getTitle() للحصول على العنوان حسب اللغة
      primaryCategory =
          services.first.category?.titleAr ?? services.first.getTitle();
      primaryType = services.first.serviceDescription ?? '';
    }

    return {
      'id': id.toString(),
      'name': user.name,
      'phone': user.phone,
      'profileImage':
          user.image.isNotEmpty ? user.image : 'assets/images/profile1.jpg',
      'state': user.state ?? 'غير محدد',
      'category': primaryCategory,
      'type': primaryType,
      'number': quantity,
      'scheduledDate': scheduledDate, // إضافة هذا السطر
      'duration':
          scheduledDate?.toIso8601String() ?? duration ?? 'not_specified'.tr,
      'totalPrice': providerAmount,
      'status': _mapStatus(status),
      'location': {
        'latitude': providerLocation?.lat ?? user.latitude ?? 0.0,
        'longitude': providerLocation?.lng ?? user.longitude ?? 0.0,
        'address': locationDetails ?? location ?? 'غير محدد',
      },
      'requestDate': orderDate,
      'originalOrder': this,
      'isMultipleServices': isMultipleServices,
      'services': services.map((s) => s.toJson()).toList(),
      'servicesBreakdown': servicesBreakdown.map((s) => s.toJson()).toList(),
    };
  }

  String _mapStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending':
        return 'pending';
      case 'accepted':
        return 'accepted';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'incomplete';
      default:
        return 'pending';
    }
  }
}

// New model for service breakdown
class ServiceBreakdown {
  final int quantity;
  final int serviceId;
  final double unitPrice;
  final double commission;
  final double totalPrice;
  final String serviceImage;
  final String serviceTitleAr; // ✅ تم التعديل
  final String serviceTitleEn; // ✅ جديد
  final double commissionAmount;
  final String? serviceDescription;

  ServiceBreakdown({
    required this.quantity,
    required this.serviceId,
    required this.unitPrice,
    required this.commission,
    required this.totalPrice,
    required this.serviceImage,
    required this.serviceTitleAr,
    required this.serviceTitleEn,
    required this.commissionAmount,
    this.serviceDescription,
  });

  // ✅ دالة للحصول على العنوان حسب اللغة
  String getTitle() {
    final LanguageService _languageService = Get.find<LanguageService>();
    return _languageService.isArabic ? serviceTitleAr : serviceTitleEn;
  }

  factory ServiceBreakdown.fromJson(Map<String, dynamic> json) {
    return ServiceBreakdown(
      quantity: json['quantity'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      serviceImage: json['serviceImage'] ?? '',
      serviceTitleAr: json['serviceTitleAr'] ?? '',
      serviceTitleEn: json['serviceTitleEn'] ?? '',
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      serviceDescription: json['serviceDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'serviceId': serviceId,
      'unitPrice': unitPrice,
      'commission': commission,
      'totalPrice': totalPrice,
      'serviceImage': serviceImage,
      'serviceTitleAr': serviceTitleAr,
      'serviceTitleEn': serviceTitleEn,
      'commissionAmount': commissionAmount,
      'serviceDescription': serviceDescription,
    };
  }
}

// Enhanced OrderServiceModel with category
class OrderServiceModel {
  final int quantity;
  final int serviceId;
  final double unitPrice;
  final double commission;
  final double totalPrice;
  final String serviceImage;
  final String serviceTitleAr; // ✅ تم التعديل
  final String serviceTitleEn; // ✅ جديد
  final double commissionAmount;
  final String? serviceDescription;
  final CategoryModel? category;

  OrderServiceModel({
    required this.quantity,
    required this.serviceId,
    required this.unitPrice,
    required this.commission,
    required this.totalPrice,
    required this.serviceImage,
    required this.serviceTitleAr,
    required this.serviceTitleEn,
    required this.commissionAmount,
    this.serviceDescription,
    this.category,
  });

  // ✅ دالة للحصول على العنوان حسب اللغة
  String getTitle() {
    final LanguageService _languageService = Get.find<LanguageService>();
    return _languageService.isArabic ? serviceTitleAr : serviceTitleEn;
  }

  factory OrderServiceModel.fromJson(Map<String, dynamic> json) {
    return OrderServiceModel(
      quantity: json['quantity'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      serviceImage: json['serviceImage'] ?? '',
      serviceTitleAr: json['serviceTitleAr'] ?? '', // ✅ تم التعديل
      serviceTitleEn: json['serviceTitleEn'] ?? '', // ✅ جديد
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      serviceDescription: json['serviceDescription'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'serviceId': serviceId,
      'unitPrice': unitPrice,
      'commission': commission,
      'totalPrice': totalPrice,
      'serviceImage': serviceImage,
      'serviceTitleAr': serviceTitleAr, // ✅ تم التعديل
      'serviceTitleEn': serviceTitleEn, // ✅ جديد
      'commissionAmount': commissionAmount,
      'serviceDescription': serviceDescription,
      'category': category?.toJson(),
    };
  }
}

class ProviderLocationModel {
  final double lat;
  final double lng;
  final String? address;

  ProviderLocationModel({
    required this.lat,
    required this.lng,
    this.address,
  });

  factory ProviderLocationModel.fromJson(Map<String, dynamic> json) {
    return ProviderLocationModel(
      lat: (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
      lng: (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String image;
  final String? state;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.image,
    this.state,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      image: json['image'] ?? '',
      state: json['state'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'image': image,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ProviderModel {
  final int id;
  final String name;
  final String phone;
  final String image;

  ProviderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.image,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'image': image,
    };
  }
}

class CategoryModel {
  final int id;
  final String image;
  final String titleAr;
  final String titleEn;
  final String state;

  CategoryModel({
    required this.id,
    required this.image,
    required this.titleAr,
    required this.titleEn,
    required this.state,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
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

class ServiceModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final CategoryModel? category;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'category': category?.toJson(),
    };
  }
}

class InvoiceModel {
  final int id;
  final int orderId;
  final DateTime? paymentDate;
  final double totalAmount;
  final double discount;
  final String paymentStatus;
  final String? paymentMethod;
  final int? verifiedBy;
  final DateTime? verifiedAt;
  final String payoutStatus;
  final DateTime? payoutDate;

  InvoiceModel({
    required this.id,
    required this.orderId,
    this.paymentDate,
    required this.totalAmount,
    required this.discount,
    required this.paymentStatus,
    this.paymentMethod,
    this.verifiedBy,
    this.verifiedAt,
    required this.payoutStatus,
    this.payoutDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? '',
      paymentMethod: json['paymentMethod'],
      verifiedBy: json['verifiedBy'],
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      payoutStatus: json['payoutStatus'] ?? '',
      payoutDate: json['payoutDate'] != null
          ? DateTime.parse(json['payoutDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'paymentDate': paymentDate?.toIso8601String(),
      'totalAmount': totalAmount,
      'discount': discount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'payoutStatus': payoutStatus,
      'payoutDate': payoutDate?.toIso8601String(),
    };
  }
}

// Keep existing models for backward compatibility
class OrderUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final double? latitude;
  final double? longitude;

  OrderUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.latitude,
    this.longitude,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class OrderService {
  final int id;
  final String title;
  final String description;

  OrderService({
    required this.id,
    required this.title,
    required this.description,
  });

  factory OrderService.fromJson(Map<String, dynamic> json) {
    return OrderService(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}

class ProviderOrder {
  final int id;
  final String status;
  final DateTime orderDate;
  final DateTime? scheduledDate;
  final String? location;
  final String? locationDetails;
  final int quantity;
  final double totalAmount;
  final double providerAmount;
  final double commissionAmount;
  final String bookingId;
  final OrderUser user;
  final OrderService service;

  ProviderOrder({
    required this.id,
    required this.status,
    required this.orderDate,
    this.scheduledDate,
    this.location,
    this.locationDetails,
    required this.quantity,
    required this.totalAmount,
    required this.providerAmount,
    required this.commissionAmount,
    required this.bookingId,
    required this.user,
    required this.service,
  });

  factory ProviderOrder.fromJson(Map<String, dynamic> json) {
    return ProviderOrder(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'])
          : DateTime.now(),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'])
          : null,
      location: json['location'],
      locationDetails: json['locationDetails'],
      quantity: json['quantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      providerAmount: (json['providerAmount'] ?? 0).toDouble(),
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      bookingId: json['bookingId'] ?? '',
      user: OrderUser.fromJson(json['user'] ?? {}),
      service: OrderService.fromJson(json['service'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'location': location,
      'locationDetails': locationDetails,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'providerAmount': providerAmount,
      'commissionAmount': commissionAmount,
      'bookingId': bookingId,
      'user': user.toJson(),
      'service': service.toJson(),
    };
  }

  Map<String, dynamic> toNotification() {
    return {
      'id': id,
      'category': service.title,
      'type': service.description,
      'number': quantity,
      'duration': scheduledDate != null
          ? '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}'
          : 'غير محدد',
      'state': location ?? 'غير محدد',
      'price': providerAmount,
      'location': {
        'latitude': user.latitude ?? 0.0,
        'longitude': user.longitude ?? 0.0,
        'address': locationDetails ?? location ?? 'غير محدد'
      },
      'customerName': user.name,
      'customerPhone': user.phone,
      'requestTime': orderDate,
      'isRead': false,
      'priority': _getPriority(),
      'bookingId': bookingId,
      'orderId': id,
    };
  }

  String _getPriority() {
    if (providerAmount >= 100) return 'high';
    if (providerAmount >= 50) return 'medium';
    return 'low';
  }

  ProviderOrder copyWith({
    int? id,
    String? status,
    DateTime? orderDate,
    DateTime? scheduledDate,
    String? location,
    String? locationDetails,
    int? quantity,
    double? totalAmount,
    double? providerAmount,
    double? commissionAmount,
    String? bookingId,
    OrderUser? user,
    OrderService? service,
  }) {
    return ProviderOrder(
      id: id ?? this.id,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      location: location ?? this.location,
      locationDetails: locationDetails ?? this.locationDetails,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      providerAmount: providerAmount ?? this.providerAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      bookingId: bookingId ?? this.bookingId,
      user: user ?? this.user,
      service: service ?? this.service,
    );
  }
}

class ProviderOrdersResponse {
  final List<ProviderOrder> orders;
  final int total;
  final String status;

  ProviderOrdersResponse({
    required this.orders,
    required this.total,
    required this.status,
  });

  factory ProviderOrdersResponse.fromJson(Map<String, dynamic> json) {
    var ordersList = json['orders'] as List? ?? [];
    List<ProviderOrder> orders = ordersList
        .map((orderJson) => ProviderOrder.fromJson(orderJson))
        .toList();

    return ProviderOrdersResponse(
      orders: orders,
      total: json['total'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
      'total': total,
      'status': status,
    };
  }
}
