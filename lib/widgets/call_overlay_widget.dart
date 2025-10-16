import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/language_service.dart';

class CallOverlayWidget extends StatefulWidget {
  final String callerName;
  final String callerPhone;
  final String? callerAvatar;
  final Map<String, dynamic>? extraData;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onShowDetails;

  const CallOverlayWidget({
    Key? key,
    required this.callerName,
    required this.callerPhone,
    this.callerAvatar,
    this.extraData,
    required this.onAccept,
    required this.onDecline,
    required this.onShowDetails,
  }) : super(key: key);

  @override
  _CallOverlayWidgetState createState() => _CallOverlayWidgetState();
}

class _CallOverlayWidgetState extends State<CallOverlayWidget>
    with TickerProviderStateMixin {
  // ✅ إضافة LanguageService
  final LanguageService _languageService = Get.find<LanguageService>();
  bool get isArabic => _languageService.isArabic;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _logoRotateController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoRotateAnimation;

  @override
  void initState() {
    super.initState();

    // تحريك النبضة
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // تحريك الانزلاق
    _slideController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // تحريك دوران اللوغو
    _logoRotateController = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _logoRotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _logoRotateController,
      curve: Curves.linear,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _logoRotateController.dispose();
    super.dispose();
  }

  // ✅ دالة للحصول على اسم الخدمة حسب اللغة
  String _getServiceName() {
    if (widget.extraData == null) {
      return isArabic ? 'خدمة عامة' : 'General Service';
    }

    // إذا كانت البيانات تحتوي على serviceTitleAr و serviceTitleEn
    if (widget.extraData!.containsKey('serviceTitleAr') && 
        widget.extraData!.containsKey('serviceTitleEn')) {
      return isArabic 
          ? widget.extraData!['serviceTitleAr'] ?? widget.extraData!['serviceTitleEn'] ?? (isArabic ? 'خدمة عامة' : 'General Service')
          : widget.extraData!['serviceTitleEn'] ?? widget.extraData!['serviceTitleAr'] ?? (isArabic ? 'خدمة عامة' : 'General Service');
    }

    // إذا كانت البيانات تحتوي على service_type_ar و service_type_en
    if (widget.extraData!.containsKey('service_type_ar') && 
        widget.extraData!.containsKey('service_type_en')) {
      return isArabic 
          ? widget.extraData!['service_type_ar'] ?? widget.extraData!['service_type_en'] ?? (isArabic ? 'خدمة عامة' : 'General Service')
          : widget.extraData!['service_type_en'] ?? widget.extraData!['service_type_ar'] ?? (isArabic ? 'خدمة عامة' : 'General Service');
    }

    // Fallback للنظام القديم
    if (widget.extraData!.containsKey('service_type')) {
      return widget.extraData!['service_type'];
    }

    return isArabic ? 'خدمة عامة' : 'General Service';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.shade900,
                Colors.red.shade700,
                Colors.red.shade600,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // شريط علوي - ✅ مترجم
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    isArabic ? 'طلب خدمة جديد' : 'New Service Request',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // لوغو خبير ثابت وأنيق
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: Image.asset(
                            'assets/icons/khabir_logo_white.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.build,
                                color: Colors.white,
                                size: 80,
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      // نوع الخدمة المطلوبة - ✅ مترجم
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isArabic ? 'نوع الخدمة المطلوبة' : 'Requested Service Type',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _getServiceName(), // ✅ استخدام الدالة الجديدة
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // رقم الطلب إذا كان متوفراً - ✅ مترجم
                      if (widget.extraData?['order_id'] != null)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isArabic 
                                ? 'رقم الطلب: ${widget.extraData!['order_id']}'
                                : 'Order #: ${widget.extraData!['order_id']}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // نص توضيحي - ✅ مترجم
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    isArabic ? 'هل تريد قبول هذا الطلب؟' : 'Do you want to accept this request?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // أزرار التحكم - ✅ مترجم
                Container(
                  padding: EdgeInsets.all(40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // زر الرفض
                      _buildActionButton(
                        icon: Icons.close,
                        label: isArabic ? 'رفض' : 'Decline',
                        color: Colors.red.shade800,
                        onPressed: widget.onDecline,
                      ),

                      // زر عرض التفاصيل
                      _buildActionButton(
                        icon: Icons.info_outline,
                        label: isArabic ? 'التفاصيل' : 'Details',
                        color: Colors.orange.shade700,
                        onPressed: widget.onShowDetails,
                      ),

                      // زر القبول
                      _buildActionButton(
                        icon: Icons.check,
                        label: isArabic ? 'قبول' : 'Accept',
                        color: Colors.green.shade700,
                        onPressed: widget.onAccept,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}