// أدوات التحقق من المدخلات
class Validators {
  static final RegExp _codeRe = RegExp(r'^[A-Z0-9]{4,8}$');

  /// تنقية الرمز: أحرف كبيرة وأرقام لاتينية فقط
  static String normCode(String? c) {
    if (c == null) return '';
    final cleaned = c.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return cleaned.length > 8 ? cleaned.substring(0, 8) : cleaned;
  }

  /// التحقق من صحة الرمز
  static bool isValidCode(String? code) {
    if (code == null || code.isEmpty) return false;
    return _codeRe.hasMatch(code);
  }

  /// قص سلسلة نصية إلى طول أقصى
  static String clamp(String? s, int max) {
    if (s == null) return '';
    if (s.length <= max) return s;
    return s.substring(0, max);
  }

  /// قيمة عددية محصورة
  static int clampInt(dynamic v, int min, int max, int def) {
    final n = int.tryParse('$v');
    if (n == null) return def;
    if (n < min) return min;
    if (n > max) return max;
    return n;
  }
}
