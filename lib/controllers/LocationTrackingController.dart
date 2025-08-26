// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import '../services/LocationTrackingService.dart';
//
// class LocationTrackingController extends GetxController {
//   final LocationTrackingService _locationService = Get.find<LocationTrackingService>();
//
//   // Observable states من الخدمة
//   bool get isConnected => _locationService.isConnected.value;
//   bool get isTracking => _locationService.isTracking.value;
//   int? get currentOrderId => _locationService.currentOrderId.value;
//   Position? get lastLocation => _locationService.lastLocation.value;
//
//   // Local loading states
//   var isStartingTracking = false.obs;
//   var isStoppingTracking = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _setupListeners();
//   }
//
//   /// إعداد المستمعين للتغيرات
//   void _setupListeners() {
//     // مراقبة حالة الاتصال
//     ever(_locationService.isConnected, (bool connected) {
//       if (connected) {
//         _showInfoSnackbar('متصل', 'تم الاتصال بخادم التتبع');
//       } else if (isTracking) {
//         _showWarningSnackbar('انقطاع الاتصال', 'انقطع الاتصال بخادم التتبع');
//       }
//     });
//
//     // مراقبة حالة التتبع
//     ever(_locationService.isTracking, (bool tracking) {
//       if (tracking && currentOrderId != null) {
//         _showSuccessSnackbar('بدء التتبع', 'تم بدء تتبع موقعك للطلب #$currentOrderId');
//       }
//     });
//   }
//
//   /// بدء تتبع الموقع لطلب معين
//   Future<bool> startTracking(int orderId, {int? updateInterval}) async {
//     if (isStartingTracking.value) return false;
//
//     try {
//       isStartingTracking.value = true;
//
//       // التحقق من الاتصال بالإنترنت
//       if (!await _checkInternetConnection()) {
//         _showErrorSnackbar('لا يوجد اتصال', 'تأكد من اتصالك بالإنترنت');
//         return false;
//       }
//
//       // التحقق من صلاحيات الموقع
//       final hasPermission = await _checkAndRequestLocationPermission();
//       if (!hasPermission) {
//         _showPermissionDialog();
//         return false;
//       }
//
//       // بدء التتبع
//       final success = await _locationService.startLocationTracking(
//         orderId,
//         updateInterval: updateInterval,
//       );
//
//       if (success) {
//         _showSuccessSnackbar(
//           'تم بدء التتبع',
//           'يمكن للعميل الآن تتبع موقعك',
//         );
//       } else {
//         _showErrorSnackbar(
//           'فشل التتبع',
//           'لم نتمكن من بدء التتبع. حاول مرة أخرى',
//         );
//       }
//
//       return success;
//     } catch (e) {
//       print('Error in startTracking: $e');
//       _showErrorSnackbar('خطأ', 'حدث خطأ في بدء التتبع: ${e.toString()}');
//       return false;
//     } finally {
//       isStartingTracking.value = false;
//     }
//   }
//
//   /// إيقاف تتبع الموقع
//   Future<bool> stopTracking() async {
//     if (isStoppingTracking.value) return false;
//
//     try {
//       isStoppingTracking.value = true;
//
//       await _locationService.stopLocationTracking();
//
//       _showInfoSnackbar('تم الإيقاف', 'تم إيقاف تتبع الموقع');
//       return true;
//     } catch (e) {
//       print('Error checking location permission: $e');
//       return false;
//     }
//   }
//
//   /// التحقق من الاتصال بالإنترنت
//   Future<bool> _checkInternetConnection() async {
//     try {
//       // يمكن استخدام مكتبة connectivity_plus للتحقق الأفضل
//       // هنا نستخدم طريقة بسيطة
//       return true; // يفترض وجود اتصال، يمكن تحسينها
//     } catch (e) {
//       return false;
//     }
//   }
//
//   /// عرض حوار طلب الصلاحيات
//   void _showPermissionDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('صلاحية الموقع مطلوبة'),
//         content: const Text(
//             'يحتاج التطبيق لصلاحية الوصول للموقع لتتبع موقعك وإرساله للعميل.\n\nهل تريد منح الصلاحية؟'
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('لاحقاً'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openAppSettings();
//             },
//             child: const Text('فتح الإعدادات'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// عرض حوار تفعيل خدمات الموقع
//   void _showLocationServiceDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('تفعيل خدمات الموقع'),
//         content: const Text(
//             'خدمات الموقع غير مفعلة. يرجى تفعيل GPS من إعدادات الجهاز.'
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               Get.back();
//               await Geolocator.openLocationSettings();
//             },
//             child: const Text('فتح الإعدادات'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// عرض معلومات حالة التتبع
//   void showTrackingStatus() {
//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.all(20),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'حالة التتبع',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//
//             _buildStatusItem(
//               'الاتصال بالخادم',
//               isConnected ? 'متصل' : 'غير متصل',
//               isConnected ? Colors.green : Colors.red,
//               isConnected ? Icons.wifi : Icons.wifi_off,
//             ),
//
//             _buildStatusItem(
//               'حالة التتبع',
//               isTracking ? 'نشط' : 'متوقف',
//               isTracking ? Colors.green : Colors.grey,
//               isTracking ? Icons.location_on : Icons.location_off,
//             ),
//
//             if (currentOrderId != null)
//               _buildStatusItem(
//                 'الطلب الحالي',
//                 '#$currentOrderId',
//                 Colors.blue,
//                 Icons.assignment,
//               ),
//
//             if (lastLocation != null)
//               _buildStatusItem(
//                 'آخر موقع',
//                 '${lastLocation!.latitude.toStringAsFixed(4)}, ${lastLocation!.longitude.toStringAsFixed(4)}',
//                 Colors.orange,
//                 Icons.gps_fixed,
//               ),
//
//             const SizedBox(height: 20),
//
//             Row(
//               children: [
//                 if (!isConnected)
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: reconnect,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                       ),
//                       child: const Text('إعادة الاتصال'),
//                     ),
//                   ),
//
//                 if (!isConnected && isTracking) const SizedBox(width: 10),
//
//                 if (isTracking)
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: isStoppingTracking.value ? null : stopTracking,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                       child: isStoppingTracking.value
//                           ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                           : const Text('إيقاف التتبع'),
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// بناء عنصر حالة
//   Widget _buildStatusItem(String title, String value, Color color, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// الحصول على نص حالة التتبع
//   String get trackingStatusText {
//     if (!isConnected) return 'غير متصل';
//     if (isTracking) return 'يتم التتبع';
//     return 'متوقف';
//   }
//
//   /// الحصول على لون حالة التتبع
//   Color get trackingStatusColor {
//     if (!isConnected) return Colors.red;
//     if (isTracking) return Colors.green;
//     return Colors.grey;
//   }
//
//   /// الحصول على أيقونة حالة التتبع
//   IconData get trackingStatusIcon {
//     if (!isConnected) return Icons.signal_wifi_off;
//     if (isTracking) return Icons.my_location;
//     return Icons.location_disabled;
//   }
//
//   // رسائل التنبيه
//   void _showSuccessSnackbar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//       icon: const Icon(Icons.check_circle, color: Colors.white),
//     );
//   }
//
//   void _showErrorSnackbar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 4),
//       icon: const Icon(Icons.error, color: Colors.white),
//     );
//   }
//
//   void _showWarningSnackbar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.orange,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 4),
//       icon: const Icon(Icons.warning, color: Colors.white),
//     );
//   }
//
//   void _showInfoSnackbar(String title, String message) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//       icon: const Icon(Icons.info, color: Colors.white),
//     );
//   }
//
// /// إعادة الاتصال بالـ Socket
// Future<void> reconnect() async {
//   try {
//     _showInfoSnackbar('جاري الاتصال', 'جاري إعادة الاتصال بالخادم...');
//     await _locationService.reconnect();
//   } catch (e) {
//     _showErrorSnackbar('خطأ في الاتصال', 'فشل في إعادة الاتصال');
//   }
// }
//
// /// التحقق من صلاحيات الموقع وطلبها
// Future<bool> _checkAndRequestLocationPermission() async {
//   try {
//     // التحقق من تفعيل خدمات الموقع
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showLocationServiceDialog();
//       return false;
//     }
//
//     // التحقق من الصلاحيات
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return false;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return false;
//     }
//
//     return true;
//   } catch (e) {
//     print('Error in stopTracking: $e');
//     _showErrorSnackbar('خطأ', 'حدث خطأ في إيقاف التتبع');
//     return false;
//   } finally {
//     isStoppingTracking.value = false;
//   }
// }
// }