import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/home_controller.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // الخدمات الأساسية - بدون async في Bindings
    // StorageService سيكون مُهيأ مسبقاً في main()

    // التأكد من وجود StorageService
    if (!Get.isRegistered<StorageService>()) {
      throw Exception('StorageService must be initialized in main() before using AppBindings');
    }

    // تسجيل ApiService
    Get.put<ApiService>(ApiService(), permanent: true);

    // المتحكمات الأساسية
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    // Get.lazyPut<OnboardingController>(() => OnboardingController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}

// Binding منفصل للصفحات التي تحتاج AuthController فقط
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

// Binding منفصل لصفحة الـ Onboarding
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}

// Binding منفصل للصفحة الرئيسية
// class HomeBinding extends Bindings {
// //   @override
// //   void dependencies() {
// //     Get.lazyPut<HomeController>(() => HomeController());
// //   }
// // }