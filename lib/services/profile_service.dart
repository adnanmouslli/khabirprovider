import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../utils/app_config.dart';
import 'dio_service.dart';
import 'storage_service.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ProfileService {
  final DioService _dioService = DioService();
  final StorageService _storageService = Get.find<StorageService>();

  // Base URL
  static const String _baseUrl = AppConfig.baseUrl;
  static const String fileUrl = AppConfig.fileUrl;

  // Profile endpoints
  static const String _getProfile = '/providers/profile';
  static const String _updateProfile = '/providers';
  static const String _deleteAccount = '/auth/delete-account';

  // جلب بيانات البروفايل
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dioService.get('$_baseUrl$_getProfile');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // تحديث حالة المزود مع استخدام ID من التخزين
  Future<Map<String, dynamic>> updateProviderStatus(bool isActive) async {
    try {
      final response = await _dioService.put(
        '${AppConfig.baseUrl}/providers/online-status',
        data: {
          'onlineStatus': isActive,
        },
      );

      if (response.statusCode == 200) {
        print('Provider status updated successfully');

        // تحديث البيانات المحفوظة أيضاً
        _updateLocalUserData('isActive', isActive);

        return response.data;
      } else {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      print('DioException in updateProviderStatus: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        final errorMessage = e.response?.data['message'] ?? e.message;
        throw Exception('API Error: $errorMessage');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error in updateProviderStatus: $e');
      throw Exception('Unexpected Error: $e');
    }
  }

  // تحديث البيانات المحلية المحفوظة
  void _updateLocalUserData(String key, dynamic value) {
    try {
      final currentUserData =
          Map<String, dynamic>.from(_storageService.userData);
      currentUserData[key] = value;
      _storageService.userData = currentUserData;
      print('Local user data updated: $key = $value');
    } catch (e) {
      print('Error updating local user data: $e');
    }
  }

  // الحصول على ID المزود من التخزين - تم إصلاح هذه الدالة
  String? getProviderIdFromStorage() {
    try {
      final userData = _storageService.userData;
      final providerId = userData['id'];

      if (providerId == null) {
        print('Provider ID is null in storage');
        return null;
      }

      // تحويل إلى String بغض النظر عن النوع الأصلي
      return providerId.toString();
    } catch (e) {
      print('Error getting provider ID from storage: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? state,
    String? city,
    String? description,
    File? imageFile,
  }) async {
    try {
      // الحصول على ID المزود من بيانات المستخدم المحفوظة
      final providerId = getProviderIdFromStorage();

      // التحقق من وجود ID
      if (providerId == null) {
        throw Exception('لا يمكن العثور على معرف المزود في البيانات المحفوظة');
      }

      print('Updating profile for ID: $providerId');

      // إذا كان هناك صورة، استخدم FormData
      if (imageFile != null) {
        return await _updateProfileWithImage(
          providerId: providerId,
          name: name,
          phone: phone,
          address: address,
          state: state,
          city: city,
          description: description,
          imageFile: imageFile,
        );
      }

      // إذا لم تكن هناك صورة، استخدم الطريقة العادية
      final Map<String, dynamic> data = {};

      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (state != null) data['state'] = state;
      if (city != null) data['city'] = city;
      if (description != null) data['description'] = description;

      print('Updating profile with data: $data');

      final response = await _dioService.put(
        '$_baseUrl$_updateProfile/$providerId',
        data: data,
      );

      // تحديث البيانات المحلية
      data.forEach((key, value) {
        _updateLocalUserData(key, value);
      });

      print('Profile updated successfully');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // دالة حذف الحساب
Future<Map<String, dynamic>> deleteAccount() async {
  try {
    final providerId = getProviderIdFromStorage();

    if (providerId == null) {
      throw Exception('لا يمكن العثور على معرف المزود');
    }

    print('Deleting account for provider ID: $providerId');

    final response = await _dioService.delete(
      '$_baseUrl$_deleteAccount',
    );

    print('Account deleted successfully');
    print('Response: ${response.data}');
    
    return response.data;
  } on dio.DioException catch (e) {
    print('DioException status code: ${e.response?.statusCode}');
    print('DioException response: ${e.response?.data}');
    
    // معالجة أخطاء HTTP حسب الـ status code
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;
      
      switch (statusCode) {
        case 400: // Bad Request - فواتير غير مدفوعة أو طلبات معلقة
          final message = responseData['message'] ?? 'خطأ في البيانات';
          throw AccountDeletionException(
            message: message,
            statusCode: statusCode,
            type: AccountDeletionErrorType.unpaidInvoices,
          );
          
        case 401: // Unauthorized
          throw AccountDeletionException(
            message: 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى',
            statusCode: statusCode,
            type: AccountDeletionErrorType.unauthorized,
          );
          
        case 403: // Forbidden
          throw AccountDeletionException(
            message: 'ليس لديك صلاحية لحذف هذا الحساب',
            statusCode: statusCode,
            type: AccountDeletionErrorType.forbidden,
          );
          
        case 404: // Not Found
          throw AccountDeletionException(
            message: 'الحساب غير موجود',
            statusCode: statusCode,
            type: AccountDeletionErrorType.notFound,
          );
          
        case 500: // Internal Server Error
          throw AccountDeletionException(
            message: 'حدث خطأ في السيرفر. يرجى المحاولة لاحقاً',
            statusCode: statusCode,
            type: AccountDeletionErrorType.serverError,
          );
          
        default:
          throw AccountDeletionException(
            message: responseData['message'] ?? 'حدث خطأ غير متوقع',
            statusCode: statusCode,
            type: AccountDeletionErrorType.unknown,
          );
      }
    }
    
    throw Exception(_handleDioError(e));
  } catch (e) {
    print('Unexpected error: $e');
    
    // إذا كان الخطأ من نوع AccountDeletionException، نعيد رميه
    if (e is AccountDeletionException) {
      rethrow;
    }
    
    throw Exception('فشل في حذف الحساب: $e');
  }
}


  // دالة منفصلة لتحديث البروفايل مع الصورة - تم تحسينها
  Future<Map<String, dynamic>> _updateProfileWithImage({
    required String providerId,
    String? name,
    String? phone,
    String? address,
    String? state,
    String? city,
    String? description,
    required File imageFile,
  }) async {
    try {
      // التحقق من وجود الملف وصحته
      if (!await imageFile.exists()) {
        throw Exception('ملف الصورة غير موجود');
      }

      // الحصول على اسم الملف وامتداده
      String fileName = path.basename(imageFile.path);
      String fileExtension = path.extension(fileName).toLowerCase();

      // التحقق من نوع الملف
      if (!['.jpg', '.jpeg', '.png', '.webp'].contains(fileExtension)) {
        throw Exception('نوع ملف غير مدعوم. يُسمح فقط بـ JPG, PNG, WEBP');
      }

      // التحقق من حجم الملف (مثلاً أقل من 5 ميجا)
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('حجم الصورة كبير جداً. يجب أن يكون أقل من 5 ميجا');
      }

      print('Preparing to upload image: $fileName (${fileSize} bytes)');

      // إنشاء FormData
      final formData = dio.FormData.fromMap({
        "image": await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // إضافة البيانات النصية إذا كانت موجودة
      if (name != null && name.isNotEmpty) {
        formData.fields.add(MapEntry('name', name));
      }
      if (phone != null && phone.isNotEmpty) {
        formData.fields.add(MapEntry('phone', phone));
      }
      if (address != null && address.isNotEmpty) {
        formData.fields.add(MapEntry('address', address));
      }
      if (state != null && state.isNotEmpty) {
        formData.fields.add(MapEntry('state', state));
      }
      if (city != null && city.isNotEmpty) {
        formData.fields.add(MapEntry('city', city));
      }
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('description', description));
      }

      print('Sending FormData with ${formData.fields.length} fields');

      // إرسال الطلب مع options محسنة
      final response = await _dioService.put(
        '$_baseUrl$_updateProfile/$providerId',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(seconds: 30), // زيادة وقت الإرسال للصور
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');

      // معالجة الاستجابة وتحديث البيانات المحلية
      if (response.statusCode == 200) {
        await _handleSuccessfulImageUpdate(
          response.data,
          name: name,
          phone: phone,
          address: address,
          state: state,
          city: city,
          description: description,
        );
      }

      print('Profile with image updated successfully');
      return response.data;
    } on dio.DioException catch (e) {
      print('DioException in image update: ${e.message}');
      print('DioException type: ${e.type}');
      if (e.response != null) {
        print('Error response: ${e.response?.data}');
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      print('Unexpected error updating profile with image: $e');
      throw Exception('فشل في تحديث البروفايل مع الصورة: $e');
    }
  }

  // طلب تغيير رقم الهاتف (إرسال OTP)
  Future<Map<String, dynamic>> requestPhoneChange(String newPhoneNumber) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/providers/change-phone/request',
        data: {
          'newPhoneNumber': newPhoneNumber,
        },
      );

      print('Phone change request sent successfully');
      return response.data;
    } on dio.DioException catch (e) {
      print('Error requesting phone change: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('فشل في إرسال طلب تغيير الرقم: $e');
    }
  }

// تأكيد تغيير رقم الهاتف (التحقق من OTP)
  Future<Map<String, dynamic>> verifyPhoneChange({
    required String newPhoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _dioService.post(
        '$_baseUrl/providers/change-phone/verify',
        data: {
          'newPhoneNumber': newPhoneNumber,
          'otp': otp,
        },
      );

      print('Phone change verified successfully');

      // تحديث رقم الهاتف في التخزين المحلي
      if (response.statusCode == 200) {
        _updateLocalUserData('phone', newPhoneNumber);
      }

      return response.data;
    } on dio.DioException catch (e) {
      print('Error verifying phone change: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('فشل في التحقق من الرمز: $e');
    }
  }

  // معالجة الاستجابة الناجحة لتحديث الصورة
  Future<void> _handleSuccessfulImageUpdate(
    Map<String, dynamic> responseData, {
    String? name,
    String? phone,
    String? address,
    String? state,
    String? city,
    String? description,
  }) async {
    try {
      // تحديث البيانات النصية
      if (name != null && name.isNotEmpty) _updateLocalUserData('name', name);
      if (phone != null && phone.isNotEmpty)
        _updateLocalUserData('phone', phone);
      if (address != null && address.isNotEmpty)
        _updateLocalUserData('address', address);
      if (state != null && state.isNotEmpty)
        _updateLocalUserData('state', state);
      if (city != null && city.isNotEmpty) _updateLocalUserData('city', city);
      if (description != null && description.isNotEmpty)
        _updateLocalUserData('description', description);

      // تحديث رابط الصورة
      String? imageUrl;

      // محاولة الحصول على رابط الصورة من الاستجابة
      if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          imageUrl = data['image'] ?? data['image_url'] ?? data['url'];
        }
      }

      // إذا لم نجد الصورة في data، ابحث في الجذر
      imageUrl ??= responseData['image'] ??
          responseData['image_url'] ??
          responseData['url'];

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // التأكد من أن الرابط صحيح
        if (!imageUrl.startsWith('http')) {
          imageUrl = '${AppConfig.baseUrl}$imageUrl';
        }
        _updateLocalUserData('image', imageUrl);
        print('Image URL updated: $imageUrl');
      } else {
        print('Warning: No image URL found in response');
      }
    } catch (e) {
      print('Error handling successful image update: $e');
    }
  }

  // حفظ بيانات البروفايل في التخزين المحلي بعد جلبها من API
  Future<void> saveProfileToStorage(Map<String, dynamic> profileData) async {
    try {
      if (profileData.containsKey('provider')) {
        final providerData = profileData['provider'] as Map<String, dynamic>;

        // دمج البيانات الحالية مع البيانات الجديدة
        final currentUserData =
            Map<String, dynamic>.from(_storageService.userData);
        currentUserData.addAll(providerData);

        _storageService.userData = currentUserData;
        print('Profile data saved to storage successfully');
      }
    } catch (e) {
      print('Error saving profile to storage: $e');
    }
  }

  Future<Map<String, String?>> getTermsAndConditions() async {
    try {
      final response = await _dioService
          .get('$_baseUrl/admin/settings/terms-and-conditions');

      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        // تكوين الروابط الكاملة بإضافة baseUrl
        String? termsEn = responseData['terms_en'] as String?;
        String? termsAr = responseData['terms_ar'] as String?;

        String? privacy_en = responseData['privacy_en'] as String?;

        String? privacy_ar = responseData['privacy_ar'] as String?;

        return {
          'terms_en': termsEn != null ? '$fileUrl$termsEn' : null,
          'terms_ar': termsAr != null ? '$fileUrl$termsAr' : null,
          'privacy_en': privacy_en != null ? '$fileUrl$privacy_en' : null,
          'privacy_ar': privacy_ar != null ? '$fileUrl$privacy_ar' : null,
        };
      }

      // في حالة كانت البيانات بشكل مختلف
      return {
        'terms_en': null,
        'terms_ar': null,
      };
    } catch (e) {
      print('Error fetching terms and conditions: $e');
      // إرجاع قيم فارغة في حالة الخطأ
      return {
        'terms_en': null,
        'terms_ar': null,
      };
    }
  }

  // معالجة أخطاء Dio محسنة
  String _handleDioError(dio.DioException error) {
    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
        return 'انتهت مهلة رفع الصورة، يرجى المحاولة مرة أخرى';

      case dio.DioExceptionType.receiveTimeout:
        return 'انتهت مهلة استقبال الاستجابة، يرجى المحاولة مرة أخرى';

      case dio.DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              return data?['message'] ?? 'بيانات الصورة غير صحيحة';
            case 401:
              return 'غير مخول، يرجى تسجيل الدخول مرة أخرى';
            case 413:
              return 'حجم الصورة كبير جداً';
            case 415:
              return 'نوع الصورة غير مدعوم';
            case 422:
              return data?['message'] ?? 'بيانات غير صالحة';
            case 500:
              return 'خطأ في الخادم، يرجى المحاولة لاحقاً';
            default:
              return data?['message'] ?? 'حدث خطأ غير متوقع';
          }
        }
        break;

      case dio.DioExceptionType.cancel:
        return 'تم إلغاء رفع الصورة';

      case dio.DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return 'لا يوجد اتصال بالإنترنت';
        }
        return 'حدث خطأ في الاتصال';

      default:
        return 'حدث خطأ غير متوقع في رفع الصورة';
    }
    return error.message ?? 'خطأ غير معروف';
  }

  // معالجة الأخطاء العامة
  String _handleError(dynamic error) {
    if (error is dio.DioException) {
      return _handleDioError(error);
    }
    return error.toString();
  }
}


// في ملف جديد: lib/models/account_deletion_exception.dart
enum AccountDeletionErrorType {
  unpaidInvoices,
  pendingOrders,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  unknown,
}

class AccountDeletionException implements Exception {
  final String message;
  final int? statusCode;
  final AccountDeletionErrorType type;

  AccountDeletionException({
    required this.message,
    this.statusCode,
    required this.type,
  });

  @override
  String toString() => message;
}