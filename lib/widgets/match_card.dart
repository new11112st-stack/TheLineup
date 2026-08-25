// بطاقة المباراة — مطابقة لـ pitch-card في الموقع
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../providers/app_state.dart';
import '../utils/arabic_helpers.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'capacity_ring.dart';
import 'countdown_widget.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final match = state.match;

    if (match == null) {
      return _EmptyMatchCard();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lineStrong),
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Stack(
        children: [
          // الزوايا الزخرفية
          Positioned(top: 9, left: 9, child: _Corner(LinePosition.topLeft)),
          Positioned(top: 9, right: 9, child: _Corner(LinePosition.topRight)),
          Positioned(bottom: 9, left: 9, child: _Corner(LinePosition.bottomLeft)),
          Positioned(bottom: 9, right: 9, child: _Corner(LinePosition.bottomRight)),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(match: match),
              const SizedBox(height: 20),
              _MatchBody(match: match, state: state),
              if (match.phone.isNotEmpty) ...[
                const SizedBox(height: 14),
                _PayStrip(match: match),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

enum LinePosition { topLeft, topRight, bottomLeft, bottomRight }

class _Corner extends StatelessWidget {
  final LinePosition pos;
  const _Corner(this.pos);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 15,
      child: CustomPaint(painter: _CornerPainter(pos)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final LinePosition pos;
  _CornerPainter(this.pos);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x38EAF2E6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    switch (pos) {
      case LinePosition.topLeft:
        path.moveTo(size.width, 0);
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
        break;
      case LinePosition.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case LinePosition.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case LinePosition.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmptyMatchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // قميص شبح
          SizedBox(
            width: 64,
            height: 64 * 0.96,
            child: CustomPaint(
              painter: _GhostShirtPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Text('لا يوجد حجز مفتوح حالياً',
              style: AppTheme.heading(size: 16, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(
            'بانتظار أن ينشئ الأدمن حجزاً جديداً — ستظهر المباراة هنا تلقائياً',
            textAlign: TextAlign.center,
            style: AppTheme.body(size: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _GhostShirtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // نعيد استخدام TshirtPainter مع ghost
    // لكن لتفادي الاستيراد الدائري نرسم نسخة مبسطة هنا
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x47EAF2E6)
      ..strokeWidth = 2;
    final path = Path();
    final w = size.width, h = size.height;
    path.moveTo(w * 0.35, h * 0.10);
    path.lineTo(w * 0.15, h * 0.198);
    path.lineTo(w * 0.06, h * 0.448);
    path.lineTo(w * 0.24, h * 0.51);
    path.lineTo(w * 0.28, h * 0.427);
    path.lineTo(w * 0.28, h * 0.906);
    path.lineTo(w * 0.72, h * 0.906);
    path.lineTo(w * 0.72, h * 0.427);
    path.lineTo(w * 0.76, h * 0.51);
    path.lineTo(w * 0.94, h * 0.448);
    path.lineTo(w * 0.85, h * 0.198);
    path.lineTo(w * 0.65, h * 0.10);
    path.quadraticBezierTo(w * 0.60, h * 0.208, w * 0.50, h * 0.208);
    path.quadraticBezierTo(w * 0.40, h * 0.208, w * 0.35, h * 0.10);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopBar extends StatelessWidget {
  final MatchModel match;
  const _TopBar({required this.match});

  @override
  Widget build(BuildContext context) {
    final phase = match.phase;
    final active = context.read<AppState>().activePlayers.length;
    final full = active >= match.capacity;

    String tag;
    bool amber = false;
    if (phase == 'ended') {
      tag = 'انتهت هذه المباراة';
      amber = true;
    } else if (phase == 'live') {
      tag = 'المباراة جارية — الحجز مغلق';
      amber = true;
    } else if (full) {
      tag = 'اكتمل عدد اللاعبين';
      amber = true;
    } else {
      tag = 'التسجيل مفتوح';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // live tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: amber ? const Color(0x1AF2B63C) : const Color(0x175EE089),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: amber ? const Color(0x59F2B63C) : const Color(0x4DE5E089),
            ),
          ),
          child: Row(
            children: [
              _PulsingDot(color: amber ? AppColors.amber : AppColors.grass),
              const SizedBox(width: 8),
              Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: amber ? AppColors.amber : AppColors.grass,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Text(
            match.title,
            style: AppTheme.heading(size: 14, color: AppColors.muted, weight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _MatchBody extends StatelessWidget {
  final MatchModel match;
  final AppState state;
  const _MatchBody({required this.match, required this.state});

  @override
  Widget build(BuildContext context) {
    final dt = match.dateObj;
    final active = state.activePlayers.length;
    final confirmed = state.players.where((p) => p.status == 'confirmed').length;
    final full = active >= match.capacity;
    final remain = (match.capacity - active).clamp(0, match.capacity);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // معلومات المباراة
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fmtWeekday(dt),
                style: const TextStyle(
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.grass,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fmtFullDate(dt),
                style: const TextStyle(
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  height: 1.3,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 22,
                runSpacing: 8,
                children: [
                  _MetaItem(
                    icon: Icons.access_time_outlined,
                    child: Text(
                      ArTime.range(match.matchTime, match.matchEnd),
                      style: AppTheme.heading(size: 14, color: AppColors.ink),
                    ),
                  ),
                  _MetaItem(
                    icon: Icons.place_outlined,
                    child: Text(
                      match.venue.isEmpty ? 'غير محدد' : match.venue,
                      style: AppTheme.body(size: 14),
                    ),
                  ),
                  _MetaItem(
                    icon: Icons.sports_soccer_outlined,
                    child: Text(
                      'ملعب ${match.type == '7x7' ? '7×7' : '5×5'}',
                      style: AppTheme.body(size: 14),
                    ),
                  ),
                  _MetaItem(
                    icon: Icons.payments_outlined,
                    child: RichText(
                      text: TextSpan(
                        style: AppTheme.heading(size: 14, color: AppColors.ink),
                        children: [
                          TextSpan(text: '${match.fee} '),
                          TextSpan(text: match.currency),
                          const TextSpan(text: ' للفرد'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x12F2B63C),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x40F2B63C)),
                ),
                child: CountdownWidget(match: match),
              ),
            ],
          ),
        ),

        // الفاصل العمودي
        Container(
          width: 1,
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: CustomPaint(painter: _DashedLinePainter()),
        ),

        // حلقة المقاعد
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CapacityRing(active: active, capacity: match.capacity),
              const SizedBox(height: 5),
              if (full)
                Text(
                  'التشكيلة مكتملة',
                  style: AppTheme.body(size: 14),
                )
              else
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.body(size: 14, color: AppColors.muted),
                    children: [
                      const TextSpan(text: 'باقي '),
                      TextSpan(
                        text: '$remain',
                        style: AppTheme.heading(size: 17, color: AppColors.grass),
                      ),
                      TextSpan(text: ' ${seatWord(remain)}'),
                    ],
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                '$confirmed مؤكد · ${active - confirmed} بانتظار',
                style: AppTheme.body(size: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _MetaItem({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.faint),
        const SizedBox(width: 7),
        child,
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33EAF2E6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dashHeight = 5.0;
    const dashSpace = 4.0;
    for (double y = 0; y < size.height; y += dashHeight + dashSpace) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, y + dashHeight),
        paint,
      );
    }
    // دائرة في المنتصف
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      31,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PayStrip extends StatelessWidget {
  final MatchModel match;
  const _PayStrip({required this.match});

  @override
  Widget build(BuildContext context) {
    final cleanPhone = match.phone.replaceAll(' ', '');
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lineStrong, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_outlined, size: 18, color: AppColors.grass),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTheme.body(size: 13, color: AppColors.muted),
                children: [
                  const TextSpan(text: 'أرسل حوالة '),
                  TextSpan(
                    text: '${match.fee} ${match.currency}',
                    style: AppTheme.heading(size: 13, color: AppColors.ink),
                  ),
                  const TextSpan(text: ' إلى'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            cleanPhone,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: 'Changa',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 1,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: cleanPhone));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم نسخ الرقم'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.surface,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.grass,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Row(
                children: [
                  Icon(Icons.copy_outlined, size: 14, color: Color(0xFF07130A)),
                  SizedBox(width: 5),
                  Text(
                    'نسخ الرقم',
                    style: TextStyle(
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF07130A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
