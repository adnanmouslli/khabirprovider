import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../utils/app_config.dart';
import 'storage_service.dart';

class DioService {
  late dio.Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();

  DioService() {
    _dio = dio.Dio();
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.userToken;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          if (AppConfig.enableLogging) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('DATA: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.enableLogging) {
            print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (AppConfig.enableLogging) {
            print('ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
            print('ERROR DATA: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );

    _dio.options.connectTimeout = Duration(seconds: AppConfig.connectionTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: AppConfig.receiveTimeoutSeconds);
    _dio.options.sendTimeout = Duration(seconds: AppConfig.sendTimeoutSeconds);
  }

  // GET request
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<dio.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<dio.Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<dio.Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST with multipart (for file uploads)
  Future<dio.Response> postMultipart(
    String path, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
  }) async {
    try {
      final formData = dio.FormData.fromMap(data);

      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update token for authenticated requests
  void updateToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear token
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }
}
