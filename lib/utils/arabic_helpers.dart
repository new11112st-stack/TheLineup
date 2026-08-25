// أدوات اللغة العربية — الجمع، تنسيق الوقت، العد التنازلي
import 'package:intl/intl.dart';

String arPlural(int n, {required String one, required String two, required String few, required String many}) {
  n = n.abs();
  if (n == 1) return one;
  if (n == 2) return two;
  if (n >= 3 && n <= 10) return few;
  return many;
}

String dayWord(int n) => arPlural(n, one: 'يوم', two: 'يومان', few: 'أيام', many: 'يوماً');
String hourWord(int n) => arPlural(n, one: 'ساعة', two: 'ساعتان', few: 'ساعات', many: 'ساعة');
String minWord(int n) => arPlural(n, one: 'دقيقة', two: 'دقيقتان', few: 'دقائق', many: 'دقيقة');
String seatWord(int n) => arPlural(n, one: 'مقعد', two: 'مقعدان', few: 'مقاعد', many: 'مقعداً');
String cardWord(int n) => arPlural(n, one: 'بطاقة', two: 'بطاقتان', few: 'بطاقات', many: 'بطاقة');
String playerWord(int n) => arPlural(n, one: 'لاعب', two: 'لاعبان', few: 'لاعبين', many: 'لاعباً');

String pad2(int n) => n.toString().padLeft(2, '0');

class ArTime {
  /// تنسيق وقت عربي: 8:30 مساءً
  static String format(String? t) {
    if (t == null || !RegExp(r'^\d{1,2}:\d{2}$').hasMatch(t)) return t ?? '';
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    String label, period;
    if (h == 0) {
      label = '12';
      period = 'صباحاً';
    } else if (h < 12) {
      label = h.toString();
      period = 'صباحاً';
    } else if (h == 12) {
      label = '12';
      period = 'ظهراً';
    } else {
      label = (h - 12).toString();
      period = 'مساءً';
    }
    return '$label:$m $period';
  }

  /// نطاق زمني: من 8:00 مساءً إلى 10:00 مساءً
  static String range(String? a, String? b) {
    if (a == null && b == null) return '';
    if (a == b) return format(a);
    final A = format(a);
    final B = format(b);
    final periodA = A.split(' ').last;
    if (periodA == B.split(' ').last) {
      return 'من ${A.replaceAll(' $periodA', '')} إلى $B';
    }
    return 'من $A إلى $B';
  }
}

/// العد التنازلي بصيغة عربية
String fmtCountdown(Duration remaining, {bool started = false}) {
  if (started || remaining.inMilliseconds <= 0) return 'انطلقت المباراة';
  final d = remaining.inDays;
  final h = remaining.inHours % 24;
  final m = remaining.inMinutes % 60;
  final s = remaining.inSeconds % 60;
  if (d > 0) {
    var s_ = 'بعد $d ${dayWord(d)}';
    if (h > 0) s_ += ' و $h ${hourWord(h)}';
    return s_;
  }
  if (h > 0) {
    var s_ = 'بعد $h ${hourWord(h)}';
    if (m > 0) s_ += ' و $m ${minWord(m)}';
    return s_;
  }
  return 'بعد ${pad2(h)}:${pad2(m)}:${pad2(s)}';
}

/// منذ متى
String timeAgo(int? ts) {
  if (ts == null) return '';
  final diff = DateTime.now().millisecondsSinceEpoch - ts;
  final m = (diff / 60000).floor();
  if (m < 1) return 'الآن';
  if (m < 60) return 'منذ $m ${minWord(m)}';
  final h = (m / 60).floor();
  if (h < 24) return 'منذ $h ${hourWord(h)}';
  return 'منذ ${(h / 24).floor()} ${dayWord((h / 24).floor())}';
}

/// تنسيق تاريخ عربي كامل
String fmtFullDate(DateTime dt) {
  return DateFormat('d MMMM y', 'ar').format(dt);
}

/// يوم الأسبوع
String fmtWeekday(DateTime dt) {
  return DateFormat('EEEE', 'ar').format(dt);
}

/// تنسيق التاريخ القصير
String fmtShortDate(DateTime dt) {
  return DateFormat('d MMM y', 'ar').format(dt);
}

/// تنسيق مختصر للتاريخ: 2025-01-15
String fmtDateInput(DateTime dt) {
  return '${dt.year}-${pad2(dt.month)}-${pad2(dt.day)}';
}

/// تنسيق الوقت: 20:30
String fmtTimeInput(DateTime dt) {
  return '${pad2(dt.hour)}:${pad2(dt.minute)}';
}
