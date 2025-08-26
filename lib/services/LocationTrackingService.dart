import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:khabir/services/storage_service.dart';
import '../utils/app_config.dart';

class LocationTrackingService extends GetxService {
  IO.Socket? _socket;
  Timer? _locationTimer;
  final StorageService _storageService = Get.find<StorageService>();

  bool _isTracking = false;
  String? _currentOrderId;

  // Socket URL - استبدل هذا بعنوان الخادم الخاص بك
  static const String _socketUrl = 'ws://31.97.71.187:3000/location-tracking';

  @override
  void onInit() {
    super.onInit();
    _initSocket();
  }

  // إعداد الاتصال بالسوكيت
  void _initSocket() {
    try {
      final token = _storageService.userToken;

      _socket = IO.io(
          _socketUrl,
          IO.OptionBuilder()
              .setAuth({
                'token': token,
              })
              .setTransports(['websocket'])
              .enableAutoConnect()
              .enableForceNew()
              .build());

      _socket?.on('connect', (_) {
        print('✅ Socket connected successfully');
      });

      _socket?.on('disconnect', (_) {
        print('❌ Socket disconnected');
      });

      _socket?.on('error', (error) {
        print('🔥 Socket error: $error');
      });
    } catch (e) {
      print('Error initializing socket: $e');
    }
  }

  // بدء تتبع الموقع
  Future<void> startLocationTracking(String orderId) async {
    try {
      if (_isTracking) {
        print('Location tracking already started');
        return;
      }

      // التحقق من صلاحيات الموقع
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }

      _currentOrderId = orderId;
      _isTracking = true;

      // إرسال إشارة بدء التتبع للسيرفر
      _socket?.emit('start_tracking', {
        'orderId': orderId,
        'updateInterval': 30, // 30 ثانية
      });

      // بدء إرسال الموقع كل 30 ثانية
      _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _sendCurrentLocation();
      });

      // إرسال الموقع الأول فوراً
      _sendCurrentLocation();

      print('✅ Location tracking started for order: $orderId');
    } catch (e) {
      print('Error starting location tracking: $e');
      _isTracking = false;
    }
  }

  // إيقاف تتبع الموقع
  void stopLocationTracking() {
    try {
      _locationTimer?.cancel();
      _locationTimer = null;
      _isTracking = false;

      if (_currentOrderId != null) {
        print('✅ Location tracking stopped for order: $_currentOrderId');
      }

      _currentOrderId = null;
    } catch (e) {
      print('Error stopping location tracking: $e');
    }
  }

  // إرسال الموقع الحالي
  Future<void> _sendCurrentLocation() async {
    try {
      if (!_isTracking ||
          _currentOrderId == null ||
          _socket?.connected != true) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _socket?.emit('update_location', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'orderId': _currentOrderId,
      });

      print('📍 Location sent: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  // التحقق من صلاحيات الموقع
  Future<bool> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // حالة التتبع الحالية
  bool get isTracking => _isTracking;

  String? get currentOrderId => _currentOrderId;

  @override
  void onClose() {
    stopLocationTracking();
    _socket?.disconnect();
    super.onClose();
  }
}
