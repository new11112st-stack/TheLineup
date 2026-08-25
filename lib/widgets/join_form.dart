// نموذج الحجز — مع منطق البحث عن الرمز في الملفات المحفوظة
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../models/app_config.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/validators.dart';
import '../utils/arabic_helpers.dart';
import 'app_button.dart';
import 'dashed_line.dart';

class JoinForm extends StatefulWidget {
  const JoinForm({super.key});

  @override
  State<JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Timer? _lookupTimer;
  bool _viewMode = false;
  String? _existingPlayerId;
  ProfileLookup? _lookup;
  bool _profileLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _lookupTimer?.cancel();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    final cleaned = Validators.normCode(value);
    if (cleaned != value) {
      _codeCtrl.value = _codeCtrl.value.copyWith(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }

    final state = context.read<AppState>();

    // فحص فوري: حجز موجود في المباراة
    final inMatch = state.players.cast<PlayerModel?>().firstWhere(
      (p) => p != null && Validators.normCode(p.code) == cleaned,
      orElse: () => null,
    );

    if (Validators.isValidCode(cleaned) && inMatch != null) {
      setState(() {
        _viewMode = true;
        _existingPlayerId = inMatch.id;
        _lookup = null;
      });
      return;
    }

    // فحص الملف المحفوظ
    setState(() {
      _viewMode = false;
      _existingPlayerId = null;
    });

    if (!Validators.isValidCode(cleaned)) {
      setState(() => _lookup = null);
      return;
    }

    // بحث مؤجل في الملفات المحفوظة
    _lookupTimer?.cancel();
    setState(() => _profileLoading = true);
    _lookupTimer = Timer(const Duration(milliseconds: 450), () async {
      await state.lookupProfile(cleaned);
      if (!mounted) return;
      final result = state.joinProfile;
      setState(() {
        _lookup = result;
        _profileLoading = false;
        if (result != null && result.found) {
          _nameCtrl.text = result.name;
          _phoneCtrl.text = result.phone;
        }
      });
    });
  }

  void _submit() async {
    final state = context.read<AppState>();
    final code = _codeCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    final result = await state.addPlayer(code: code, name: name, phone: phone);

    if (!mounted) return;

    if (!result.ok && result.err != 'existing') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.err ?? 'حدث خطأ'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (result.err == 'existing') {
      // الرمز له حجز بالفعل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أهلاً بعودتك — بطاقتك جاهزة'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // نجاح — نعرض نافذة الرمز
      _showBookedModal(result.playerId!, code.toUpperCase());
    }

    // إعادة تعيين الحقول
    _codeCtrl.clear();
    _nameCtrl.clear();
    _phoneCtrl.clear();
    setState(() {
      _viewMode = false;
      _existingPlayerId = null;
      _lookup = null;
    });
  }

  void _showBookedModal(String playerId, String code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _BookedSheet(
        playerId: playerId,
        code: code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final match = state.match;

    if (match == null) {
      return _InfoCard(
        icon: Icons.hourglass_empty_outlined,
        title: 'لا يوجد حجز مفتوح حالياً',
        subtitle: 'بانتظار أن ينشئ الأدمن حجزاً جديداً — تابع الصفحة وستفتح تلقائياً.',
        iconColor: AppColors.amber,
      );
    }

    final phase = match.phase;
    if (phase == 'live' || phase == 'ended') {
      return _InfoCard(
        icon: Icons.lock_outline,
        title: phase == 'live'
            ? 'الحجز مغلق — المباراة جارية الآن'
            : 'الحجز مغلق — انتهت هذه المباراة',
        subtitle: 'بانتظار أن ينشئ الأدمن حجزاً جديداً، وستظهر المباراة القادمة هنا تلقائياً.',
        iconColor: AppColors.amber,
      );
    }

    if (state.activePlayers.length >= match.capacity) {
      return _InfoCard(
        icon: Icons.groups_outlined,
        title: 'اكتمل عدد اللاعبين (${state.activePlayers.length}/${match.capacity})',
        subtitle: 'جميع مقاعد هذه المباراة محجوزة. تواصل مع الأدمن لأي مقعد يصبح شاغراً.',
        iconColor: AppColors.amber,
      );
    }

    final added = state.myPlayers.isNotEmpty;
    final label = added ? 'إضافة لاعب' : 'انضم للتشكيلة';

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
          _SectionHeader(
            icon: Icons.person_add_outlined,
            title: added ? 'أضف لاعباً آخر' : 'احجز مقعدك',
            count: '${(match.capacity - state.activePlayers.length).clamp(0, match.capacity)} مقاعد متاحة',
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _codeCtrl,
            hint: 'رمزك (مثال A7BK)',
            maxLength: 8,
            textCapitalization: TextCapitalization.characters,
            onChanged: _onCodeChanged,
            icon: Icons.key_outlined,
            hintColor: AppColors.faint,
            isCode: true,
          ),
          const SizedBox(height: 10),
          if (!_viewMode) ...[
            _buildField(
              controller: _nameCtrl,
              hint: 'الاسم الكامل',
              maxLength: 30,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 10),
            _buildField(
              controller: _phoneCtrl,
              hint: 'رقم الهاتف (اختياري)',
              maxLength: 20,
              icon: Icons.phone_outlined,
              isPhone: true,
            ),
          ],
          if (_lookup != null && _lookup!.found)
            _StatusBanner(
              message: 'أهلاً بعودتك ${_lookup!.name} — بياناتك معبّأة، اضغط «احجز الآن»',
              type: _StatusType.ok,
            ),
          if (_lookup != null && !_lookup!.found && _codeCtrl.text.isNotEmpty)
            _StatusBanner(
              message: 'رمز جديد — اكتب الاسم والرقم وسيُحفظان مع رمزك للمباريات القادمة.',
              type: _StatusType.info,
            ),
          if (_profileLoading && _lookup == null)
            _StatusBanner(
              message: 'جارٍ البحث في ملفاتك المحفوظة...',
              type: _StatusType.info,
            ),
          if (_viewMode && _existingPlayerId != null)
            _StatusBanner(
              message: 'رمزك معروف — لديك حجز في هذه المباراة. اضغط «عرض البطاقة».',
              type: _StatusType.ok,
            ),
          const SizedBox(height: 14),
          if (_viewMode && _existingPlayerId != null)
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'عرض البطاقة',
                icon: Icons.badge_outlined,
                onPressed: () {
                  // الانتقال لتبويب بطاقتي
                  state.resetProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('بطاقتك في تبويب «بطاقتي»'),
                      backgroundColor: AppColors.surface,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: label,
                icon: Icons.person_add_outlined,
                onPressed: _submit,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.faint),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.body(size: 12, color: AppColors.muted, height: 1.8),
                    children: [
                      const TextSpan(
                        text: 'الرمز مفتاحك الشخصي: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: 'اكتب رمزك (4–8 أحرف إنجليزية أو أرقام). إن سبق لك الحجز سابقاً ستُعبّأ بياناتك تلقائياً ويختفي حقل الاسم والرقم — وإن كان لديك حجز في هذه المباراة أصلاً يتحول الزر إلى «عرض البطاقة». لإضافة لاعب آخر امسح الرمز واكتب رمزاً جديداً مع بياناته. يُغلق التسجيل تلقائياً عند بدء وقت المباراة.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLength = 100,
    IconData? icon,
    Color? hintColor,
    bool isCode = false,
    bool isPhone = false,
    ValueChanged<String>? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      textDirection: isCode || isPhone ? TextDirection.ltr : TextDirection.rtl,
      textAlign: isCode ? TextAlign.center : (isPhone ? TextAlign.left : TextAlign.right),
      keyboardType: isPhone
          ? TextInputType.phone
          : isCode
              ? TextInputType.text
              : TextInputType.name,
      style: isCode
          ? const TextStyle(
              fontFamily: 'Changa',
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppColors.ink,
            )
          : AppTheme.body(size: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTheme.body(size: 14, color: hintColor ?? AppColors.faint),
        counterText: '',
        prefixIcon: Icon(icon, size: 18, color: AppColors.faint),
        isDense: true,
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
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
          _SectionHeader(icon: Icons.groups_outlined, title: 'الحجز'),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.heading(size: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTheme.body(size: 13, color: AppColors.muted, height: 1.7)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _StatusType { ok, info }

class _StatusBanner extends StatelessWidget {
  final String message;
  final _StatusType type;

  const _StatusBanner({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final isOk = type == _StatusType.ok;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOk ? const Color(0x125EE089) : const Color(0x05FFFFFF),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isOk ? const Color(0x405EE089) : AppColors.line,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle_outline : Icons.info_outline,
            size: 16,
            color: isOk ? AppColors.grass : AppColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTheme.body(size: 12, color: isOk ? AppColors.grass : AppColors.muted, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookedSheet extends StatelessWidget {
  final String playerId;
  final String code;

  const _BookedSheet({required this.playerId, required this.code});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        top: 22,
        bottom: 22 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, size: 28, color: AppColors.grass),
              const SizedBox(width: 10),
              Text('تم الحجز!', style: AppTheme.heading(size: 20)),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: AppTheme.body(size: 14, color: AppColors.muted, height: 1.8),
              children: const [
                TextSpan(text: 'هذا '),
                TextSpan(
                  text: 'رمزك الخاص',
                  style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' — احتفظ به جيداً:\nفي أي حجز قادم اكتبه وستُعبّأ بياناتك تلقائياً، وعلى أي جهاز آخر اكتبه لتظهر بطاقاتك.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x735EE089), style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.ltr,
              children: [
                Text(
                  code,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    letterSpacing: 7,
                    color: AppColors.grass,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  color: AppColors.faint,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم نسخ رمز اللاعب'),
                        backgroundColor: AppColors.surface,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'رفع إشعار التحويل الآن',
                  icon: Icons.upload_outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    _triggerUpload(context, playerId);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'لاحقاً — سأرفعه من بطاقتي',
              style: BtnStyle.ghost,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerUpload(BuildContext context, String playerId) async {
    // تنفيذ رفع الصورة من المعرض
    final state = context.read<AppState>();
    final ok = await state.uploadReceiptFromGallery(playerId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم رفع الإشعار — بانتظار المراجعة' : 'تعذّر رفع الإشعار'),
        backgroundColor: ok ? AppColors.surface : AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
