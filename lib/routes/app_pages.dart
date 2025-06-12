import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
// import '../views/splash/splash_view.dart';
// import '../views/onboarding/onboarding_view.dart';
import '../bindings/initial_binding.dart';
import '../view/auth/forgot_password_view.dart';
import '../view/auth/login_view.dart';
import '../view/auth/register_view.dart';
import '../view/auth/reset_password_view.dart';
import '../view/auth/verify_account_view.dart';
import '../view/auth/verify_otp_view.dart';
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
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.VERIFY_OTP,
      page: () => VerifyOtpView(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => ResetPasswordView(),
      binding: AuthBinding(),
    ),

    // تأكيد الحساب بعد التسجيل
    GetPage(
      name: AppRoutes.VERIFY_ACCOUNT,
      page: () => VerifyAccountView(),
      binding: AuthBinding(),
    ),


  ];
}