import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../services/storage_service.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeOutController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeOutAnimation;
  StorageService? storage;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeStorage() {
    try {
      storage = Get.find<StorageService>();
      print('StorageService found successfully');
    } catch (e) {
      print('StorageService not found: $e');
    }
  }

  void _initializeAnimations() {
    // تحكم في حركة اللوغو
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // تحكم في الاختفاء
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // حركة ظهور وتكبير اللوغو
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    // حركة الاختفاء
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeOutController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _startSplashSequence() async {
    // بدء حركة اللوغو
    await _logoAnimationController.forward();

    // انتظار قليل لعرض اللوغو
    await Future.delayed(const Duration(milliseconds: 800));

    // بدء حركة الاختفاء
    await _fadeOutController.forward();

    // الانتقال للشاشة التالية
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (storage == null) {
      print('Storage is null, going to onboarding');
      _smoothNavigate(AppRoutes.ONBOARDING);
      return;
    }

    try {
      // تحقق من حالة التطبيق
      bool isOnboardingShown = storage!.isOnboardingShown;
      bool isLoggedIn = storage!.isLoggedIn;

      print('Onboarding shown: $isOnboardingShown');
      print('Is logged in: $isLoggedIn');

      String nextRoute;

      if (isLoggedIn) {
        print('Navigating to HOME');
        nextRoute = AppRoutes.HOME;
      } else if (isOnboardingShown) {
        print('Navigating to LOGIN');
        nextRoute = AppRoutes.LOGIN;
      } else {
        print('Navigating to ONBOARDING');
        nextRoute = AppRoutes.ONBOARDING;
      }

      _smoothNavigate(nextRoute);

    } catch (e) {
      print('Error in navigation: $e');
      _smoothNavigate(AppRoutes.ONBOARDING);
    }
  }

  void _smoothNavigate(String route) {
    // الطريقة الصحيحة للانتقال السلس
    Get.offAllNamed(route);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE53E3E),
      body: AnimatedBuilder(
        animation: _fadeOutAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOutAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE53E3E),
                    const Color(0xFFD53030),
                  ],
                ),
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogo(),
                            SizedBox(height: 30),
                            _buildLoadingIndicator(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 160,
      height: 160,
      child: Image.asset(
        'assets/icons/khabir_logo_white.png',
        width: 160,
        height: 160,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildTextLogo();
        },
      ),
    );
  }

  Widget _buildTextLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // النص العربي
          Text(
            'خبير',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE53E3E),
              fontFamily: 'Cairo',
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          // النص الإنجليزي
          Text(
            'KHABIR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE53E3E).withOpacity(0.7),
              fontFamily: AppTextStyles.fontFamily,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 60,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: AnimatedBuilder(
        animation: _logoAnimationController,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                width: 60 * _logoAnimationController.value,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}