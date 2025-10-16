class ProfileResponse {
  final User user;
  final SystemInfo systemInfo;

  ProfileResponse({
    required this.user,
    required this.systemInfo,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      // تغيير من 'user' إلى 'provider' حسب استجابة الـ API
      user: User.fromJson(json['provider']),
      systemInfo: SystemInfo.fromJson(json['systemInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': user.toJson(), // تغيير للتوافق مع API
      'systemInfo': systemInfo.toJson(),
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? image;
  final String? address;
  final String phone;
  final String state;
  final bool isActive;
  final String? officialDocuments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final String? city;
  final bool? isVerified;
  final String? location;
  final bool onlineStatus; // إضافة الحقل الجديد

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'provider',
    this.image,
    this.address,
    required this.phone,
    required this.state,
    required this.isActive,
    this.officialDocuments,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.city,
    this.isVerified,
    this.location,
    this.onlineStatus = false, // قيمة افتراضية
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'provider',
      image: json['image'],
      address: json['address'],
      phone: json['phone'] ?? '',
      state: json['state'] ?? '',
      isActive: json['isActive'] ?? false,
      officialDocuments: json['officialDocuments'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      description: json['description'],
      city: json['city'],
      isVerified: json['isVerified'],
      location: json['location'],
      onlineStatus: json['onlineStatus'] ?? false, // إضافة الحقل الجديد
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'image': image,
      'address': address,
      'phone': phone,
      'state': state,
      'isActive': isActive,
      'officialDocuments': officialDocuments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'city': city,
      'isVerified': isVerified,
      'location': location,
      'onlineStatus': onlineStatus, // إضافة الحقل الجديد
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? image,
    String? address,
    String? phone,
    String? state,
    bool? isActive,
    String? officialDocuments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    String? city,
    bool? isVerified,
    String? location,
    bool? onlineStatus, // إضافة الحقل الجديد
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      image: image ?? this.image,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      isActive: isActive ?? this.isActive,
      officialDocuments: officialDocuments ?? this.officialDocuments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      city: city ?? this.city,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      onlineStatus: onlineStatus ?? this.onlineStatus, // إضافة الحقل الجديد
    );
  }
}
class SystemInfo {
  final SocialMedia socialMedia;
  final LegalDocuments legalDocuments;
  final Support support;

  SystemInfo({
    required this.socialMedia,
    required this.legalDocuments,
    required this.support,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      socialMedia: SocialMedia.fromJson(json['socialMedia'] ?? {}),
      legalDocuments: LegalDocuments.fromJson(json['legalDocuments'] ?? {}),
      support: Support.fromJson(json['support'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'socialMedia': socialMedia.toJson(),
      'legalDocuments': legalDocuments.toJson(),
      'support': support.toJson(),
    };
  }
}

class SocialMedia {
  final String? whatsapp;
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final String? snapchat;

  SocialMedia({
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.tiktok,
    this.snapchat,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      whatsapp: json['whatsapp'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      tiktok: json['tiktok'],
      snapchat: json['snapchat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsapp': whatsapp,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'snapchat': snapchat,
    };
  }
}

class LegalDocuments {
  final String? termsEn;
  final String? termsAr;
  final String? privacyEn;
  final String? privacyAr;

  LegalDocuments({
    this.termsEn,
    this.termsAr,
    this.privacyEn,
    this.privacyAr,
  });

  factory LegalDocuments.fromJson(Map<String, dynamic> json) {
    return LegalDocuments(
      termsEn: json['terms_en'],
      termsAr: json['terms_ar'],
      privacyEn: json['privacy_en'],
      privacyAr: json['privacy_ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms_en': termsEn,
      'terms_ar': termsAr,
      'privacy_en': privacyEn,
      'privacy_ar': privacyAr,
    };
  }
}

class Support {
  final String? whatsappSupport;

  Support({
    this.whatsappSupport,
  });

  factory Support.fromJson(Map<String, dynamic> json) {
    return Support(
      whatsappSupport: json['whatsapp_support'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsapp_support': whatsappSupport,
    };
  }
}