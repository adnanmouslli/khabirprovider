import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomDropdownField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;
  final bool enabled;

  const CustomDropdownField({
    Key? key,
    required this.hintText,
    this.prefixIcon,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? AppColors.primary : const Color(0xFFF3F4F6),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: enabled ? onChanged : null,
        isExpanded: true, // هذا يحل مشكلة الـ overflow
        style: TextStyle(
          fontSize: 16,
          color: enabled ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: prefixIcon != null
              ? Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              prefixIcon,
              color: enabled ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              size: 20,
            ),
          )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.only(
            left: prefixIcon != null ? 0 : 16, // تقليل المساحة الجانبية
            right: 0, // إزالة المساحة اليمنى للسماح لـ icon بالظهور
            top: 16,
            bottom: 16,
          ),
        ),
        icon: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            Icons.keyboard_arrow_down,
            color: enabled ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            size: 20,
          ),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        menuMaxHeight: 200, // تحديد أقصى ارتفاع للقائمة المنسدلة
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Container(
              width: double.infinity,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis, // قطع النص الطويل
                maxLines: 1, // سطر واحد فقط
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}