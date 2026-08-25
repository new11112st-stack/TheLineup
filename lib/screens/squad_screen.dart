// شاشة التشكيلة — قائمة بجميع اللاعبين مع أرقام قمصانهم
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/arabic_helpers.dart';
import '../widgets/tshirt.dart';
import '../widgets/status_badge.dart';
import '../widgets/dashed_line.dart';

class SquadScreen extends StatelessWidget {
  const SquadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final match = state.match;
    final active = state.activePlayers.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العنوان
            _SectionHeader(
              icon: Icons.groups_outlined,
              title: 'التشكيلة',
              count: match != null ? '$active من ${match.capacity} لاعب' : null,
            ),
            const SizedBox(height: 16),
            if (match == null || state.players.isEmpty)
              _EmptySquad()
            else
              _SquadGrid(),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grass),
        const SizedBox(width: 9),
        Text(title, style: AppTheme.heading(size: 16)),
        const SizedBox(width: 12),
        const Expanded(child: DashedLine()),
        if (count != null) ...[
          const SizedBox(width: 12),
          Text(count!, style: AppTheme.heading(size: 13, color: AppColors.muted)),
        ],
      ],
    );
  }
}

class _EmptySquad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      child: Column(
        children: [
          SizedBox(
            width: 64,
            height: 64 * 0.96,
            child: CustomPaint(painter: _GhostShirtPainter()),
          ),
          const SizedBox(height: 8),
          Text(
            'التشكيلة فارغة',
            style: AppTheme.heading(size: 16, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'كن أول من يحجز مقعداً في هذه المباراة',
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

class _SquadGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: state.players.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        return _PlayerTile(
          shirtNumber: i + 1,
          player: p,
          isMine: state.isMine(p),
        );
      }).toList(),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final int shirtNumber;
  final PlayerModel player;
  final bool isMine;

  const _PlayerTile({
    required this.shirtNumber,
    required this.player,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.fromLTRB(6, 13, 6, 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Tshirt(
                number: shirtNumber,
                status: player.status,
                size: 62,
              ),
              if (isMine)
                Positioned(
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.grass,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'أضفته',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF07130A),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            player.name,
            style: AppTheme.body(size: 13, weight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          StatusBadge(status: player.status, compact: true),
        ],
      ),
    );
  }
}
