// ثوابت المشروع — الألوان، الإعدادات، ومفاتيح Firebase
import 'package:flutter/material.dart';

class AppColors {
  // الخلفيات
  static const Color bg = Color(0xFF0B0F0C);
  static const Color surface = Color(0xFF121A14);
  static const Color surface2 = Color(0xFF0E1510);
  static const Color inputBg = Color(0xFF0D130F);

  // النصوص
  static const Color ink = Color(0xFFEAF2E6);
  static const Color muted = Color(0xFF8FA18C);
  static const Color faint = Color(0xFF5C6B5A);

  // الألوان الرئيسية
  static const Color grass = Color(0xFF5EE089);
  static const Color grassHover = Color(0xFF7BEB9F);
  static const Color amber = Color(0xFFF2B63C);
  static const Color red = Color(0xFFE5543F);
  static const Color redSoft = Color(0xFFFF9884);

  // الخطوط الفاصلة
  static const Color line = Color(0x17E2EEE0); // ~9% alpha
  static const Color lineStrong = Color(0x2BE2EEE0); // ~17% alpha
}

class AppStrings {
  static const String appName = 'التشكيلة';
  static const String appSubtitle = 'حجز مقاعد كرة القدم';
}

class StorageKeys {
  static const String mine = 'takweela_mine';
  static const String codes = 'takweela_codes';
  static const String adminSession = 'takweela_admin_session';
}

class StatusInfo {
  final String key;
  final String label;
  final Color color;
  final Color bg;
  final Color border;

  const StatusInfo({
    required this.key,
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
  });
}

class Status {
  static const StatusInfo pending = StatusInfo(
    key: 'pending',
    label: 'بانتظار التسديد',
    color: Color(0xFFE8C56A),
    bg: Color(0x12F2B63C),
    border: Color(0x59F2B63C),
  );
  static const StatusInfo review = StatusInfo(
    key: 'review',
    label: 'بانتظار المراجعة',
    color: Color(0xFFF2B63C),
    bg: Color(0x1AF2B63C),
    border: Color(0x73F2B63C),
  );
  static const StatusInfo confirmed = StatusInfo(
    key: 'confirmed',
    label: 'مؤكد',
    color: Color(0xFF5EE089),
    bg: Color(0x175EE089),
    border: Color(0x665EE089),
  );
  static const StatusInfo rejected = StatusInfo(
    key: 'rejected',
    label: 'مرفوض',
    color: Color(0xFFFF9884),
    bg: Color(0x12E5543F),
    border: Color(0x66E5543F),
  );

  static StatusInfo fromKey(String? key) {
    switch (key) {
      case 'pending':
        return pending;
      case 'review':
        return review;
      case 'confirmed':
        return confirmed;
      case 'rejected':
        return rejected;
      default:
        return pending;
    }
  }
}

class Connection {
  /// مؤشر حالة الاتصال
  static const int ok = 0;
  static const int cache = 1;
  static const int error = 2;
}
