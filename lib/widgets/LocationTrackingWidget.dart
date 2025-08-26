// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../controllers/LocationTrackingController.dart';
//
// class LocationTrackingWidget extends StatelessWidget {
//   final LocationTrackingController controller = Get.find<LocationTrackingController>();
//
//   LocationTrackingWidget({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان مع الحالة
//           Row(
//             children: [
//               Icon(
//                 controller.trackingStatusIcon,
//                 color: controller.trackingStatusColor,
//                 size: 24,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'تتبع الموقع',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: controller.trackingStatusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   controller.trackingStatusText,
//                   style: TextStyle(
//                     color: controller.trackingStatusColor,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 16),
//
//           // معلومات الطلب الحالي
//           if (controller.currentOrderId != null)
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.assignment,
//                     color: Colors.blue,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'الطلب الحالي: #${controller.currentOrderId}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           if (controller.currentOrderId != null) const SizedBox(height: 12),
//
//           // معلومات آخر موقع
//           if (controller.lastLocation != null)
//             Row(
//               children: [
//                 const Icon(
//                   Icons.gps_fixed,
//                   color: Colors.green,
//                   size: 16,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'آخر تحديث: ${controller.lastLocation!.latitude.toStringAsFixed(4)}, ${controller.lastLocation!.longitude.toStringAsFixed(4)}',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//           const SizedBox(height: 16),
//
//           // أزرار التحكم
//           Row(
//             children: [
//               // زر عرض التفاصيل
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: controller.showTrackingStatus,
//                   icon: const Icon(Icons.info_outline, size: 16),
//                   label: const Text('التفاصيل'),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: 12),
//
//               // زر إعادة الاتصال (إذا انقطع الاتصال)
//               if (!controller.isConnected) ...[
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: controller.reconnect,
//                     icon: const Icon(Icons.refresh, size: 16),
//                     label: const Text('إعادة الاتصال'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                     ),
//                   ),
//                 ),
//               ],
//
//               // زر إيقاف التتبع (إذا كان نشط)
//               if (controller.isTracking) ...[
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: controller.isStoppingTracking.value
//                         ? null
//                         : controller.stopTracking,
//                     icon: controller.isStoppingTracking.value
//                         ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                         : const Icon(Icons.stop, size: 16),
//                     label: const Text('إيقاف'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//
//           // تحذير إذا لم يكن متصل
//           if (!controller.isConnected && controller.isTracking)
//             Container(
//               margin: const EdgeInsets.only(top: 12),
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//                 border: Border.all(color: Colors.orange.withOpacity(0.3)),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(
//                     Icons.warning_amber,
//                     color: Colors.orange,
//                     size: 16,
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'انقطع الاتصال بالخادم. جاري المحاولة إعادة الاتصال...',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.orange,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     ));
//   }
// }
//
// /// Widget مُصغر للإشارة لحالة التتبع في AppBar
// class LocationTrackingIndicator extends StatelessWidget {
//   final LocationTrackingController controller = Get.find<LocationTrackingController>();
//
//   LocationTrackingIndicator({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => GestureDetector(
//       onTap: controller.showTrackingStatus,
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               controller.trackingStatusIcon,
//               color: controller.trackingStatusColor,
//               size: 20,
//             ),
//             if (controller.isTracking) ...[
//               const SizedBox(width: 4),
//               Container(
//                 width: 8,
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     ));
//   }
// }
//
// /// Widget للطلبات - يظهر فقط للطلبات المقبولة
// class OrderLocationTrackingCard extends StatelessWidget {
//   final int orderId;
//   final bool isAccepted;
//   final LocationTrackingController controller = Get.find<LocationTrackingController>();
//
//   OrderLocationTrackingCard({
//     Key? key,
//     required this.orderId,
//     required this.isAccepted,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (!isAccepted) return const SizedBox.shrink();
//
//     return Obx(() {
//       final isCurrentOrder = controller.currentOrderId == orderId;
//       final isThisOrderTracked = isCurrentOrder && controller.isTracking;
//
//       return Card(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     isThisOrderTracked ? Icons.my_location : Icons.location_on,
//                     color: isThisOrderTracked ? Colors.green : Colors.grey,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'تتبع الموقع للطلب #$orderId',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: (isThisOrderTracked ? Colors.green : Colors.grey)
//                           .withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       isThisOrderTracked ? 'نشط' : 'متوقف',
//                       style: TextStyle(
//                         color: isThisOrderTracked ? Colors.green : Colors.grey,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               if (isThisOrderTracked) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   'يمكن للعميل تتبع موقعك الآن',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//                 if (controller.lastLocation != null)
//                   Text(
//                     'آخر تحديث: ${DateTime.now().toString().substring(11, 16)}',
//                     style: const TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey,
//                     ),
//                   ),
//               ],
//
//               if (!isThisOrderTracked && isCurrentOrder) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   'التتبع متوقف لهذا الطلب',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.orange.shade700,
//                   ),
//                 ),
//               ],
//
//               if (!isCurrentOrder) ...[
//                 const SizedBox(height: 8),
//                 ElevatedButton.icon(
//                   onPressed: controller.isStartingTracking.value
//                       ? null
//                       : () => controller.startTracking(orderId),
//                   icon: controller.isStartingTracking.value
//                       ? const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     ),
//                   )
//                       : const Icon(Icons.play_arrow, size: 16),
//                   label: const Text('بدء التتبع'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }