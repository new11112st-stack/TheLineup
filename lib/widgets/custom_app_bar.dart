// الشريط العلوي — شعار + اسم التطبيق + حالة الاتصال + زر الأدمن
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAdminTap;
  final bool showAdminButton;

  const CustomAppBar({
    super.key,
    this.onAdminTap,
    this.showAdminButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return AppBar(
      backgroundColor: AppColors.bg.withOpacity(0.85),
      elevation: 0,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // الشعار
          SizedBox(
            width: 32,
            height: 32,
            child: CustomPaint(painter: _LogoPainter()),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: AppTheme.heading(size: 20, weight: FontWeight.w800),
              ),
              Text(
                AppStrings.appSubtitle,
                style: AppTheme.body(size: 11, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // حالة الاتصال
        _LiveBadge(state: state),
        const SizedBox(width: 9),
        // زر الأدمن
        if (showAdminButton)
          GestureDetector(
            onTap: onAdminTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lineStrong),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Icon(
                    state.adminUnlocked ? Icons.dashboard_outlined : Icons.shield_outlined,
                    size: 16,
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.adminUnlocked ? 'العودة للوحة' : 'لوحة الأدمن',
                    style: AppTheme.heading(size: 13, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _LiveBadge extends StatelessWidget {
  final AppState state;
  const _LiveBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.connection < 0) {
      return _Badge(
        text: 'الاتصال...',
        color: AppColors.muted,
        bg: const Color(0x05FFFFFF),
        borderColor: AppColors.lineStrong,
        pulse: true,
      );
    }
    if (state.connection == Connection.ok) {
      return _Badge(
        text: 'مباشر',
        color: AppColors.grass,
        bg: const Color(0x125EE089),
        borderColor: const Color(0x595EE089),
        pulse: true,
      );
    }
    if (state.connection == Connection.cache) {
      return _Badge(
        text: 'من الذاكرة المؤقتة',
        icon: Icons.storage_outlined,
        color: AppColors.amber,
        bg: const Color(0x12F2B63C),
        borderColor: const Color(0x66F2B63C),
      );
    }
    return _Badge(
      text: 'انقطع الاتصال',
      icon: Icons.wifi_off_outlined,
      color: AppColors.redSoft,
      bg: const Color(0x12E5543F),
      borderColor: const Color(0x66E5543F),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color bg;
  final Color borderColor;
  final bool pulse;

  const _Badge({
    required this.text,
    this.icon,
    required this.color,
    required this.bg,
    required this.borderColor,
    this.pulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 13, color: color)
          else if (pulse)
            _Pulse(color: color),
          if (icon != null || pulse) const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pulse extends StatefulWidget {
  final Color color;
  const _Pulse({required this.color});

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
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

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // الدائرة الخضراء
    paint.color = AppColors.grass;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 1,
      paint,
    );

    // النجمة الخماسية الداخلية (غامقة)
    paint.color = AppColors.bg;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.28;
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

    // خطوط بسيطة حول النجمة (decorative)
    paint.color = AppColors.bg;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    paint.strokeCap = StrokeCap.round;
    // 5 خطوط
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      final p1 = Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
      final p2 = Offset(cx + (r + 4) * math.cos(angle), cy + (r + 4) * math.sin(angle));
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
