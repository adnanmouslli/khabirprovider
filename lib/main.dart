import 'dart:convert';
import 'dart:core';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:khabir/routes/app_routes.dart';
import 'package:khabir/services/orders_service.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:khabir/controllers/auth_controller.dart';
import 'package:khabir/routes/app_pages.dart';
import 'package:khabir/services/LocationTrackingService.dart';
import 'package:khabir/services/auth_service.dart';
import 'package:khabir/services/storage_service.dart';
import 'package:khabir/services/language_service.dart';
import 'package:khabir/services/simple_call_service.dart';
import 'package:khabir/translations/AppTranslations.dart';
import 'package:khabir/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bindings/initial_binding.dart';
import 'dart:io';

// إضافة MethodChannel للتواصل مع Native
const MethodChannel _methodChannel =
    MethodChannel('com.akwan.khabirprovider_new/notifications');

// متغير لتتبع حالة التطبيق - مهم جداً
bool _isAppInForeground = false;
late AppLifecycleObserver _lifecycleObserver;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initServices();
    await _initializeFirebase();
    await Future.delayed(Duration(milliseconds: 500));
    await _initFCMToken();
    await _setupMethodChannelHandlers();

    runApp(MyApp());

    _requestNotificationPermissionAsync();
    _setupFCMListeners();
    _checkInitialMessage();
    _setupAppLifecycleObserver();
  } catch (e) {
    print('❌ Error in main: $e');
    runApp(MyApp());
  }
}

// إعداد مراقب دورة حياة التطبيق
void _setupAppLifecycleObserver() {
  _lifecycleObserver = AppLifecycleObserver();
  WidgetsBinding.instance.addObserver(_lifecycleObserver);

  // تحديد الحالة الأولية
  _isAppInForeground = true;
  _notifyNativeOfAppState(true);
}

// إشعار النايتف بحالة التطبيق
Future<void> _notifyNativeOfAppState(bool isInForeground) async {
  try {
    // لا نحتاج لإرسال للنايتف لأن النايتف يتحقق بنفسه
    print('📱 App state: ${isInForeground ? "Foreground" : "Background"}');
  } catch (e) {
    print('❌ Error notifying native: $e');
  }
}

// مراقب دورة حياة التطبيق
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        print('🟢 App resumed - in foreground');
        _notifyNativeOfAppState(true);
        _cancelNativeNotifications();
        break;
      case AppLifecycleState.paused:
        _isAppInForeground = false;
        print('🔴 App paused - in background');
        _notifyNativeOfAppState(false);
        break;
      case AppLifecycleState.inactive:
        _isAppInForeground = false;
        print('🟡 App inactive - in background');
        _notifyNativeOfAppState(false);
        break;
      case AppLifecycleState.detached:
        _isAppInForeground = false;
        print('⚫ App detached - in background');
        _notifyNativeOfAppState(false);
        break;
      case AppLifecycleState.hidden:
        _isAppInForeground = false;
        print('⚫ App hidden - in background');
        _notifyNativeOfAppState(false);
        break;
    }
  }
}

// إلغاء الإشعارات النايتف
Future<void> _cancelNativeNotifications() async {
  try {
    await _methodChannel.invokeMethod('cancelCallNotification');
    print('✅ Native notifications cancelled');
  } catch (e) {
    print('❌ Error cancelling native notifications: $e');
  }
}

// إعداد معالجات MethodChannel
Future<void> _setupMethodChannelHandlers() async {
  _methodChannel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'onCallAccepted':
        final callerName = call.arguments['caller_name'] as String?;
        final orderId = call.arguments['order_id'] as String?;
        await _handleCallAcceptedFromNotification(callerName, orderId);
        break;

      case 'navigateToOrderDetails':
        final orderId = call.arguments['order_id'] as String?;
        if (orderId != null) {
          Get.toNamed(AppRoutes.NOTIFICATIONS, arguments: orderId);
        }
        break;

      case 'navigateToNotifications':
        final orderId = call.arguments['order_id'] as String?;
        Get.toNamed(AppRoutes.NOTIFICATIONS, arguments: orderId);
        break;

      case 'acceptOrder':
        final orderId = call.arguments['order_id'] as String?;
        await _acceptOrderFromForeground(orderId);
        break;

      case 'onCallDeclined':
        final orderId = call.arguments['order_id'] as String?;
        if (orderId != null) {
          Get.snackbar(
            'تم رفض الطلب',
            'تم رفض الطلب رقم: $orderId',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          Get.toNamed(AppRoutes.NOTIFICATIONS);
        }
        break;

      case 'declineOrder':
        final orderId = call.arguments['order_id'] as String?;
        await _declineOrderFromForeground(orderId);
        break;
    }
  });
}

// معالجة قبول المكالمة من الإشعار الخلفي
Future<void> _handleCallAcceptedFromNotification(
    String? callerName, String? orderId) async {
  print('📞 Call accepted from background notification');
  print('👤 Caller: $callerName, Order ID: $orderId');

  try {
    if (orderId != null) {
      final ordersService = OrdersService();
      final orderIdInt = int.tryParse(orderId);

      if (orderIdInt != null) {
        await ordersService.acceptOrder(orderIdInt);

        Get.snackbar(
          'تم قبول المكالمة',
          'تم قبول الطلب من $callerName بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        Get.toNamed(AppRoutes.NOTIFICATIONS, arguments: orderId);
      }
    }
  } catch (e) {
    print('❌ Error handling call acceptance: $e');
    Get.snackbar(
      'خطأ',
      'فشل في قبول الطلب: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

// معالجة قبول الطلب من الإشعار الأمامي
Future<void> _acceptOrderFromForeground(String? orderId) async {
  print('📞 Accepting order from foreground notification');

  try {
    if (orderId != null) {
      final ordersService = OrdersService();
      final orderIdInt = int.tryParse(orderId);

      if (orderIdInt != null) {
        await ordersService.acceptOrder(orderIdInt);

        Get.snackbar(
          'تم قبول الطلب',
          'تم قبول الطلب بنجاح (ID: $orderIdInt)',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.toNamed('/order-details', arguments: orderIdInt);
      }
    }
  } catch (e) {
    print('❌ Error accepting order: $e');
    Get.snackbar(
      'خطأ',
      'فشل في قبول الطلب: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

// معالجة رفض الطلب من الإشعار الأمامي
Future<void> _declineOrderFromForeground(String? orderId) async {
  print('📞 Declining order from foreground notification');

  try {
    if (orderId != null) {
      final ordersService = OrdersService();
      final orderIdInt = int.tryParse(orderId);

      if (orderIdInt != null) {
        await ordersService.cancelOrder(orderIdInt);

        Get.snackbar(
          'تم رفض الطلب',
          'تم رفض الطلب (ID: $orderIdInt)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  } catch (e) {
    print('❌ Error declining order: $e');
    Get.snackbar(
      'خطأ',
      'فشل في رفض الطلب: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

// Firebase Options
const FirebaseOptions androidFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDHO1IFaUDdDK9RTUxqxX6KP2P9v7jbfNA',
  appId: '1:387321964868:android:f8f3cb3a99acc24f130f11',
  messagingSenderId: '387321964868',
  projectId: 'khabir-e3989',
  storageBucket: 'khabir-e3989.firebasestorage.app',
);

const FirebaseOptions _iosFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAtedhIkmx8hKX7wlncrkY8aIBqjWY-b4c',
  appId: '1:981857863200:ios:f92db5901145d4e3f0de45',
  messagingSenderId: '981857863200',
  projectId: 'radar-2447e',
  storageBucket: 'radar-2447e.firebasestorage.app',
  iosBundleId: 'com.anycode.radar',
);

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(options: _getFirebaseOptions());
    print('✅ Firebase initialized successfully');
    await Future.delayed(Duration(milliseconds: 300));
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
    rethrow;
  }
}

FirebaseOptions _getFirebaseOptions() {
  if (Platform.isAndroid) {
    return androidFirebaseOptions;
  } else if (Platform.isIOS) {
    return _iosFirebaseOptions;
  } else {
    throw UnsupportedError('Platform not supported');
  }
}

void _setupFCMListeners() {
  try {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('🔄 FCM Token refreshed: $newToken');
      final storageService = Get.find<StorageService>();
      await storageService.setFCMToken(newToken);

      if (storageService.isLoggedIn) {
        print('✅ User is logged in, subscribing to topics...');
        Future.delayed(Duration(seconds: 2), () {
          _subscribeToProvidersTopicWithRetry();
        });
      } else {
        print('⚠️ User not logged in, skipping topic subscription');
      }
    });

    // معالجة الرسائل في المقدمة - هنا التحسين الرئيسي
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          '📱 Received message in foreground: ${message.notification?.title}');
      print('🟢 App is in foreground: $_isAppInForeground');

      // فقط إظهار إشعار Flutter إذا كان التطبيق في المقدمة
      if (_isAppInForeground) {
        _handleForegroundMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Message clicked: ${message.notification?.title}');
      Future.delayed(Duration(milliseconds: 1000), () {
        _handleMessageClick(message);
      });
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('❌ Error setting up FCM listeners: $e');
  }
}

void _handleForegroundMessage(RemoteMessage message) {
  final notification = message.notification;
  final data = message.data;

  print('📱 Handling foreground message');
  print('📱 App state: $_isAppInForeground');
  print('📱 Received FCM data: $data');
  print('📱 Notification: ${notification?.title}');

  // التحقق مرة أخرى من حالة التطبيق
  if (!_isAppInForeground) {
    print('⚠️ App not in foreground, skipping Flutter notification');
    return;
  }

  bool isCallMessage = _isCallMessage(data);

  if (isCallMessage) {
    print('📞 This is a call message - showing Flutter call overlay only');
    _showSimpleCall(data);
    return;
  }

  // للرسائل العادية، التحقق من وجود صورة
  String? imageUrl = data['imageUrl'] ?? data['image_url'] ?? data['image'];

  if (notification != null) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // إشعار مع صورة

      imageUrl = fixImageUrl(imageUrl);

      print('🖼️ Notification has image: $imageUrl');
      _showNotificationWithImage(
        title: notification.title ?? 'إشعار',
        body: notification.body ?? '',
        imageUrl: imageUrl,
      );
    } else {
      // إشعار عادي بدون صورة
      Get.snackbar(
        notification.title ?? 'إشعار',
        notification.body ?? '',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}

String fixImageUrl(String url) {
  const String serverIp = '31.97.71.187';
  const String serverPort = '3000';

  // استبدال localhost:3001 بـ IP السيرفر
  if (url.contains('localhost:3001')) {
    return url.replaceAll('localhost:3001', '$serverIp:$serverPort');
  }

  // استبدال localhost بـ IP السيرفر (أي port)
  if (url.contains('localhost')) {
    return url.replaceAll(RegExp(r'localhost(:\d+)?'), '$serverIp:$serverPort');
  }

  // استبدال 127.0.0.1 بـ IP السيرفر
  if (url.contains('127.0.0.1')) {
    return url.replaceAll(
        RegExp(r'127\.0\.0\.1(:\d+)?'), '$serverIp:$serverPort');
  }

  // إذا كان الرابط نسبي (يبدأ بـ /uploads)
  if (url.startsWith('/uploads')) {
    return 'http://$serverIp:$serverPort$url';
  }

  // الرابط صحيح بالفعل
  return url;
}

// دالة جديدة لعرض إشعار مع صورة في Flutter
void _showNotificationWithImage({
  required String title,
  required String body,
  required String imageUrl,
}) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الصورة
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            // العنوان والمحتوى
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),

                  // زر الإغلاق
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'حسناً',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );

  // إغلاق تلقائي بعد 10 ثواني
  Future.delayed(Duration(seconds: 10), () {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  });
}

// إظهار واجهة المكالمة المُصححة للإشعارات الأمامية
void _showSimpleCall(Map<String, dynamic> data) {
  print('📞 Showing service request overlay with data: $data');
  print('🟢 Current app state: $_isAppInForeground');

  if (!_isAppInForeground) {
    print('⚠️ App not in foreground, not showing request overlay');
    return;
  }

  try {
    final callService = SimpleCallService.instance;

    // إخفاء معلومات العميل - فقط إظهار نوع الخدمة
    String serviceType = data['service_type'] ??
        data['serviceType'] ??
        data['service'] ??
        'خدمة عامة';

    String orderId = data['order_id'] ??
        data['orderId'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> extraData = {
      'call_id': data['call_id'] ??
          data['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      'order_id': orderId,
      'service_type': serviceType,
      'provider_id': data['provider_id'] ?? data['providerId'],
      'message_id': data['message_id'],
      'call_timestamp':
          data['call_timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      'call_source': data.containsKey('call_timestamp') ? 'saved' : 'live',
    };

    // إظهار الـ overlay بدون معلومات العميل
    callService.showCallOverlay(
      callerName: 'عميل جديد', // اسم عام بدلاً من الاسم الحقيقي
      callerPhone: '', // إخفاء رقم الهاتف
      callerAvatar: null, // إخفاء الصورة
      extraData: extraData,
      onAcceptCustom: () async {
        callService.hideOverlay();
        await _acceptOrderFromForeground(orderId);
      },
      onDeclineCustom: () async {
        callService.hideOverlay();
        await _declineOrderFromForeground(orderId);
      },
    );

    print('✅ Service request overlay shown successfully for order: $orderId');
  } catch (e) {
    print('❌ Error showing request overlay: $e');

    // fallback snackbar مُحدث
    Get.snackbar(
      'طلب خدمة جديد',
      'لديك طلب خدمة جديد', // بدون ذكر اسم العميل
      backgroundColor: Colors.blue, // تغيير اللون من الأخضر
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      onTap: (_) {
        if (data['order_id'] != null) {
          Get.toNamed('/order-details', arguments: data['order_id']);
        }
      },
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    print('📩 Handling background message: ${message.messageId}');
    print('📩 Message data: ${message.data}');

    final data = message.data;

    bool isCallMessage = data.containsKey('type') && data['type'] == 'call' ||
        data.containsKey('call_type') ||
        data.containsKey('caller_name');

    if (isCallMessage) {
      print(
          '📞 Background call received - Native notification should handle this');
    }
  } catch (e) {
    print('❌ Error in background handler: $e');
  }
}

void _requestNotificationPermissionAsync() {
  Future.delayed(const Duration(seconds: 1), () {
    _requestNotificationPermission();
  });
}

Future<void> _requestNotificationPermission() async {
  try {
    bool permissionGranted = false;

    if (Platform.isIOS) {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('iOS Notification permission: ${settings.authorizationStatus}');
      permissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    } else if (Platform.isAndroid) {
      PermissionStatus status = await Permission.notification.request();
      print('Android Notification permission: $status');
      permissionGranted = status == PermissionStatus.granted;
    }

    if (permissionGranted) {
      final storageService = Get.find<StorageService>();
      if (storageService.isLoggedIn) {
        print('✅ User is logged in, subscribing to topics...');
        Future.delayed(Duration(seconds: 2), () {
          _subscribeToProvidersTopicWithRetry();
        });
      } else {
        print('⚠️ User not logged in, skipping topic subscription');
      }
    }
  } catch (e) {
    print('❌ Error requesting notification permission: $e');
  }
}

Future<void> _subscribeToProvidersTopicWithRetry({int maxRetries = 3}) async {
  const String topicName = 'channel_providers';

  try {
    final storageService = Get.find<StorageService>();
    if (!storageService.isLoggedIn) {
      print('⚠️ User not logged in, cancelling topic subscription');
      return;
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print(
            '🔄 Attempting to subscribe to topic: $topicName (Attempt $attempt/$maxRetries)');
        await FirebaseMessaging.instance.subscribeToTopic(topicName);
        print('✅ Successfully subscribed to topic: $topicName');

        await storageService.write('subscribed_to_providers_topic', true);
        return;
      } catch (e) {
        print('❌ Error subscribing to topic (Attempt $attempt): $e');
        if (attempt < maxRetries) {
          int waitTime = attempt * 2;
          print('⏳ Waiting ${waitTime}s before retry...');
          await Future.delayed(Duration(seconds: waitTime));
        }
      }
    }
    print('💥 Failed to subscribe to topic after $maxRetries attempts');
  } catch (e) {
    print('❌ Error in topic subscription process: $e');
  }
}

void _handleMessageClick(RemoteMessage message) {
  final data = message.data;
  print('🔔 Message clicked with data: $data');

  if (data.containsKey('screen')) {
    final screen = data['screen'];
    switch (screen) {
      case 'orders':
        Get.toNamed('/orders');
        break;
      case 'profile':
        Get.toNamed('/profile');
        break;
      case 'notifications':
        Get.toNamed('/notifications');
        break;
      default:
        Get.toNamed('/home');
    }
  } else if (data.containsKey('order_id')) {
    Get.toNamed(AppRoutes.NOTIFICATIONS, arguments: data['order_id']);
  }
}

Future<void> _initFCMToken() async {
  try {
    await Future.delayed(Duration(milliseconds: 500));
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print('📲 FCM Token: $token');
      final storageService = Get.find<StorageService>();
      await storageService.setFCMToken(token);
      print('✅ FCM Token saved successfully');
    } else {
      print('⚠️ FCM Token is null');
    }
  } catch (e) {
    print('❌ Error getting FCM token: $e');
  }
}

Future<void> initServices() async {
  print('🔄 Starting services initialization...');

  try {
    print('📱 Initializing StorageService...');
    final storageService = StorageService();
    await storageService.init();
    Get.put<StorageService>(storageService, permanent: true);
    print('✅ StorageService initialized successfully');

    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.put(LocationTrackingService(), permanent: true);

    print('📞 Initializing SimpleCallService...');
    Get.put<SimpleCallService>(SimpleCallService(), permanent: true);
    print('✅ SimpleCallService initialized successfully');

    await Future.delayed(Duration(milliseconds: 200));

    print('🌍 Initializing LanguageService...');
    final languageService = LanguageService();
    Get.put<LanguageService>(languageService, permanent: true);

    await Future.delayed(Duration(milliseconds: 300));
    print('✅ LanguageService initialized successfully');
    print('🎉 All services initialized successfully');
  } catch (e) {
    print('❌ Error initializing services: $e');

    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService(), permanent: true);
    }
    if (!Get.isRegistered<LanguageService>()) {
      Get.put<LanguageService>(LanguageService(), permanent: true);
    }
    if (!Get.isRegistered<SimpleCallService>()) {
      Get.put<SimpleCallService>(SimpleCallService(), permanent: true);
    }
  }
}

Future<void> _checkInitialMessage() async {
  try {
    print('🔍 Checking for initial messages and pending calls...');

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('🔔 App opened from terminated state via notification');
      print('🔔 Initial message data: ${initialMessage.data}');

      final data = initialMessage.data;
      if (_isCallMessage(data)) {
        print('📞 Initial message is a call - showing immediately');
        Future.delayed(Duration(milliseconds: 1000), () {
          _showSimpleCall(data);
        });
        return;
      } else {
        Future.delayed(Duration(milliseconds: 2000), () {
          _handleMessageClick(initialMessage);
        });
      }
    }
  } catch (e) {
    print('❌ Error checking initial message: $e');
  }
}

bool _isCallMessage(Map<String, dynamic> data) {
  if (data.containsKey('type') && data['type'] == 'call') {
    return true;
  }
  return false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();

    return Obx(() {
      final locale = languageService.currentLocale.value;

      return OverlaySupport.global(
        child: GetMaterialApp(
          title: 'خدمات',
          debugShowCheckedModeBanner: false,
          locale: locale,
          fallbackLocale: const Locale('ar', 'SA'),
          translations: AppTranslations(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: Get.locale?.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Cairo',
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
            ),
            textTheme: const TextTheme().apply(
              fontFamily: 'Cairo',
            ),
            useMaterial3: true,
          ),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          initialBinding: AppBindings(),
        ),
      );
    });
  }
}
