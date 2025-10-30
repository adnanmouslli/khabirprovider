// // test_call_screen.dart - صفحة اختبار المكالمات
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:khabir/services/simple_call_service.dart';

// class TestCallScreen extends StatelessWidget {


//   void _testNativeCallNotification() {
//   print('🧪 Testing native call notification');
  
//   try {
//     NativeNotificationService.showNativeCallNotification(
//       callerName: 'أحمد محمد (Native)',
//       callerPhone: '+966501234567',
//       callData: {
//         'order_id': 'NATIVE_TEST_123',
//         'service_type': 'سباكة',
//         'provider_id': 'PRV_NATIVE',
//         'test_mode': true,
//       },
//     );
    
//     Get.snackbar(
//       'تم إرسال الاختبار',
//       'تحقق من شريط الإشعارات',
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       duration: Duration(seconds: 3),
//     );
    
//   } catch (e) {
//     Get.snackbar(
//       'خطأ في الاختبار',
//       'تأكد من إعداد Native Service: $e',
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }
// }

// // اختبار إشعار عادي
// void _testNativeGeneralNotification() {
//   print('🧪 Testing native general notification');
  
//   try {
//     NativeNotificationService.showNativeGeneralNotification(
//       title: 'إشعار اختبار',
//       body: 'هذا إشعار اختبار من النظام الأصلي',
//       data: {
//         'test': true,
//         'type': 'general_test',
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       },
//     );
    
//     Get.snackbar(
//       'تم إرسال الإشعار',
//       'تحقق من شريط الإشعارات',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//       duration: Duration(seconds: 3),
//     );
    
//   } catch (e) {
//     Get.snackbar(
//       'خطأ في الاختبار',
//       'تأكد من إعداد Native Service: $e',
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('اختبار المكالمات'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             SizedBox(height: 20),
            
//             Text(
//               'اختبار نظام المكالمات',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
            
//             SizedBox(height: 30),
            
//             // زر اختبار مكالمة عادية
//             ElevatedButton.icon(
//               onPressed: () => _testNormalCall(),
//               icon: Icon(Icons.call, color: Colors.white),
//               label: Text(
//                 'اختبار مكالمة عادية',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
            
//             SizedBox(height: 15),
            
//             // زر اختبار مكالمة مع بيانات إضافية
//             ElevatedButton.icon(
//               onPressed: () => _testCallWithData(),
//               icon: Icon(Icons.engineering, color: Colors.white),
//               label: Text(
//                 'اختبار مكالمة مقدم خدمة',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
            
//             SizedBox(height: 15),
            
//             // زر اختبار مكالمة طوارئ
//             ElevatedButton.icon(
//               onPressed: () => _testEmergencyCall(),
//               icon: Icon(Icons.warning, color: Colors.white),
//               label: Text(
//                 'اختبار مكالمة طوارئ',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.white,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
            
//             SizedBox(height: 30),
            

//             // زر اختبار Native Call Notification
// ElevatedButton.icon(
//   onPressed: () => _testNativeCallNotification(),
//   icon: Icon(Icons.notifications_active, color: Colors.white),
//   label: Text(
//     'اختبار إشعار مكالمة Native',
//     style: TextStyle(
//       fontSize: 18,
//       color: Colors.white,
//     ),
//   ),
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Colors.purple,
//     padding: EdgeInsets.symmetric(vertical: 15),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(10),
//     ),
//   ),
// ),

// SizedBox(height: 15),

// // زر اختبار Native General Notification
// ElevatedButton.icon(
//   onPressed: () => _testNativeGeneralNotification(),
//   icon: Icon(Icons.notification_important, color: Colors.white),
//   label: Text(
//     'اختبار إشعار عادي Native',
//     style: TextStyle(
//       fontSize: 18,
//       color: Colors.white,
//     ),
//   ),
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Colors.teal,
//     padding: EdgeInsets.symmetric(vertical: 15),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(10),
//     ),
//   ),
// ),

// SizedBox(height: 15),

//             // معلومات إضافية
//             Container(
//               padding: EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'ملاحظات:',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text('• سيظهر إشعار المكالمة مع نغمة الرنين'),
//                   Text('• يمكنك قبول أو رفض المكالمة'),
//                   Text('• زر التفاصيل سيفتح صفحة الطلب'),
//                   Text('• النغمة ستتوقف عند اتخاذ أي إجراء'),
//                 ],
//               ),
//             ),
            
//             Spacer(),
            
//             // معلومات الخدمة
//             Container(
//               padding: EdgeInsets.all(10),
//               child: Text(
//                 'هذه الأزرار لاختبار نظام المكالمات فقط\nفي التطبيق الحقيقي ستظهر عند استلام إشعار FCM',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // اختبار مكالمة عادية
//   void _testNormalCall() {
//     try {
//       final callService = SimpleCallService.instance;
      
//       callService.showCallOverlay(
//         callerName: 'أحمد محمد',
//         callerPhone: '+966501234567',
//         callerAvatar: null, // بدون صورة
//         extraData: null,
//       );
      
//       Get.snackbar(
//         'تم بدء الاختبار',
//         'ستظهر واجهة المكالمة الآن',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: Duration(seconds: 2),
//       );
      
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ في بدء الاختبار: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // اختبار مكالمة مع بيانات
//   void _testCallWithData() {
//     try {
//       final callService = SimpleCallService.instance;
      
//       callService.showCallOverlay(
//         callerName: 'خالد السباك',
//         callerPhone: '+966551234567',
//         callerAvatar: 'https://via.placeholder.com/150', // صورة تجريبية
//         extraData: {
//           'order_id': 'ORD_12345',
//           'service_type': 'سباكة',
//           'provider_id': 'PRV_567',
//           'estimated_arrival': '15 دقيقة',
//         },
//       );
      
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ في بدء الاختبار: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // اختبار مكالمة طوارئ
//   void _testEmergencyCall() {
//     try {
//       final callService = SimpleCallService.instance;
      
//       callService.showCallOverlay(
//         callerName: 'خدمة الطوارئ',
//         callerPhone: '+966911',
//         callerAvatar: null,
//         extraData: {
//           'order_id': 'EMR_911',
//           'service_type': 'طوارئ',
//           'priority': 'عالية',
//         },
//       );
      
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ في بدء الاختبار: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
// }

// // إضافة الصفحة إلى home_screen.dart أو أي صفحة أخرى
// class HomeScreenWithTestButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('الرئيسية'),
//         actions: [
//           // زر اختبار المكالمات في AppBar
//           IconButton(
//             onPressed: () => Get.to(() => TestCallScreen()),
//             icon: Icon(Icons.call),
//             tooltip: 'اختبار المكالمات',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // محتوى الصفحة الرئيسية...
            
//             SizedBox(height: 20),
            
//             // زر اختبار سريع
//             Card(
//               elevation: 5,
//               child: Padding(
//                 padding: EdgeInsets.all(15),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.phone_in_talk,
//                       size: 50,
//                       color: Colors.blue,
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'اختبار نظام المكالمات',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     ElevatedButton(
//                       onPressed: () => _quickCallTest(),
//                       child: Text('اختبار سريع'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     TextButton(
//                       onPressed: () => Get.to(() => TestCallScreen()),
//                       child: Text('المزيد من خيارات الاختبار'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             // باقي محتوى الصفحة...
//           ],
//         ),
//       ),
      
//       // زر عائم لاختبار سريع
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _quickCallTest(),
//         child: Icon(Icons.call),
//         backgroundColor: Colors.green,
//         tooltip: 'اختبار مكالمة سريع',
//       ),
//     );
//   }

//   // اختبار سريع
//   void _quickCallTest() {
//     try {
//       final callService = SimpleCallService.instance;
      
//       callService.showCallOverlay(
//         callerName: 'اختبار سريع',
//         callerPhone: '+966500000000',
//         extraData: {
//           'test': true,
//           'service_type': 'اختبار',
//         },
//       );
      
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'تأكد من تهيئة SimpleCallService في main.dart',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
// }

// // widget بسيط لإضافة زر في أي مكان
// class QuickCallTestButton extends StatelessWidget {
//   final String? buttonText;
//   final Color? buttonColor;

//   const QuickCallTestButton({
//     Key? key,
//     this.buttonText,
//     this.buttonColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: () {
//         try {
//           final callService = SimpleCallService.instance;
          
//           callService.showCallOverlay(
//             callerName: 'مختبر التطبيق',
//             callerPhone: '+966555123456',
//             extraData: {
//               'test_mode': true,
//               'service_type': 'اختبار النظام',
//             },
//           );
          
//         } catch (e) {
//           Get.snackbar(
//             'خطأ في الاختبار',
//             'تأكد من إعداد SimpleCallService بشكل صحيح',
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//           );
//         }
//       },
//       icon: Icon(Icons.phone, color: Colors.white),
//       label: Text(
//         buttonText ?? 'اختبار المكالمة',
//         style: TextStyle(color: Colors.white),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: buttonColor ?? Colors.green,
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }



// class NativeNotificationService {
//   static const platform = MethodChannel('com.khabirs.provider/notifications');

//   // إظهار إشعار مكالمة native
//   @pragma('vm:entry-point')
//   static Future<void> showNativeCallNotification({
//     required String callerName,
//     required String callerPhone,
//     String? callerAvatar,
//     required Map<String, dynamic> callData,
//   }) async {
//     try {
//       await platform.invokeMethod('showCallNotification', {
//         'callerName': callerName,
//         'callerPhone': callerPhone,
//         'callerAvatar': callerAvatar ?? '',
//         'callData': callData,
//       });

//       print('✅ Native call notification shown');
//     } catch (e) {
//       print('❌ Error showing native call notification: $e');
//     }
//   }

//   // إظهار إشعار عادي native
//   static Future<void> showNativeGeneralNotification({
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//   }) async {
//     try {
//       await platform.invokeMethod('showGeneralNotification', {
//         'title': title,
//         'body': body,
//         'data': data ?? {},
//       });
//       print('✅ Native general notification shown');
//     } catch (e) {
//       print('❌ Error showing native general notification: $e');
//     }
//   }

//   // إلغاء إشعار المكالمة
//   static Future<void> cancelCallNotification() async {
//     try {
//       await platform.invokeMethod('cancelCallNotification');
//       print('✅ Native call notification cancelled');
//     } catch (e) {
//       print('❌ Error cancelling native call notification: $e');
//     }
//   }
// }

