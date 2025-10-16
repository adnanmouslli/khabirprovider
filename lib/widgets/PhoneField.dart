import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/colors.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final String? errorText;
  final bool showValidIcon;
  final bool enabled;
  final double height;
  final String countryCode;
  final String flagAssetPath;
  final String countryShortName;

  const PhoneField({
    Key? key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.errorText,
    this.showValidIcon = true,
    this.enabled = true,
    this.height = 56,
    this.countryCode = '+968',
    this.flagAssetPath = 'assets/icons/oman_flag.png',
    this.countryShortName = 'OM',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null && errorText!.isNotEmpty
                  ? Colors.red
                  : AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                // قسم رمز البلد
                _buildCountryCodeSection(),

                // قسم إدخال رقم الهاتف
                _buildPhoneInputSection(),
              ],
            ),
          ),
        ),

        // رسالة الخطأ
        if (errorText != null && errorText!.isNotEmpty)
          _buildErrorMessage(),
      ],
    );
  }

  Widget _buildCountryCodeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        mainAxisSize: MainAxisSize.min,
        children: [
          // العلم
          _buildFlagIcon(),
          const SizedBox(width: 8),
          // رمز البلد
          Text(
            countryCode,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildFlagIcon() {
    return Image.asset(
      flagAssetPath,
      width: 30,
      height: 20,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 20,
          height: 15,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              countryShortName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneInputSection() {
    return Expanded(
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.phone,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? const Color(0xFF111827) : Colors.grey[600],
          fontWeight: FontWeight.w400,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText ?? 'enter_mobile_number'.tr,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          // أيقونة التحقق عند كتابة رقم صحيح
          suffixIcon: _buildSuffixIcon(),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (!showValidIcon) return null;

    if (controller.text.isNotEmpty &&
        (errorText == null || errorText!.isEmpty)) {
      return const Icon(
        Icons.check_circle_outline,
        color: Colors.green,
        size: 20,
      );
    }

    return null;
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget مخصص للاستخدام مع GetX Controller
class ObxPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final RxString? errorText; // استخدام RxString للتحديث التلقائي
  final bool showValidIcon;
  final bool enabled;
  final double height;
  final String countryCode;
  final String flagAssetPath;
  final String countryShortName;

  const ObxPhoneField({
    Key? key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.errorText,
    this.showValidIcon = true,
    this.enabled = true,
    this.height = 56,
    this.countryCode = '+968',
    this.flagAssetPath = 'assets/icons/oman_flag.png',
    this.countryShortName = 'OM',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => PhoneField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      errorText: errorText?.value,
      showValidIcon: showValidIcon,
      enabled: enabled,
      height: height,
      countryCode: countryCode,
      flagAssetPath: flagAssetPath,
      countryShortName: countryShortName,
    ));
  }
}