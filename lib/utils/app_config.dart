class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://31.97.71.187:3000/api';
  static const String socketUrl = 'wss://your-backend-url.com';
  static const String fileUrl = 'http://31.97.71.187:3000';

  static const String imageBaseUrl = 'http://31.97.71.187:3000';


  static const String supportWhatsAppNumber = '+963999999999';

  // App Information
  static const String appName = 'Khabir';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.khabir.app';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String userTypeKey = 'user_type';
  static const String isLoggedInKey = 'is_logged_in';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultUserType = 'PROVIDER';
  
  // OTP Configuration
  static const int otpLength = 4;
  static const int otpTimeoutSeconds = 60;
  static const int accountVerificationTimeoutSeconds = 120;
  
  // File Upload Configuration
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // Phone Number Configuration
  static const String syriaCountryCode = '+963';
  static const String saudiCountryCode = '+966';
  static const String defaultCountryCode = syriaCountryCode;
  
  // API Timeouts
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;
  
  // Image Configuration
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 80;
  
  // Development Flags
  static const bool isDevelopment = true;
  static const bool enableLogging = true;
  static const bool bypassOTP = true; // For development only
  
  // Error Messages
  static const String networkErrorMessage = 'لا يوجد اتصال بالإنترنت';
  static const String timeoutErrorMessage = 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
  static const String serverErrorMessage = 'خطأ في الخادم، يرجى المحاولة لاحقاً';
  static const String unknownErrorMessage = 'حدث خطأ غير متوقع';
  
  // Success Messages
  static const String loginSuccessMessage = 'تم تسجيل الدخول بنجاح';
  static const String registerSuccessMessage = 'تم إنشاء الحساب بنجاح';
  static const String logoutSuccessMessage = 'تم تسجيل الخروج بنجاح';
  static const String passwordResetSuccessMessage = 'تم تغيير كلمة المرور بنجاح';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int maxDescriptionLength = 500;
}
