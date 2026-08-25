// شاشة بطاقتي — قائمة بحجوزات اللاعب الحالية
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/arabic_helpers.dart';
import '../widgets/player_card.dart';
import '../widgets/dashed_line.dart';

class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final myPlayers = state.myPlayers;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              icon: Icons.badge_outlined,
              title: 'بطاقاتك',
              count: myPlayers.isNotEmpty
                  ? '${myPlayers.length} ${cardWord(myPlayers.length)}'
                  : null,
            ),
            const SizedBox(height: 16),
            if (state.match == null || myPlayers.isEmpty)
              _EmptyCards()
            else
              Column(
                children: List.generate(myPlayers.length, (i) {
                  final p = myPlayers[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == myPlayers.length - 1 ? 0 : 12),
                    child: PlayerCard(player: p),
                  );
                }),
              ),
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

class _EmptyCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(36),
      child: Column(
        children: [
          Icon(
            state.match == null ? Icons.event_busy_outlined : Icons.badge_outlined,
            size: 42,
            color: AppColors.faint,
          ),
          const SizedBox(height: 12),
          Text(
            state.match == null ? 'لا يوجد حجز مفتوح' : 'لا توجد بطاقات لك',
            style: AppTheme.heading(size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            state.match == null
                ? 'بانتظار أن ينشئ الأدمن حجزاً جديداً'
                : 'انتقل لتبويب «الرئيسية» واحجز مقعدك — ستظهر بطاقتك هنا',
            textAlign: TextAlign.center,
            style: AppTheme.body(size: 13, color: AppColors.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}
