import '../models/order_model.dart';

class InvoiceModel {
  final int id;
  final int orderId;
  final DateTime? paymentDate;
  final double totalAmount;
  final double discount;
  final String? paymentMethod;
  final String paymentStatus;
  final DateTime? payoutDate;
  final String payoutStatus;
  final InvoiceOrderModel order;
  final double commissionAmount;
  final double providerAmount;
  final int quantity;

  InvoiceModel({
    required this.id,
    required this.orderId,
    this.paymentDate,
    required this.totalAmount,
    required this.discount,
    this.paymentMethod,
    required this.paymentStatus,
    this.payoutDate,
    required this.payoutStatus,
    required this.order,
    required this.commissionAmount,
    required this.providerAmount,
    required this.quantity,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate']) : null,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'] ?? 'unpaid',
      payoutDate: json['payoutDate'] != null ? DateTime.parse(json['payoutDate']) : null,
      payoutStatus: json['payoutStatus'] ?? 'pending',
      order: InvoiceOrderModel.fromJson(json['order'] ?? {}),
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      providerAmount: (json['providerAmount'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'paymentDate': paymentDate?.toIso8601String(),
      'totalAmount': totalAmount,
      'discount': discount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'payoutDate': payoutDate?.toIso8601String(),
      'payoutStatus': payoutStatus,
      'order': order.toJson(),
      'commissionAmount': commissionAmount,
      'providerAmount': providerAmount,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toIncomeFormat() {
    // معالجة الخدمات المتعددة
    String category = '';
    String type = '';

    if (order.isMultipleServices && order.services.isNotEmpty) {
      // للخدمات المتعددة، استخدم الخدمة الأولى كأساس
      category = order.services.first.category?.titleAr ?? order.services.first.serviceTitle;
      type = order.services.first.serviceDescription;
    } else if (order.services.isNotEmpty) {
      // للخدمة الواحدة
      category = order.services.first.category?.titleAr ?? order.services.first.serviceTitle;
      type = order.services.first.serviceDescription;
    } else {
      // fallback للنظام القديم
      category = 'خدمة';
      type = 'غير محدد';
    }

    return {
      'id': id.toString(),
      'customerName': order.user.name,
      'phone': order.user.phone,
      'profileImage': order.user.image.isNotEmpty
          ? order.user.image.startsWith('/uploads')
          ? 'https://your-api-domain.com${order.user.image}' // تحديث بالدومين الحقيقي
          : order.user.image
          : 'assets/images/profile1.jpg',
      'state': order.user.state ?? 'غير محدد',
      'category': category,
      'type': type,
      'number': quantity,
      'duration': order.scheduledDate != null
          ? '${order.scheduledDate!.day}/${order.scheduledDate!.month}/${order.scheduledDate!.year}'
          : 'غير محدد',
      'totalPrice': totalAmount,
      'commission': commissionAmount,
      'afterCommission': providerAmount,
      'paymentStatus': paymentStatus == 'paid' ? 'Paid' : 'Not paid',
      'completedDate': paymentDate ?? order.orderDate,
      'originalInvoice': this,
      // معلومات الخدمات المتعددة
      'isMultipleServices': order.isMultipleServices,
      'services': order.services.map((s) => {
        'serviceTitle': s.serviceTitle,
        'serviceDescription': s.serviceDescription,
        'quantity': s.quantity,
        'totalPrice': s.totalPrice,
        'category': s.category?.titleAr,
      }).toList(),
      'servicesCount': order.services.length,
      'totalServicesQuantity': order.services.fold(0, (sum, s) => sum + s.quantity),
      'servicesBreakdown': order.servicesBreakdown.map((s) => {
        'serviceTitle': s.serviceTitle,
        'serviceDescription': s.serviceDescription,
        'quantity': s.quantity,
        'totalPrice': s.totalPrice,
      }).toList(),
    };
  }
}

class InvoiceOrderModel {
  final DateTime? scheduledDate;
  final DateTime orderDate;
  final double commissionAmount;
  final double providerAmount;
  final int quantity;
  final bool isMultipleServices;
  final List<InvoiceServiceBreakdown> servicesBreakdown;
  final InvoiceUserModel user;
  final InvoiceProviderModel provider;
  final List<InvoiceServiceModel> services;

  InvoiceOrderModel({
    this.scheduledDate,
    required this.orderDate,
    required this.commissionAmount,
    required this.providerAmount,
    required this.quantity,
    this.isMultipleServices = false,
    this.servicesBreakdown = const [],
    required this.user,
    required this.provider,
    this.services = const [],
  });

  factory InvoiceOrderModel.fromJson(Map<String, dynamic> json) {
    return InvoiceOrderModel(
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toIso8601String()),
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      providerAmount: (json['providerAmount'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      isMultipleServices: json['isMultipleServices'] ?? false,
      servicesBreakdown: json['servicesBreakdown'] != null
          ? (json['servicesBreakdown'] as List)
          .map((service) => InvoiceServiceBreakdown.fromJson(service))
          .toList()
          : [],
      user: InvoiceUserModel.fromJson(json['user'] ?? {}),
      provider: InvoiceProviderModel.fromJson(json['provider'] ?? {}),
      services: json['services'] != null
          ? (json['services'] as List)
          .map((service) => InvoiceServiceModel.fromJson(service))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduledDate': scheduledDate?.toIso8601String(),
      'orderDate': orderDate.toIso8601String(),
      'commissionAmount': commissionAmount,
      'providerAmount': providerAmount,
      'quantity': quantity,
      'isMultipleServices': isMultipleServices,
      'servicesBreakdown': servicesBreakdown.map((s) => s.toJson()).toList(),
      'user': user.toJson(),
      'provider': provider.toJson(),
      'services': services.map((s) => s.toJson()).toList(),
    };
  }
}

class InvoiceServiceBreakdown {
  final int quantity;
  final int serviceId;
  final double unitPrice;
  final double commission;
  final double totalPrice;
  final String serviceImage;
  final String serviceTitle;
  final double commissionAmount;
  final String serviceDescription;

  InvoiceServiceBreakdown({
    required this.quantity,
    required this.serviceId,
    required this.unitPrice,
    required this.commission,
    required this.totalPrice,
    required this.serviceImage,
    required this.serviceTitle,
    required this.commissionAmount,
    required this.serviceDescription,
  });

  factory InvoiceServiceBreakdown.fromJson(Map<String, dynamic> json) {
    return InvoiceServiceBreakdown(
      quantity: json['quantity'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      serviceImage: json['serviceImage'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      serviceDescription: json['serviceDescription'] ?? '',
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
      'serviceTitle': serviceTitle,
      'commissionAmount': commissionAmount,
      'serviceDescription': serviceDescription,
    };
  }
}

class InvoiceServiceModel {
  final int quantity;
  final int serviceId;
  final double unitPrice;
  final double commission;
  final double totalPrice;
  final String serviceImage;
  final String serviceTitle;
  final double commissionAmount;
  final String serviceDescription;
  final InvoiceCategoryModel? category;

  InvoiceServiceModel({
    required this.quantity,
    required this.serviceId,
    required this.unitPrice,
    required this.commission,
    required this.totalPrice,
    required this.serviceImage,
    required this.serviceTitle,
    required this.commissionAmount,
    required this.serviceDescription,
    this.category,
  });

  factory InvoiceServiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceServiceModel(
      quantity: json['quantity'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      serviceImage: json['serviceImage'] ?? '',
      serviceTitle: json['serviceTitle'] ?? '',
      commissionAmount: (json['commissionAmount'] ?? 0).toDouble(),
      serviceDescription: json['serviceDescription'] ?? '',
      category: json['category'] != null ? InvoiceCategoryModel.fromJson(json['category']) : null,
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
      'serviceTitle': serviceTitle,
      'commissionAmount': commissionAmount,
      'serviceDescription': serviceDescription,
      'category': category?.toJson(),
    };
  }
}

class InvoiceCategoryModel {
  final int id;
  final String image;
  final String titleAr;
  final String titleEn;
  final String state;

  InvoiceCategoryModel({
    required this.id,
    required this.image,
    required this.titleAr,
    required this.titleEn,
    required this.state,
  });

  factory InvoiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return InvoiceCategoryModel(
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

class InvoiceUserModel {
  final int id;
  final String name;
  final String? email;
  final String phone;
  final String state;
  final String image;
  final double? latitude;
  final double? longitude;
  final String? address;

  InvoiceUserModel({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.state,
    required this.image,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory InvoiceUserModel.fromJson(Map<String, dynamic> json) {
    return InvoiceUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      state: json['state'] ?? '',
      image: json['image'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'state': state,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

class InvoiceProviderModel {
  final int id;
  final String name;
  final String phone;

  InvoiceProviderModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory InvoiceProviderModel.fromJson(Map<String, dynamic> json) {
    return InvoiceProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}