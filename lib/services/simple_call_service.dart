import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:khabir/routes/app_routes.dart';
import 'package:khabir/widgets/call_overlay_widget.dart';
import 'package:overlay_support/overlay_support.dart';
import 'dart:io';

import 'package:khabir/services/orders_service.dart';

class SimpleCallService extends GetxController {
  static SimpleCallService get instance => Get.find<SimpleCallService>();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  OverlaySupportEntry? _overlayEntry;

  final OrdersService _ordersService = OrdersService();
  
  // عرض واجهة المكالمة مع دعم الوظائف المخصصة
  void showCallOverlay({
    required String callerName,
    required String callerPhone,
    String? callerAvatar,
    Map<String, dynamic>? extraData,
    Function()? onAccept,
    Function()? onDecline,
    Function()? onShowDetails,
    Function()? onAcceptCustom,    // وظيفة مخصصة للقبول
    Function()? onDeclineCustom,   // وظيفة مخصصة للرفض
  }) async {
    // بدء تشغيل نغمة الرنين
    _playRingtone();
    
    // إظهار الواجهة العائمة
    _overlayEntry = showOverlay(
      (context, t) => CallOverlayWidget(
        callerName: callerName,
        callerPhone: callerPhone,
        callerAvatar: callerAvatar,
        extraData: extraData,
        onAccept: onAcceptCustom ?? onAccept ?? () => _onAcceptCall(extraData),
        onDecline: onDeclineCustom ?? onDecline ?? () => _onDeclineCall(extraData),
        onShowDetails: onShowDetails ?? () => _onShowDetails(extraData),
      ),
      duration: Duration.zero, // لا تختفي تلقائياً
    );
  }
  
  // تشغيل نغمة الرنين
  void _playRingtone() async {
    try {
      if (Platform.isAndroid) {
        await _audioPlayer.play(AssetSource('sounds/ella.mp3'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer.play(AssetSource('sounds/ella.mp3'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      }
      await _audioPlayer.setVolume(1.0);
    } catch (e) {
      print('❌ Error playing ringtone: $e');
    }
  }
  
  // إيقاف نغمة الرنين
  void _stopRingtone() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('❌ Error stopping ringtone: $e');
    }
  }
  
  // إخفاء واجهة المكالمة - الطريقة العامة
  void hideOverlay() {
    _hideCallOverlay();
  }
  
  // إخفاء واجهة المكالمة - الطريقة الداخلية
  void _hideCallOverlay() {
    _stopRingtone();
    _overlayEntry?.dismiss();
    _overlayEntry = null;
  }
  
  // عند قبول المكالمة (الوظيفة الافتراضية)
  Future<void> _onAcceptCall(Map<String, dynamic>? extraData) async {
    _hideCallOverlay();

    try {
      if (extraData?['order_id'] != null) {
        final orderId = int.tryParse(extraData!['order_id'].toString());
        if (orderId != null) {
          await _ordersService.acceptOrder(orderId);
          Get.snackbar(
            'تم قبول الطلب',
            'تم قبول الطلب بنجاح (ID: $orderId)',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // التوجه لصفحة تفاصيل الطلب
          Get.toNamed(AppRoutes.NOTIFICATIONS, arguments: orderId);
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في قبول الطلب: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // عند رفض المكالمة (الوظيفة الافتراضية)
  Future<void> _onDeclineCall(Map<String, dynamic>? extraData) async {
    _hideCallOverlay();

    try {
      if (extraData?['order_id'] != null) {
        final orderId = int.tryParse(extraData!['order_id'].toString());
        if (orderId != null) {
          await _ordersService.cancelOrder(orderId);
          Get.snackbar(
            'تم رفض الطلب',
            'تم رفض الطلب (ID: $orderId)',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في رفض الطلب: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // عند الضغط على عرض التفاصيل (الوظيفة الافتراضية)
  void _onShowDetails(Map<String, dynamic>? extraData) {
    _hideCallOverlay();
    
    if (extraData?['order_id'] != null) {
      Get.toNamed(AppRoutes.NOTIFICATIONS, arguments: extraData!['order_id']);
    } else {
      Get.toNamed(AppRoutes.HOME);
    }
  }

  // التحقق من حالة المكالمة
  bool get isCallActive => _overlayEntry != null;
}