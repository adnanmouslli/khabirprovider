// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import '../../controllers/auth_controller.dart';
// import '../../utils/colors.dart';
// import '../../widgets/CustomButton.dart';
//
// class VerifyOtpView extends GetView<AuthController> {
//   final AuthController controller = Get.put(AuthController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3F4F6),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Dialog container
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 20,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // أيقونة الهاتف
//                       Container(
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           color: AppColors.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(40),
//                         ),
//                         child: Icon(
//                           Icons.smartphone_rounded,
//                           size: 40,
//                           color: AppColors.primary,
//                         ),
//                       ),
//
//                       const SizedBox(height: 24),
//
//                       // العنوان
//                       Text(
//                         'forgot_your_password'.tr,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w800,
//                           color: AppColors.textPrimary,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       // الوصف
//                       Text(
//                         'verification_code_sent'.tr,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.textPrimary,
//                           height: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//
//                       const SizedBox(height: 8),
//
//                       Text(
//                         'enter_field_below'.tr,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           color: AppColors.textSecondary,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//
//                       const SizedBox(height: 32),
//
//                       // حقل OTP باستخدام pin_code_fields
//                       _buildPinCodeField(),
//
//                       const SizedBox(height: 16),
//
//                       // رسالة الخطأ
//                       Obx(() => controller.hasOtpError.value
//                           ? Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 12),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFFEF2F2),
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(
//                                   color: const Color(0xFFFECACA),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.error_outline_rounded,
//                                     color: Color(0xFFEF4444),
//                                     size: 20,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: Text(
//                                       controller.otpErrorText.value,
//                                       style: const TextStyle(
//                                         color: Color(0xFFEF4444),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : const SizedBox.shrink()),
//
//                       const SizedBox(height: 24),
//
//                       // قسم إعادة الإرسال
//                       _buildResendSection(),
//
//                       const SizedBox(height: 32),
//
//                       // زر التأكيد
//                       Obx(() => CustomButton(
//                             text: 'confirmation'.tr,
//                             onPressed: controller.verifyOtpCode,
//                             isLoading: controller.isLoading.value,
//                             width: double.infinity,
//                             height: 56,
//                             backgroundColor: AppColors.primary,
//                             textColor: Colors.white,
//                             borderRadius: 12,
//                             icon: Icons.check_circle_outline_rounded,
//                           )),
//
//                       const SizedBox(height: 16),
//
//                       // زر مسح الرمز
//                       TextButton.icon(
//                         onPressed: controller.clearOtp,
//                         icon: const Icon(
//                           Icons.refresh_rounded,
//                           size: 18,
//                         ),
//                         label: const Text(
//                           'مسح الرمز',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         style: TextButton.styleFrom(
//                           foregroundColor: AppColors.textSecondary,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPinCodeField() {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 4),
//         child: PinCodeTextField(
//           appContext: Get.context!,
//           length: 6,
//           controller: controller.otpController,
//           errorAnimationController: controller.otpErrorController,
//           animationType: AnimationType.scale,
//           keyboardType: TextInputType.number,
//           textStyle: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: AppColors.textPrimary,
//           ),
//
//           // تخصيص شكل الحقول
//           pinTheme: PinTheme(
//             shape: PinCodeFieldShape.box,
//             borderRadius: BorderRadius.circular(12),
//             fieldHeight: 56,
//             fieldWidth: 42,
//
//             // الحالة العادية
//             inactiveColor: AppColors.textSecondary.withOpacity(0.3),
//             inactiveFillColor: const Color(0xFFF9FAFB),
//
//             // الحالة النشطة (عند التركيز)
//             activeColor: AppColors.primary,
//             activeFillColor: AppColors.primary.withOpacity(0.05),
//
//             // الحالة المحددة (عند الكتابة)
//             selectedColor: AppColors.primary,
//             selectedFillColor: AppColors.primary.withOpacity(0.1),
//
//             // حالة الخطأ
//             errorBorderColor: const Color(0xFFEF4444),
//
//             borderWidth: 2,
//             disabledColor: AppColors.textSecondary.withOpacity(0.2),
//           ),
//
//           // تفعيل التعبئة
//           enableActiveFill: true,
//
//           // تفعيل التبديل التلقائي بين الحقول
//           autoFocus: true,
//
//           // إعدادات الكيبورد
//           enablePinAutofill: true,
//           useHapticFeedback: true,
//           hapticFeedbackTypes: HapticFeedbackTypes.medium,
//
//           // الأنيميشن عند إدخال الرقم
//           animationDuration: const Duration(milliseconds: 300),
//
//           // تخصيص لون المؤشر
//           cursorColor: AppColors.primary,
//           cursorWidth: 2,
//           cursorHeight: 20,
//
//           // عند تغيير النص
//           onChanged: (value) {
//             controller.onOtpChanged(value);
//           },
//
//           // عند إكمال الإدخال
//           onCompleted: (value) {
//             print("OTP مكتمل في صفحة التحقق: $value");
//             // إظهار تأثير بصري عند اكتمال الرمز
//             _showCompletionFeedback();
//           },
//
//           // عند الضغط على الحقل
//           onTap: () {
//             print("تم الضغط على حقل OTP في صفحة التحقق");
//           },
//
//           // قبل إدخال النص (للتحقق من صحة الإدخال)
//           beforeTextPaste: (text) {
//             print("محاولة لصق في صفحة التحقق: $text");
//             if (text != null && text.length == 6) {
//               return RegExp(r'^[0-9]+$').hasMatch(text);
//             }
//             return false;
//           },
//
//           // إعدادات إضافية
//           showCursor: true,
//           blinkWhenObscuring: true,
//           blinkDuration: const Duration(milliseconds: 600),
//
//           // خيارات التحديد
//           autovalidateMode: AutovalidateMode.disabled,
//         ),
//       ),
//     );
//   }
//
//   void _showCompletionFeedback() {
//     // تأثير بصري بسيط عند اكتمال الرمز
//     Get.snackbar(
//       '',
//       '',
//       titleText: const SizedBox.shrink(),
//       messageText: Row(
//         children: [
//           Icon(
//             Icons.check_circle_rounded,
//             color: Colors.green,
//             size: 20,
//           ),
//           const SizedBox(width: 8),
//           const Text(
//             'تم إدخال الرمز بالكامل',
//             style: TextStyle(
//               color: Colors.green,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: Colors.green.withOpacity(0.1),
//       borderColor: Colors.green.withOpacity(0.3),
//       borderWidth: 1,
//       duration: const Duration(seconds: 2),
//       snackPosition: SnackPosition.TOP,
//       margin: const EdgeInsets.all(16),
//       borderRadius: 8,
//     );
//   }
//
//   Widget _buildResendSection() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF9FAFB),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: AppColors.textSecondary.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'didnt_get_code'.tr,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Obx(() => GestureDetector(
//                     onTap: controller.canResendOtp.value
//                         ? controller.resendOtp
//                         : null,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: controller.canResendOtp.value
//                             ? AppColors.primary
//                             : AppColors.textSecondary.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         'resend'.tr,
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: controller.canResendOtp.value
//                               ? Colors.white
//                               : AppColors.textSecondary,
//                         ),
//                       ),
//                     ),
//                   )),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Obx(() => controller.otpTimer.value > 0
//               ? Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFEF2F2),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: const Color(0xFFFECACA),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.timer_outlined,
//                         color: Color(0xFFEF4444),
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '${'expires_in'.tr} ${(controller.otpTimer.value ~/ 60).toString().padLeft(1, '0')}:${(controller.otpTimer.value % 60).toString().padLeft(2, '0')}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFFEF4444),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : const SizedBox.shrink()),
//         ],
//       ),
//     );
//   }
// }
