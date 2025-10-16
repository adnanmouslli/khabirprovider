import 'package:get/get.dart';
import 'package:khabir/controllers/AddServiceController.dart';
import 'package:khabir/controllers/IncomeController.dart';
import 'package:khabir/controllers/NotificationsController.dart';
import 'package:khabir/controllers/OffersController.dart';
import 'package:khabir/controllers/ProfileController.dart';
import 'package:khabir/controllers/RequestsController.dart';
import 'package:khabir/view/income/IncomeView.dart';
import 'package:khabir/view/notifications/NotificationsView.dart';
import 'package:khabir/view/offers/OffersView.dart';
import 'package:khabir/view/profile/ProfileView.dart';
import 'package:khabir/view/requests/requestsView.dart';
import 'package:khabir/view/services/AddServiceView.dart';
import 'package:khabir/view/services/ServicesView.dart';
import 'package:khabir/view/update/update_view.dart';
// import '../views/splash/splash_view.dart';
// import '../views/onboarding/onboarding_view.dart';
import '../bindings/initial_binding.dart';
import '../view/auth/forgot_password_view.dart';
import '../view/auth/login_view.dart';
import '../view/auth/register_view.dart';
import '../view/auth/reset_password_view.dart';
import '../view/auth/verify_account_view.dart';
import '../view/home/home_view.dart';
import '../view/onboarding/onboarding_view.dart';
import '../view/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    // صفحة البدء
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashView(),
    ),
    //
    // // صفحات التعريف
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),

    // صفحات المصادقة
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(), // إضافة الـ Binding
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

    ),
    //
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => SignUpView(),
      binding: AuthBinding(),
    ),
    //
    // // الصفحة الرئيسية
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
    ),

    // صفحات نسيان كلمة المرور
    GetPage(
      name: AppRoutes.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
    ),

    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => ResetPasswordView(),
    ),

    // تأكيد الحساب بعد التسجيل
    GetPage(
      name: AppRoutes.VERIFY_ACCOUNT,
      page: () => VerifyAccountView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.SERVICES,
      page: () => ServicesView(),
    ),

    GetPage(
      name: AppRoutes.ADD_SERVICE,
      page: () => AddServiceView(),
      binding: BindingsBuilder(() {
        Get.put(AddServiceController());
      }),
    ),

    GetPage(
      name: AppRoutes.OFFERS,
      page: () => OffersView(),
      binding: BindingsBuilder(() {
        Get.put(OffersController());
      }),
    ),

    GetPage(
      name: AppRoutes.REQUESTS,
      page: () => RequestsView(),
      binding: BindingsBuilder(() {
        Get.put(RequestsController());
      }),
    ),

    GetPage(
      name: AppRoutes.INCOME,
      page: () => IncomeView(),
      binding: BindingsBuilder(() {
        Get.put(IncomeController());
      }),
    ),

    GetPage(
      name: AppRoutes.PROFILE,
      page: () => ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),

    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => NotificationsView(),
      binding: BindingsBuilder(() {
        Get.put(NotificationsController());
      }),
    ),

    GetPage(
      name: AppRoutes.UPDATE,
      page: () => UpdateView(),
    ),
  ];
}
