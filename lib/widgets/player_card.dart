// بطاقة اللاعب — مطابقة لـ my-card في الموقع
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../providers/app_state.dart';
import '../utils/arabic_helpers.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/validators.dart';
import 'app_button.dart';
import 'status_badge.dart';
import 'tshirt.dart';

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final bool flash;

  const PlayerCard({super.key, required this.player, this.flash = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final match = state.match;
    if (match == null) return const SizedBox.shrink();

    final info = Status.fromKey(player.status);
    final shirtNumber = state.shirtNum(player);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: info.bg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: info.border),
        boxShadow: flash
            ? [
                BoxShadow(
                  color: AppColors.grass.withOpacity(0.55),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الرأس: القميص + الاسم + الحالة
          Row(
            children: [
              Tshirt(number: shirtNumber, status: player.status, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: AppTheme.heading(size: 17),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (player.phone.isNotEmpty)
                      Text(
                        player.phone,
                        textDirection: TextDirection.ltr,
                        style: AppTheme.body(size: 12, color: AppColors.muted),
                      )
                    else
                      Text(
                        'رمزك مفتاح بطاقتك في أي جهاز',
                        style: AppTheme.body(size: 12, color: AppColors.muted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: player.status),
            ],
          ),

          // رمز اللاعب الخاص
          if (player.code.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.key_outlined, size: 14, color: AppColors.faint),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'رمزك الخاص — يعبّئ بياناتك تلقائياً في أي حجز قادم:',
                    style: AppTheme.body(size: 12, color: AppColors.muted),
                  ),
                ),
                const SizedBox(width: 7),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: player.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم نسخ رمز اللاعب'),
                        backgroundColor: AppColors.surface,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        player.code,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontFamily: 'Changa',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: AppColors.grass,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.copy_outlined, size: 13, color: AppColors.faint),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // الرسالة
          const SizedBox(height: 13),
          _StatusMessage(player: player, match: match),

          // الأزرار
          const SizedBox(height: 13),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: _buildActions(context, state),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, AppState state) {
    final actions = <Widget>[];
    if (player.status == 'pending' || player.status == 'rejected') {
      actions.add(AppButton(
        label: 'رفع إشعار التحويل',
        icon: Icons.upload_outlined,
        small: true,
        onPressed: () async {
          final ok = await state.uploadReceiptFromGallery(player.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ok
                  ? 'تم رفع إشعار ${player.name} — بانتظار المراجعة'
                  : 'تعذّر رفع الإشعار'),
              backgroundColor: ok ? AppColors.surface : AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ));
    }
    if (player.status == 'review') {
      actions.add(AppButton(
        label: 'استبدال الإشعار',
        icon: Icons.restart_alt_outlined,
        style: BtnStyle.ghost,
        small: true,
        onPressed: () async {
          final ok = await state.uploadReceiptFromGallery(player.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ok ? 'تم استبدال الإشعار' : 'تعذّر رفع الإشعار'),
              backgroundColor: ok ? AppColors.surface : AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ));
    }
    actions.add(AppButton(
      label: 'إزالة',
      icon: Icons.person_remove_outlined,
      style: BtnStyle.dangerText,
      small: true,
      onPressed: () => _confirmRemove(context, state),
    ));
    return actions;
  }

  void _confirmRemove(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.person_remove_outlined, color: AppColors.red),
            const SizedBox(width: 10),
            Text('إزالة اللاعب', style: AppTheme.heading(size: 18)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: AppTheme.body(size: 14, color: AppColors.muted, height: 1.7),
            children: [
              const TextSpan(text: 'سيُحذف مقعد '),
              TextSpan(
                text: player.name,
                style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' من التشكيلة ويتاح للاعبين الآخرين.'),
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
            label: 'نعم، أزِله',
            icon: Icons.check,
            style: BtnStyle.danger,
            small: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await state.removePlayer(player.id);
            },
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final PlayerModel player;
  final MatchModel match;

  const _StatusMessage({required this.player, required this.match});

  @override
  Widget build(BuildContext context) {
    final (icon, message) = _build();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            message,
            style: AppTheme.body(size: 13, color: AppColors.muted, height: 1.7),
          ),
        ),
      ],
    );
  }

  (IconData, InlineSpan) _build() {
    switch (player.status) {
      case 'pending':
        return (
          Icons.hourglass_empty_outlined,
          TextSpan(children: [
            const TextSpan(text: 'مقعد '),
            TextSpan(
              text: player.name,
              style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' محجوز مؤقتاً. أرسل مبلغ '),
            TextSpan(
              text: '${match.fee} ${match.currency}',
              style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' إلى رقم الأدمن أعلاه، ثم ارفع إشعار التحويل من هذه البطاقة.'),
          ]),
        );
      case 'review':
        return (
          Icons.hourglass_top_outlined,
          TextSpan(children: [
            const TextSpan(text: 'استلمنا إشعار تحويل '),
            TextSpan(
              text: player.name,
              style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ${timeAgo(player.receiptAt ?? player.joinedAt)}. سيراجعه الأدمن وتظهر النتيجة هنا فوراً.'),
          ]),
        );
      case 'confirmed':
        return (
          Icons.check_circle_outline,
          TextSpan(children: [
            const TextSpan(text: 'حجز '),
            TextSpan(
              text: player.name,
              style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' '),
            const TextSpan(
              text: 'مؤكد',
              style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ومقعده مضمون في «${match.title}». نراه على الملعب!'),
          ]),
        );
      case 'rejected':
        return (
          Icons.cancel_outlined,
          TextSpan(children: [
            TextSpan(text: 'رُفض إشعار تحويل ${player.name}'),
            if (player.note.isNotEmpty)
              TextSpan(
                text: ' — السبب: ${player.note}',
                style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
              ),
            const TextSpan(text: '. يمكنك رفع إشعار جديد بعد التأكد من التحويل.'),
          ]),
        );
      default:
        return (Icons.info_outline, const TextSpan(text: ''));
    }
  }
}
