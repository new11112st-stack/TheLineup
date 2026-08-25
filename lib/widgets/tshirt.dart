// رسم قميص كرة القدم باستخدام CustomPainter — مطابق للـ SVG في الموقع
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TshirtPainter extends CustomPainter {
  final int number;
  final String status; // pending | review | confirmed | rejected | ghost

  TshirtPainter({required this.number, required this.status});

  Color get _fill {
    switch (status) {
      case 'pending':
        return const Color(0xFFDFE8DA);
      case 'review':
        return AppColors.amber;
      case 'confirmed':
        return const Color(0xFF43CD77);
      case 'rejected':
        return const Color(0xFF2B1C19);
      case 'ghost':
        return Colors.transparent;
      default:
        return const Color(0xFFDFE8DA);
    }
  }

  Color get _numColor {
    switch (status) {
      case 'pending':
        return const Color(0xFF1A2612);
      case 'review':
        return const Color(0xFF2A1C04);
      case 'confirmed':
        return const Color(0xFF04150A);
      case 'rejected':
        return AppColors.redSoft;
      case 'ghost':
        return const Color(0x2EEAF2E6);
      default:
        return const Color(0xFF1A2612);
    }
  }

  Color get _shade {
    switch (status) {
      case 'pending':
        return const Color(0x241A2612);
      case 'review':
        return const Color(0x292A1C04);
      case 'confirmed':
        return const Color(0x2E04150A);
      case 'rejected':
        return const Color(0x1FE5543F);
      default:
        return Colors.transparent;
    }
  }

  Color? get _stroke {
    if (status == 'rejected') return const Color(0x8CE5543F);
    if (status == 'ghost') return const Color(0x47EAF2E6);
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // مسار القميص — يحاكي SVG الأصلي
    final w = size.width;
    final h = size.height;

    final path = Path();
    // نقطة البداية: أعلى الكتف الأيسر
    path.moveTo(w * 0.35, h * 0.10);
    // إلى أسفل الكتف الأيسر
    path.lineTo(w * 0.15, h * 0.198);
    // إلى أسفل الجانب الأيسر (الكتف)
    path.lineTo(w * 0.06, h * 0.448);
    // إلى أسفل الفتحة اليسرى
    path.lineTo(w * 0.24, h * 0.51);
    // إلى أعلى الفتحة اليسرى
    path.lineTo(w * 0.28, h * 0.427);
    // إلى أسفل القميص الأيسر
    path.lineTo(w * 0.28, h * 0.906);
    // إلى أسفل القميص الأيمن
    path.lineTo(w * 0.72, h * 0.906);
    // إلى أعلى الفتحة اليمنى
    path.lineTo(w * 0.72, h * 0.427);
    // إلى أسفل الفتحة اليمنى
    path.lineTo(w * 0.76, h * 0.51);
    // إلى أسفل الجانب الأيمن
    path.lineTo(w * 0.94, h * 0.448);
    // إلى أسفل الكتف الأيمن
    path.lineTo(w * 0.85, h * 0.198);
    // إلى أعلى الكتف الأيمن
    path.lineTo(w * 0.65, h * 0.10);
    // منحنى الياقة
    path.quadraticBezierTo(w * 0.60, h * 0.208, w * 0.50, h * 0.208);
    path.quadraticBezierTo(w * 0.40, h * 0.208, w * 0.35, h * 0.10);
    path.close();

    // التعبئة
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _fill;

    if (status != 'ghost') {
      canvas.drawPath(path, paint);
    }

    // التظليل
    if (_shade != Colors.transparent && status != 'ghost') {
      final shadePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = _shade;

      // الظل الجانبي الأيسر
      final shadePath = Path();
      shadePath.moveTo(w * 0.06, h * 0.448);
      shadePath.lineTo(w * 0.24, h * 0.51);
      shadePath.lineTo(w * 0.20, h * 0.583);
      shadePath.lineTo(w * 0.04, h * 0.520);
      shadePath.close();
      canvas.drawPath(shadePath, shadePaint);

      // الظل الجانبي الأيمن
      final shadePath2 = Path();
      shadePath2.moveTo(w * 0.94, h * 0.448);
      shadePath2.lineTo(w * 0.76, h * 0.51);
      shadePath2.lineTo(w * 0.80, h * 0.583);
      shadePath2.lineTo(w * 0.96, h * 0.520);
      shadePath2.close();
      canvas.drawPath(shadePath2, shadePaint);

      // ظل الجانبين السفليين
      canvas.drawRect(Rect.fromLTRB(w * 0.28, h * 0.427, w * 0.33, h * 0.906), shadePaint);
      canvas.drawRect(Rect.fromLTRB(w * 0.67, h * 0.427, w * 0.72, h * 0.906), shadePaint);
    }

    // الحدود (للرفض أو الشبح)
    if (_stroke != null) {
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = _stroke!
        ..strokeWidth = 2.0;
      if (status == 'rejected') {
        strokePathWithDashes(canvas, path, strokePaint);
      } else {
        canvas.drawPath(path, strokePaint);
      }
    }

    // الرقم
    final numStr = number.toString();
    final fontSize = numStr.length > 1 ? w * 0.22 : w * 0.27;
    final textPainter = TextPainter(
      text: TextSpan(
        text: numStr,
        style: TextStyle(
          fontFamily: 'Changa',
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          color: _numColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (w - textPainter.width) / 2,
        h * 0.625 - textPainter.height / 2,
      ),
    );

    // خط الياقة
    if (status != 'ghost' && status != 'rejected') {
      final collarPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = _numColor.withOpacity(0.28)
        ..strokeWidth = 2.0;
      final collarPath = Path();
      collarPath.moveTo(w * 0.35, h * 0.10);
      collarPath.quadraticBezierTo(w * 0.40, h * 0.208, w * 0.50, h * 0.208);
      collarPath.quadraticBezierTo(w * 0.60, h * 0.208, w * 0.65, h * 0.10);
      canvas.drawPath(collarPath, collarPaint);
    }
  }

  /// رسم المسار بخطوط متقطعة
  void strokePathWithDashes(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      const dashWidth = 4.0;
      const dashGap = 3.0;
      while (distance < metric.length) {
        final len = distance + dashWidth > metric.length
            ? metric.length - distance
            : dashWidth;
        dashPath.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += dashWidth + dashGap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant TshirtPainter oldDelegate) {
    return oldDelegate.number != number || oldDelegate.status != status;
  }
}

/// ويدجت القميص الجاهز
class Tshirt extends StatelessWidget {
  final int number;
  final String status;
  final double size;

  const Tshirt({
    super.key,
    required this.number,
    required this.status,
    this.size = 62,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.96,
      child: CustomPaint(
        painter: TshirtPainter(number: number, status: status),
      ),
    );
  }
}
