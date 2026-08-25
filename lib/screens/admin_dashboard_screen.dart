// لوحة تحكم الأدمن — الإحصائيات + الحجوزات + الإعدادات
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../providers/app_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/arabic_helpers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/tshirt.dart';
import '../../widgets/status_badge.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final match = state.match;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (match != null && match.phase != 'before')
              _PhaseNotice(phase: match.phase),
            if (match == null)
              _NoMatchNotice()
            else ...[
              _StatsBar(),
              const SizedBox(height: 22),
              _BookingsSection(),
              const SizedBox(height: 22),
              _HistorySection(),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhaseNotice extends StatelessWidget {
  final String phase;
  const _PhaseNotice({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0FF2B63C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x66F2B63C), style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              phase == 'live'
                  ? 'بدأت هذه المباراة — الحجز مغلق تلقائياً أمام اللاعبين. أنشئ حجزاً جديداً متى شئت.'
                  : 'انتهى وقت هذه المباراة — أنشئ حجزاً جديداً لفتح التسجيل من جديد.',
              style: AppTheme.body(size: 13, color: AppColors.amber, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMatchNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      child: Column(
        children: [
          const Icon(Icons.event_available_outlined, size: 42, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            'لا يوجد حجز نشط حالياً.',
            style: AppTheme.heading(size: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'أنشئ حجزاً جديداً ليبدأ اللاعبون بالتسجيل فوراً.',
            textAlign: TextAlign.center,
            style: AppTheme.body(size: 13, color: AppColors.muted, height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final match = state.match!;
    final players = state.players;
    final conf = players.where((p) => p.status == 'confirmed').length;
    final rev = players.where((p) => p.status == 'review').length;
    final rej = players.where((p) => p.status == 'rejected').length;
    final available = (match.capacity - state.activePlayers.length).clamp(0, match.capacity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _Stat(value: '$conf', sub: '/${match.capacity}', label: 'حجز مؤكد'),
          _verticalDivider(),
          _Stat(value: '${conf * match.fee}', label: '${match.currency} محصّلة'),
          _verticalDivider(),
          _Stat(value: '$rev', label: 'بانتظار المراجعة'),
          _verticalDivider(),
          _Stat(value: '$rej', label: 'مرفوض'),
          _verticalDivider(),
          _Stat(value: '$available', label: 'مقاعد متاحة'),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.line,
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String? sub;
  final String label;

  const _Stat({required this.value, this.sub, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColors.ink,
                ),
                children: [
                  TextSpan(text: value),
                  if (sub != null)
                    TextSpan(
                      text: sub,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.body(size: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filters = [
      ('all', 'الكل'),
      ('pending', 'بانتظار التسديد'),
      ('review', 'بانتظار المراجعة'),
      ('confirmed', 'مؤكد'),
      ('rejected', 'مرفوض'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt_outlined, size: 20, color: AppColors.grass),
              const SizedBox(width: 9),
              Text('الحجوزات', style: AppTheme.heading(size: 16)),
              const Spacer(),
              Wrap(
                spacing: 7,
                children: filters.map((f) {
                  final isActive = state.adminFilter == f.$1;
                  return GestureDetector(
                    onTap: () {
                      state.adminFilter = f.$1;
                      // استدعاء notifyListeners — نحتاج طريقة في AppState
                      state.setAdminFilter(f.$1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0x1F5EE089)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isActive ? AppColors.grass : AppColors.lineStrong,
                        ),
                      ),
                      child: Text(
                        f.$2,
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? AppColors.grass : AppColors.muted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BookingsList(),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.players
        .where((p) => state.adminFilter == 'all' || p.status == state.adminFilter)
        .toList();

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(26),
        child: Text(
          'لا توجد حجوزات ضمن هذا التصنيف بعد.',
          textAlign: TextAlign.center,
          style: AppTheme.body(size: 13, color: AppColors.muted),
        ),
      );
    }

    return Column(
      children: list.map((p) => _BookingTile(player: p)).toList(),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final PlayerModel player;
  const _BookingTile({required this.player});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = player;
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Tshirt(
                number: state.shirtNum(p),
                status: p.status,
                size: 42,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            p.name,
                            style: AppTheme.heading(size: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        StatusBadge(status: p.status, compact: true),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (p.phone.isNotEmpty) ...[
                          Text(
                            p.phone,
                            textDirection: TextDirection.ltr,
                            style: AppTheme.body(size: 12, color: AppColors.muted),
                          ),
                          const Text(' · ', style: TextStyle(color: AppColors.faint)),
                        ],
                        Text(
                          'انضم ${timeAgo(p.joinedAt)}',
                          style: AppTheme.body(size: 12, color: AppColors.muted),
                        ),
                        if (p.code.isNotEmpty) ...[
                          const Text(' · ', style: TextStyle(color: AppColors.faint)),
                          const Text('رمز ', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                          Text(
                            p.code,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontFamily: 'Changa',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              fontSize: 12,
                              color: AppColors.grass,
                            ),
                          ),
                        ],
                        if (p.receiptAt != null) ...[
                          const Text(' · ', style: TextStyle(color: AppColors.faint)),
                          Text(
                            'رفع الإشعار ${timeAgo(p.receiptAt)}',
                            style: AppTheme.body(size: 12, color: AppColors.muted),
                          ),
                        ],
                      ],
                    ),
                    if (p.status == 'rejected' && p.note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.cancel_outlined, size: 14, color: AppColors.redSoft),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              p.note,
                              style: const TextStyle(fontSize: 12, color: AppColors.redSoft),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (p.receipt != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showReceipt(context, p),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.lineStrong),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.memory(
                      _dataUrlToBytes(p.receipt!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.inputBg,
                        child: const Icon(Icons.broken_image_outlined, color: AppColors.faint),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // أزرار الإجراءات
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (p.status != 'confirmed')
                AppButton(
                  label: 'قبول',
                  icon: Icons.check,
                  small: true,
                  onPressed: () async {
                    final ok = await state.acceptPlayer(p.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'تم تأكيد حجز ${p.name}' : 'تعذّر التنفيذ'),
                        backgroundColor: ok ? AppColors.surface : AppColors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              if (p.status != 'rejected')
                AppButton(
                  label: 'رفض',
                  icon: Icons.close,
                  style: BtnStyle.danger,
                  small: true,
                  onPressed: () => _showRejectDialog(context, state, p),
                ),
              AppButton(
                icon: Icons.delete_outline,
                style: BtnStyle.ghost,
                iconOnly: true,
                small: true,
                onPressed: () => _showDeleteDialog(context, state, p),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReceipt(BuildContext context, PlayerModel p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ReceiptViewer(
          name: p.name,
          dataUrl: p.receipt!,
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AppState state, PlayerModel p) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.red),
            const SizedBox(width: 10),
            Text('رفض الحجز', style: AppTheme.heading(size: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: AppTheme.body(size: 13, color: AppColors.muted, height: 1.7),
                children: [
                  const TextSpan(text: 'رفض حجز '),
                  TextSpan(
                    text: p.name,
                    style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '. يمكنك كتابة سبب يظهر للاعب على بطاقته.'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLength: 80,
              decoration: const InputDecoration(
                hintText: 'سبب الرفض (اختياري)',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'تراجع',
            style: BtnStyle.ghost,
            small: true,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'تأكيد الرفض',
            icon: Icons.close,
            style: BtnStyle.danger,
            small: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await state.rejectPlayer(p.id, note: reasonCtrl.text.trim());
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'تم رفض حجز ${p.name}' : 'تعذّر التنفيذ'),
                  backgroundColor: ok ? AppColors.surface : AppColors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppState state, PlayerModel p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: AppColors.red),
            const SizedBox(width: 10),
            Text('حذف الحجز', style: AppTheme.heading(size: 18)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: AppTheme.body(size: 13, color: AppColors.muted, height: 1.7),
            children: [
              const TextSpan(text: 'سيتم حذف '),
              TextSpan(
                text: p.name,
                style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' من التشكيلة نهائياً وتحرير مقعده.'),
            ],
          ),
        ),
        actions: [
          AppButton(
            label: 'تراجع',
            style: BtnStyle.ghost,
            small: true,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'نعم، احذفه',
            icon: Icons.delete_outline,
            style: BtnStyle.danger,
            small: true,
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await state.deletePlayer(p.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'تم حذف الحجز' : 'تعذّر التنفيذ'),
                  backgroundColor: ok ? AppColors.surface : AppColors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Uint8List _dataUrlToBytes(String dataUrl) {
    final b64 = dataUrl.split(',').last;
    return base64Decode(b64);
  }
}

class _ReceiptViewer extends StatelessWidget {
  final String name;
  final String dataUrl;

  const _ReceiptViewer({required this.name, required this.dataUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('إشعار تحويل — $name'),
        backgroundColor: AppColors.bg,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(
            _dataUrlToBytes(dataUrl),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Uint8List _dataUrlToBytes(String dataUrl) {
    final b64 = dataUrl.split(',').last;
    return base64Decode(b64);
  }
}

class _HistorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final archived = state.archived;

    if (archived.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.archive_outlined, size: 20, color: AppColors.grass),
              const SizedBox(width: 9),
              Text('الحجوزات السابقة', style: AppTheme.heading(size: 16)),
              const Spacer(),
              Text('${archived.length} حجز', style: AppTheme.heading(size: 13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: archived.map((m) => _HistoryRow(match: m)).toList(),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final MatchModel match;
  const _HistoryRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final m = match;
    final dateStr = fmtFullDate(m.dateObj);
    final summary = m.summary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: AppTheme.heading(size: 14)),
                const SizedBox(height: 2),
                Text(
                  '${m.title} · ${ArTime.range(m.matchTime, m.matchEnd)}${m.venue.isNotEmpty ? ' · ${m.venue}' : ''}',
                  style: AppTheme.body(size: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 16,
            children: [
              _StatItem(
                icon: Icons.groups_outlined,
                value: '${summary?.players ?? 0}/${m.capacity}',
              ),
              _StatItem(
                icon: Icons.check_circle_outline,
                value: '${summary?.confirmed ?? 0}',
                label: 'مؤكد',
              ),
              _StatItem(
                icon: Icons.payments_outlined,
                value: '${summary?.collected ?? 0}',
                label: m.currency,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String? label;

  const _StatItem({required this.icon, required this.value, this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.faint),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Changa',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.ink,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 4),
          Text(label!, style: AppTheme.body(size: 12, color: AppColors.muted)),
        ],
      ],
    );
  }
}
