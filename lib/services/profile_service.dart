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

  // Profile endpoints
  static const String _getProfile = '/providers/profile';
  static const String _updateProfile = '/providers';
  static const String _uploadImage = '/providers/profile/image';

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
      // الحصول على ID المزود من بيانات المستخدم المحفوظة
      final providerId = getProviderIdFromStorage();

      // التحقق من وجود ID
      if (providerId == null) {
        throw Exception('لا يمكن العثور على معرف المزود في البيانات المحفوظة');
      }

      print('Updating provider status for ID: $providerId to $isActive');

      final response = await _dioService.put(
        '${AppConfig.baseUrl}/providers/$providerId/status',
        data: {
          'isActive': isActive,
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
      final currentUserData = Map<String, dynamic>.from(_storageService.userData);
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
    String? email,
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
          email: email,
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
      if (email != null) data['email'] = email;
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

  // دالة منفصلة لتحديث البروفايل مع الصورة - تم تحسينها
  Future<Map<String, dynamic>> _updateProfileWithImage({
    required String providerId,
    String? name,
    String? email,
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
      if (email != null && email.isNotEmpty) {
        formData.fields.add(MapEntry('email', email));
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
          email: email,
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

  // معالجة الاستجابة الناجحة لتحديث الصورة
  Future<void> _handleSuccessfulImageUpdate(
      Map<String, dynamic> responseData, {
        String? name,
        String? email,
        String? phone,
        String? address,
        String? state,
        String? city,
        String? description,
      }) async {
    try {
      // تحديث البيانات النصية
      if (name != null && name.isNotEmpty) _updateLocalUserData('name', name);
      if (email != null && email.isNotEmpty) _updateLocalUserData('email', email);
      if (phone != null && phone.isNotEmpty) _updateLocalUserData('phone', phone);
      if (address != null && address.isNotEmpty) _updateLocalUserData('address', address);
      if (state != null && state.isNotEmpty) _updateLocalUserData('state', state);
      if (city != null && city.isNotEmpty) _updateLocalUserData('city', city);
      if (description != null && description.isNotEmpty) _updateLocalUserData('description', description);

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
      imageUrl ??= responseData['image'] ?? responseData['image_url'] ?? responseData['url'];

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
        final currentUserData = Map<String, dynamic>.from(_storageService.userData);
        currentUserData.addAll(providerData);

        _storageService.userData = currentUserData;
        print('Profile data saved to storage successfully');
      }
    } catch (e) {
      print('Error saving profile to storage: $e');
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