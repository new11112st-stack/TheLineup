// شاشة التحميل — مطابقة لـ .loading في الموقع
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: CustomPaint(painter: _SplashLogoPainter()),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.appName,
              style: AppTheme.heading(size: 26, weight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.appSubtitle,
              style: AppTheme.body(size: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.grass),
                backgroundColor: Color(0x33EAF2E6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'جارٍ الاتصال بقاعدة البيانات...',
              style: AppTheme.body(size: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.grass;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 2,
      paint,
    );
    paint.color = AppColors.bg;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.26;
    final points = List<Offset>.generate(5, (i) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      return Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
    });
    final innerPoints = List<Offset>.generate(5, (i) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5 + math.pi / 5;
      final ir = r * 0.4;
      return Offset(cx + ir * math.cos(angle), cy + ir * math.sin(angle));
    });
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < 5; i++) {
      path.lineTo(innerPoints[i].dx, innerPoints[i].dy);
      path.lineTo(points[(i + 1) % 5].dx, points[(i + 1) % 5].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
