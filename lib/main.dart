// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:khabir/routes/app_pages.dart';
import 'package:khabir/services/api_service.dart';
import 'package:khabir/services/storage_service.dart';
import 'package:khabir/services/language_service.dart';
import 'package:khabir/translations/AppTranslations.dart';
import 'package:khabir/utils/colors.dart';
import 'bindings/initial_binding.dart';

void main() async {
  // ضمان تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();

  await initServices();

  runApp(MyApp());
}

Future<void> initServices() async {
  print('🔄 Starting services initialization...');

  try {
    // 1. تهيئة خدمة التخزين أولاً والانتظار حتى اكتمالها
    print('📱 Initializing StorageService...');
    final storageService = StorageService();
    await storageService.init();
    Get.put<StorageService>(storageService, permanent: true);
    print('✅ StorageService initialized successfully');

    // انتظار إضافي للتأكد من جاهزية التخزين
    await Future.delayed(Duration(milliseconds: 200));

    // 2. تهيئة خدمة اللغة (تعتمد على خدمة التخزين)
    print('🌍 Initializing LanguageService...');
    final languageService = LanguageService();
    Get.put<LanguageService>(languageService, permanent: true);

    // انتظار تهيئة خدمة اللغة
    await Future.delayed(Duration(milliseconds: 300));

    print('✅ LanguageService initialized successfully');
    print('🎉 All services initialized successfully');

  } catch (e) {
    print('❌ Error initializing services: $e');
    // في حالة الخطأ، تأكد من وجود خدمات افتراضية
    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService(), permanent: true);
    }
    if (!Get.isRegistered<LanguageService>()) {
      Get.put<LanguageService>(LanguageService(), permanent: true);
    }
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

        // إعداد اللغات
        locale: locale,
        fallbackLocale: const Locale('ar', 'SA'),
        translations: AppTranslations(),

        // دعم اللغات المحلية
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],

        // دعم الاتجاهات RTL/LTR
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
          // تأكد من إضافة الخط العربي
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ),
          // إعداد اتجاه النص حسب اللغة
          textTheme: const TextTheme().apply(
            fontFamily: 'Cairo',
          ),
          // إعدادات إضافية للنصوص العربية
          useMaterial3: true,
        ),

        // تحديد الصفحة الأولى
        initialRoute: AppPages.INITIAL,
        // تحديد جميع الصفحات
        getPages: AppPages.routes,
        // ربط الـ Controllers الأساسية
        initialBinding: AppBindings(),
      );

    });
  }
}