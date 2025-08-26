import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import 'package:khabir/controllers/IncomeController.dart';

class IncomeView extends GetView<IncomeController> {
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.grey[50],
body: SafeArea(
child: Column(
children: [
// Top Bar
_buildTopBar(),
const SizedBox(height: 20),
// Content
Expanded(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20),
child: Column(
children: [
// Statistics Cards
_buildStatisticsCards(),
const SizedBox(height: 20),
// Income List
Expanded(
child: Obx(() {
if (controller.isLoading.value) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
CircularProgressIndicator(),
SizedBox(height: 16),
Text(
'loading_invoices'.tr,
style: TextStyle(
fontSize: 16,
color: Colors.grey,
),
),
],
),
);
}
if (controller.incomeRecords.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.receipt_long,
size: 64,
color: Colors.grey,
),
SizedBox(height: 16),
Text(
'no_invoices'.tr,
style: TextStyle(
fontSize: 16,
color: Colors.grey,
),
),
],
),
);
}
return ListView.builder(
itemCount: controller.incomeRecords.length,
itemBuilder: (context, index) {
final record = controller.incomeRecords[index];
return Padding(
padding: const EdgeInsets.only(bottom: 16),
child: _buildIncomeCard(record),
);
},
);
}),
),
],
),
),
),
],
),
),
);
}

Widget _buildTopBar() {
return Container(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: const BorderRadius.only(
bottomLeft: Radius.circular(25),
bottomRight: Radius.circular(25),
),
boxShadow: [
BoxShadow(
color: AppColors.primary.withOpacity(0.10),
spreadRadius: 0,
blurRadius: 12,
offset: const Offset(0, 4),
),
],
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
// Back button and title
Row(
children: [
// Back button
GestureDetector(
onTap: () => Get.back(),
child: Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(8),
border: Border.all(
color: Colors.grey[300]!,
width: 1,
),
),
child: const Icon(
Icons.arrow_back_ios_new,
color: Colors.black54,
size: 18,
),
),
),
const SizedBox(width: 20),
// Title
Text(
'income'.tr,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
// Logo
GestureDetector(
onTap: () {
Get.snackbar('خبير', 'welcome_message'.tr);
},
child: Container(
height: 40,
child: Image.asset(
'assets/icons/logo_sm.png',
height: 40,
fit: BoxFit.contain,
errorBuilder: (context, error, stackTrace) {
return Row(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: const Color(0xFFEF4444),
borderRadius: BorderRadius.circular(12),
),
child: const Center(
child: Icon(
Icons.build,
color: Colors.white,
size: 24,
),
),
),
const SizedBox(width: 8),
Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'خبير',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
color: Color(0xFFEF4444),
height: 1.0,
),
),
const Text(
'khabir',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w500,
color: Color(0xFFEF4444),
height: 1.0,
),
),
],
),
],
);
},
),
),
),
],
),
);
}

Widget _buildStatisticsCards() {
return Obx(() => Row(
children: [
// Completed requests
Expanded(
child: _buildStatCard(
icon: Icons.work_outline,
title: 'completed_requests'.tr,
value: controller.completedRequests.toString(),
color: const Color(0xFFEF4444),
),
),
const SizedBox(width: 12),
// Gross income
Expanded(
child: _buildStatCard(
icon: Icons.attach_money,
title: 'gross_income'.tr,
value: '${controller.grossIncome.value.toStringAsFixed(2)} OMR',
color: const Color(0xFFEF4444),
),
),
const SizedBox(width: 12),
// After commission
Expanded(
child: _buildStatCard(
icon: Icons.trending_up,
title: 'after_commission'.tr,
value: '${controller.afterCommission.value.toStringAsFixed(2)} OMR',
color: const Color(0xFFEF4444),
),
),
],
));
}

Widget _buildStatCard({
required IconData icon,
required String title,
required String value,
required Color color,
}) {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.grey.withOpacity(0.1),
spreadRadius: 1,
blurRadius: 6,
offset: const Offset(0, 2),
),
],
),
child: Column(
children: [
// Icon container
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
color: Colors.grey[100],
borderRadius: BorderRadius.circular(12),
),
child: Icon(
icon,
color: color,
size: 28,
),
),
const SizedBox(height: 12),
// Title
Text(
title,
style: const TextStyle(
fontSize: 12,
color: Colors.black87,
fontWeight: FontWeight.w500,
),
textAlign: TextAlign.center,
maxLines: 2,
overflow: TextOverflow.ellipsis,
),
const SizedBox(height: 4),
// Value
Text(
value,
style: TextStyle(
fontSize: 14,
color: color,
fontWeight: FontWeight.w700,
),
textAlign: TextAlign.center,
),
],
),
);
}

Widget _buildIncomeCard(Map<String, dynamic> record) {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(16),
boxShadow: [
BoxShadow(
color: Colors.grey.withOpacity(0.1),
spreadRadius: 1,
blurRadius: 6,
offset: const Offset(0, 2),
),
],
),
child: Column(
children: [
// Header with profile and ID
Row(
children: [
// Profile image
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(25),
border: Border.all(color: Colors.grey[300]!, width: 1),
),
child: ClipRRect(
borderRadius: BorderRadius.circular(25),
child: record['profileImage'].startsWith('assets/')
? Image.asset(
record['profileImage'],
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) {
return Container(
color: Colors.grey[200],
child: Icon(
Icons.person,
color: Colors.grey[400],
size: 30,
),
);
},
)
    : Image.network(
record['profileImage'],
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) {
return Container(
color: Colors.grey[200],
child: Icon(
Icons.person,
color: Colors.grey[400],
size: 30,
),
);
},
),
),
),
const SizedBox(width: 12),
// Name and phone
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
record['customerName'],
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
const SizedBox(height: 4),
Text(
record['phone'],
style: TextStyle(
fontSize: 14,
color: Colors.grey[600],
fontWeight: FontWeight.w400,
),
),
],
),
),
// ID and State
Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'id'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(width: 4),
Text(
record['id'],
style: const TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
const SizedBox(height: 8),
Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'state'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(width: 4),
Text(
record['state'],
style: const TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
],
),
],
),
const SizedBox(height: 16),
// Service details
Row(
children: [
// Category
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'category'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
record['category'],
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
),
// Type
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'type'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
record['type'],
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
),
// Number
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'number'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
record['number'].toString(),
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
),
// Duration
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'duration'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
record['duration'],
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
),
// Total Price
Column(
crossAxisAlignment: CrossAxisAlignment.end,
children: [
Text(
'total_price'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
'${record['totalPrice']} ${'omr'.tr}',
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Color(0xFFEF4444),
),
),
],
),
],
),
const SizedBox(height: 16),
// Commission details and payment status
Row(
children: [
// Commission
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'commission'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
'${record['commission']} ${'omr'.tr}',
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
),
// After Commission
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'after_commission'.tr,
style: TextStyle(
fontSize: 12,
color: Colors.grey[600],
fontWeight: FontWeight.w500,
),
),
const SizedBox(height: 4),
Text(
'${record['afterCommission']} ${'omr'.tr}',
style: const TextStyle(
fontSize: 14,
fontWeight: FontWeight.w600,
color: Colors.black87,
),
),
],
),
),
const SizedBox(width: 16),
// Payment status
_buildPaymentStatus(record['paymentStatus'], record['id']),
],
),
],
),
);
}

Widget _buildPaymentStatus(String status, String recordId) {
final bool isPaid = status.toLowerCase() == 'paid';
final bool canRequest = controller.canRequestPayment(recordId);

Color backgroundColor;
Color textColor;
String text;
IconData? icon;

if (isPaid) {
backgroundColor = Colors.green;
textColor = Colors.white;
text = 'paid'.tr;
icon = Icons.check;
} else {
backgroundColor = const Color(0xFFEF4444);
textColor = Colors.white;
text = 'not_paid'.tr;
icon = Icons.paid_outlined;
}

return GestureDetector(
onTap: canRequest ? () => controller.contactAdminForPayment(recordId) : null,
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
decoration: BoxDecoration(
color: backgroundColor,
borderRadius: BorderRadius.circular(20),
boxShadow: canRequest
? [
BoxShadow(
color: backgroundColor.withOpacity(0.3),
spreadRadius: 1,
blurRadius: 4,
offset: const Offset(0, 2),
),
]
    : null,
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
if (icon != null) ...[
Icon(
icon,
color: textColor,
size: 14,
),
const SizedBox(width: 4),
],
Text(
text,
style: TextStyle(
color: textColor,
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
if (canRequest) ...[
const SizedBox(width: 4),
Icon(
Icons.arrow_forward_ios,
color: textColor,
size: 10,
),
],
],
),
),
);
}
}
