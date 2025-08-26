// main.dart - Fixed version with better error handling and retry logic
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:khabir/controllers/auth_controller.dart';
import 'package:khabir/routes/app_pages.dart';
import 'package:khabir/services/LocationTrackingService.dart';
import 'package:khabir/services/auth_service.dart';
import 'package:khabir/services/storage_service.dart';
import 'package:khabir/services/language_service.dart';
import 'package:khabir/translations/AppTranslations.dart';
import 'package:khabir/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bindings/initial_binding.dart';
import 'dart:io';

void main() async {
  // ضمان تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // تهيئة الخدمات و Firebase بشكل متتالي
    await initServices();
    await _initializeFirebase();

    // انتظار قصير للتأكد من جاهزية Firebase
    await Future.delayed(Duration(milliseconds: 500));

    await _initFCMToken();

    runApp(MyApp());

    // طلب الإذونات بعد تشغيل التطبيق
    _requestNotificationPermissionAsync();

    _setupFCMListeners();
    _checkInitialMessage();

  } catch (e) {
    print('❌ Error in main: $e');
    // تشغيل التطبيق حتى لو فشل FCM
    runApp(MyApp());
  }
}

// 🔹 Firebase Android Options
const FirebaseOptions androidFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDHO1IFaUDdDK9RTUxqxX6KP2P9v7jbfNA',
  appId: '1:387321964868:android:f8f3cb3a99acc24f130f11',
  messagingSenderId: '387321964868',
  projectId: 'khabir-e3989',
  storageBucket: 'khabir-e3989.firebasestorage.app',
);

// 🔹 Firebase iOS Options
const FirebaseOptions _iosFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAtedhIkmx8hKX7wlncrkY8aIBqjWY-b4c',
  appId: '1:981857863200:ios:f92db5901145d4e3f0de45',
  messagingSenderId: '981857863200',
  projectId: 'radar-2447e',
  storageBucket: 'radar-2447e.firebasestorage.app',
  iosBundleId: 'com.anycode.radar',
);

// 🔹 تهيئة Firebase
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: _getFirebaseOptions(),
    );
    print('✅ Firebase initialized successfully');

    // انتظار إضافي للتأكد من جاهزية الخدمة
    await Future.delayed(Duration(milliseconds: 300));

  } catch (e) {
    print('❌ Error initializing Firebase: $e');
    rethrow;
  }
}

// 🔹 تحديد إعدادات Firebase حسب المنصة
FirebaseOptions _getFirebaseOptions() {
  if (Platform.isAndroid) {
    return androidFirebaseOptions;
  } else if (Platform.isIOS) {
    return _iosFirebaseOptions;
  } else {
    throw UnsupportedError('Platform not supported');
  }
}

// 🔹 إعداد مستمعي FCM
void _setupFCMListeners() {
  try {
    // الاستماع لتحديث التوكن
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('🔄 FCM Token refreshed: $newToken');
      final storageService = Get.find<StorageService>();
      await storageService.setFCMToken(newToken);

      // إعادة محاولة الاشتراك بالتوبيك مع تأخير
      Future.delayed(Duration(seconds: 2), () {
        _subscribeToProvidersTopicWithRetry();
      });
    });

    // الاستماع للرسائل في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Received message in foreground: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // الاستماع للرسائل عند النقر عليها
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Message clicked: ${message.notification?.title}');
      Future.delayed(Duration(milliseconds: 1000), () {
        _handleMessageClick(message);
      });
    });

    // تعيين معالج رسائل الخلفية
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  } catch (e) {
    print('❌ Error setting up FCM listeners: $e');
  }
}

// 🔹 طلب إذن الإشعارات بعد التأخير
void _requestNotificationPermissionAsync() {
  Future.delayed(const Duration(seconds: 1), () {
    _requestNotificationPermission();
  });
}

// 🔹 طلب إذن الإشعارات مع معالجة أفضل للأخطاء
Future<void> _requestNotificationPermission() async {
  try {
    bool permissionGranted = false;

    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('iOS Notification permission: ${settings.authorizationStatus}');
      permissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized;

    } else if (Platform.isAndroid) {
      PermissionStatus status = await Permission.notification.request();
      print('Android Notification permission: $status');
      permissionGranted = status == PermissionStatus.granted;
    }

    if (permissionGranted) {
      // انتظار قبل محاولة الاشتراك
      Future.delayed(Duration(seconds: 2), () {
        _subscribeToProvidersTopicWithRetry();
      });
    }

  } catch (e) {
    print('❌ Error requesting notification permission: $e');
  }
}

// 🔹 الاشتراك في توبيك مقدمي الخدمات مع إعادة المحاولة
Future<void> _subscribeToProvidersTopicWithRetry({int maxRetries = 3}) async {
  const String topicName = 'channel_providers';

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      print('🔄 Attempting to subscribe to topic: $topicName (Attempt $attempt/$maxRetries)');

      await FirebaseMessaging.instance.subscribeToTopic(topicName);
      print('✅ Successfully subscribed to topic: $topicName');

      // حفظ معلومات الاشتراك
      final storageService = Get.find<StorageService>();
      await storageService.write('subscribed_to_providers_topic', true);

      return; // نجح الاشتراك، اخرج من الدالة

    } catch (e) {
      print('❌ Error subscribing to topic (Attempt $attempt): $e');

      if (attempt < maxRetries) {
        // انتظار متزايد بين المحاولات
        int waitTime = attempt * 2;
        print('⏳ Waiting ${waitTime}s before retry...');
        await Future.delayed(Duration(seconds: waitTime));
      }
    }
  }

  print('💥 Failed to subscribe to topic after $maxRetries attempts');
}

// 🔹 إلغاء الاشتراك من توبيك مقدمي الخدمات
Future<void> _unsubscribeFromProvidersTopic() async {
  try {
    const String topicName = 'channel_providers';
    await FirebaseMessaging.instance.unsubscribeFromTopic(topicName);
    print('✅ Successfully unsubscribed from topic: $topicName');

    final storageService = Get.find<StorageService>();
    await storageService.write('subscribed_to_providers_topic', false);

  } catch (e) {
    print('❌ Error unsubscribing from providers topic: $e');
  }
}

// 🔹 معالج الرسائل في المقدمة
void _handleForegroundMessage(RemoteMessage message) {
  final notification = message.notification;
  final data = message.data;

  if (notification != null) {
    Get.snackbar(
      notification.title ?? 'إشعار جديد',
      notification.body ?? 'لديك رسالة جديدة',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      onTap: (_) => _handleMessageClick(message),
    );
  }

  print('📱 Foreground message data: $data');
}

// 🔹 معالج النقر على الرسائل
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
    Get.toNamed('/order-details', arguments: data['order_id']);
  }
}

// 🔹 معالج رسائل الخلفية
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: _getFirebaseOptions());
    print('📩 Handling background message: ${message.messageId}');
    print('📩 Message data: ${message.data}');
    print('📩 Notification: ${message.notification?.title} - ${message.notification?.body}');
  } catch (e) {
    print('❌ Error in background handler: $e');
  }
}

// 🔹 تهيئة FCM Token مع معالجة أفضل
Future<void> _initFCMToken() async {
  try {
    // التأكد من أن Firebase جاهز
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

// 🔹 تهيئة الخدمات
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
  }
}

// 🔹 التحقق من الرسالة الأولية
Future<void> _checkInitialMessage() async {
  try {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('🔔 App opened from terminated state via notification');
      print('🔔 Initial message data: ${initialMessage.data}');

      Future.delayed(Duration(milliseconds: 2000), () {
        _handleMessageClick(initialMessage);
      });
    }
  } catch (e) {
    print('❌ Error checking initial message: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LanguageService languageService = Get.find<LanguageService>();

    return Obx(() {
      final locale = languageService.currentLocale.value;

      return GetMaterialApp(
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
      );
    });
  }
}