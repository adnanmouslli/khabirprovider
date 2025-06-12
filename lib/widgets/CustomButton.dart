import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final double? elevation;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.fontSize,
    this.padding,
    this.enabled = true,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: isOutlined ? _buildOutlinedButton() : _buildElevatedButton(),
    );
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: (isLoading || !enabled) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        elevation: elevation,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        disabledBackgroundColor: AppColors.greyLight,
        disabledForegroundColor: AppColors.textMuted,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: (isLoading || !enabled) ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: backgroundColor ?? AppColors.primary,
        side: BorderSide(
          color: (isLoading || !enabled)
              ? AppColors.greyLight
              : backgroundColor ?? AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Colors.transparent,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined
                ? (backgroundColor ?? AppColors.primary)
                : (textColor ?? Colors.white),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: _getContentColor(),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(),
      textAlign: TextAlign.center,
    );
  }

  Color _getContentColor() {
    if (!enabled) {
      return AppColors.textMuted;
    }

    if (isOutlined) {
      return textColor ?? backgroundColor ?? AppColors.primary;
    }

    return textColor ?? Colors.white;
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle = AppTextStyles.buttonMedium;

    // تطبيق حجم الخط المخصص
    if (fontSize != null) {
      baseStyle = baseStyle.copyWith(fontSize: fontSize);
    }

    // تطبيق اللون المناسب
    Color textColorToUse = _getContentColor();

    return baseStyle.copyWith(
      color: textColorToUse,
      fontWeight: FontWeight.w600,
    );
  }
}

// أزرار مخصصة جاهزة للاستخدام
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      icon: icon,
      backgroundColor: AppColors.primary,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      icon: icon,
      isOutlined: true,
      backgroundColor: AppColors.primary,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const DangerButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      icon: icon,
      backgroundColor: AppColors.error,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const SuccessButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      icon: icon,
      backgroundColor: AppColors.success,
    );
  }
}

class SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final bool isOutlined;
  final IconData? icon;

  const SmallButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.isOutlined = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? AppColors.primary,
      isOutlined: isOutlined,
      icon: icon,
      height: 40,
      fontSize: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool isLoading;

  const IconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size / 4),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              iconColor ?? Colors.white,
            ),
          ),
        )
            : Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}