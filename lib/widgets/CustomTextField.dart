import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool isPassword;
  final bool enabled;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTextStyles.inputLabel,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary, // Light gray border
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            enabled: enabled,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            focusNode: focusNode,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
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
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              )
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                onTap: onSuffixTap,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Icon(
                    suffixIcon,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
              )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}