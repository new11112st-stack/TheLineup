// الحلقة الدائرية لعدد اللاعبين — مطابقة لـ ring-wrap في الموقع
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CapacityRing extends StatelessWidget {
  final int active;
  final int capacity;
  final double size;

  const CapacityRing({
    super.key,
    required this.active,
    required this.capacity,
    this.size = 126,
  });

  @override
  Widget build(BuildContext context) {
    final pct = capacity > 0 ? (active / capacity).clamp(0.0, 1.0) : 0.0;
    final full = active >= capacity;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              pct: pct,
              full: full,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.123,
                    color: AppColors.ink,
                  ),
                  children: [
                    TextSpan(text: '$active'),
                    TextSpan(
                      text: '/$capacity',
                      style: TextStyle(
                        fontSize: size * 0.075,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'لاعب',
                style: TextStyle(
                  fontSize: size * 0.054,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  final bool full;

  _RingPainter({required this.pct, required this.full});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;

    // الحلقة الخلفية
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = const Color(0x1AEAF2E6),
    );

    // الحلقة الأمامية (التقدم)
    final sweep = 2 * math.pi * pct;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = full ? AppColors.grass : AppColors.amber,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.pct != pct || oldDelegate.full != full;
  }
}
