import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Widget لدعم RTL بشكل أفضل
class RTLSupport extends StatelessWidget {
  final Widget child;

  const RTLSupport({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _getTextDirection(),
      child: child,
    );
  }

  TextDirection _getTextDirection() {
    final locale = Get.locale ?? const Locale('ar', 'SA');
    return locale.languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}

/// Extension لتسهيل استخدام RTL
extension RTLExtension on Widget {
  Widget withRTL() {
    return RTLSupport(child: this);
  }
}

/// Helper class للحصول على معلومات الاتجاه
class DirectionHelper {
  static bool get isRTL {
    final locale = Get.locale ?? const Locale('ar', 'SA');
    return locale.languageCode == 'ar';
  }

  static bool get isLTR => !isRTL;

  static TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }

  static TextAlign get textAlign {
    return isRTL ? TextAlign.right : TextAlign.left;
  }

  static EdgeInsetsGeometry paddingStart(double value) {
    return isRTL
        ? EdgeInsets.only(right: value)
        : EdgeInsets.only(left: value);
  }

  static EdgeInsetsGeometry paddingEnd(double value) {
    return isRTL
        ? EdgeInsets.only(left: value)
        : EdgeInsets.only(right: value);
  }
}