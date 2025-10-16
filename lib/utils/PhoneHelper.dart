class PhoneHelper {
  // لاحقة عمان
  static const String omanCountryCode = '+968';

  // أرقام بداية الهواتف المحمولة العمانية
  static const List<String> validOmanMobilePrefixes = [
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99', // Omantel
    '77', '78', '79', '75' , '72' , '71' // Ooredoo
  ];

  // أرقام بداية الهواتف الثابتة العمانية
  static const List<String> validOmanLandlinePrefixes = [
    '24', '25', '26', '27', // مسقط
    '23', // الباطنة
    '25', // الداخلية
    '27', // الشرقية
    '23', // الظاهرة
    '26', // ظفار
    '26', // مسندم
    '23', // الوسطى
  ];
  
  /// تنظيف رقم الهاتف من الرموز والمسافات
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// التحقق من صحة رقم الهاتف العماني
  static bool isValidOmanPhone(String phone) {
    String cleanPhone = cleanPhoneNumber(phone);

    // إزالة اللاحقة إذا كانت موجودة
    if (cleanPhone.startsWith(omanCountryCode)) {
      cleanPhone = cleanPhone.substring(4);
    }

    // التحقق من طول الرقم (8 أرقام)
    if (cleanPhone.length != 8) {
      return false;
    }

    // التحقق من بداية الرقم
    String prefix = cleanPhone.substring(0, 2);
    return 
    validOmanMobilePrefixes.contains(prefix) ||
        validOmanLandlinePrefixes.contains(prefix);
  }

  /// إضافة اللاحقة العمانية إذا لم تكن موجودة
  static String formatOmanPhone(String phone) {
    String cleanPhone = cleanPhoneNumber(phone);

    // إذا كان الرقم يحتوي على لاحقة عمان بالفعل
    if (cleanPhone.startsWith(omanCountryCode)) {
      return cleanPhone;
    }

    // إذا كان الرقم يبدأ بـ 968 (بدون +)
    if (cleanPhone.startsWith('968') && cleanPhone.length == 11) {
      return '+$cleanPhone';
    }

    // إذا كان الرقم عماني صالح (8 أرقام)
    if (cleanPhone.length == 8 && isValidOmanPhone(cleanPhone)) {
      return '$omanCountryCode$cleanPhone';
    }

    // إذا كان الرقم يبدأ بـ 00968
    if (cleanPhone.startsWith('00968') && cleanPhone.length == 13) {
      return '+${cleanPhone.substring(2)}';
    }

    return cleanPhone;
  }

  /// تنسيق الرقم للعرض (مع مسافات)
  static String displayFormat(String phone) {
    String formattedPhone = formatOmanPhone(phone);

    if (formattedPhone.startsWith(omanCountryCode)) {
      String number = formattedPhone.substring(4);
      if (number.length == 8) {
        return '$omanCountryCode ${number.substring(0, 4)} ${number.substring(4)}';
      }
    }

    return formattedPhone;
  }

  /// الحصول على رسالة خطأ مناسبة
  static String? getPhoneErrorMessage(String phone, String locale) {
    if (phone.isEmpty) {
      return locale == 'ar'
          ? 'يرجى إدخال رقم الهاتف'
          : 'Please enter phone number';
    }

    String cleanPhone = cleanPhoneNumber(phone);

    // إزالة اللاحقة للتحقق
    if (cleanPhone.startsWith(omanCountryCode)) {
      cleanPhone = cleanPhone.substring(4);
    } else if (cleanPhone.startsWith('968')) {
      cleanPhone = cleanPhone.substring(3);
    } else if (cleanPhone.startsWith('00968')) {
      cleanPhone = cleanPhone.substring(5);
    }

    if (cleanPhone.length != 8) {
      return locale == 'ar'
          ? 'رقم الهاتف يجب أن يكون 8 أرقام'
          : 'Phone number must be 8 digits';
    }

    String prefix = cleanPhone.substring(0, 2);
    if (!validOmanMobilePrefixes.contains(prefix) &&
        !validOmanLandlinePrefixes.contains(prefix)) {
      return locale == 'ar' ? 'رقم هاتف غير صحيح' : 'Invalid phone number';
    }

    return null;
  }
}
