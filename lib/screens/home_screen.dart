// شاشة الرئيسية للاعب — بطاقة المباراة + نموذج الحجز
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../utils/arabic_helpers.dart';
import '../../widgets/match_card.dart';
import '../../widgets/join_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!state.isReady && !state.hasError)
            const _LoadingIndicator()
          else if (state.hasError && state.match == null)
            const _ConnectionError()
          else ...[
            const MatchCard(),
            const SizedBox(height: 22),
            const JoinForm(),
            const SizedBox(height: 30),
            _Footer(),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: body,
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(64),
      child: Column(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.grass),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'جارٍ الاتصال بقاعدة البيانات...',
            style: AppTheme.body(size: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ConnectionError extends StatelessWidget {
  const _ConnectionError();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            size: 42,
            color: AppColors.redSoft,
          ),
          const SizedBox(height: 12),
          Text(
            'تعذّر الاتصال بقاعدة البيانات',
            style: AppTheme.heading(size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'تحقق من اتصالك بالإنترنت ثم أعد المحاولة',
            textAlign: TextAlign.center,
            style: AppTheme.body(size: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // إعادة بناء الـ widget بالكامل عبر إعادة قراءة Firebase
              final state = context.read<AppState>();
              state.start();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grass,
              foregroundColor: const Color(0xFF07130A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            icon: const Icon(Icons.restart_alt),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.line, height: 1),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التشكيلة — متصل بقاعدة بيانات Firebase',
              style: AppTheme.body(size: 11, color: AppColors.faint),
            ),
            GestureDetector(
              onTap: () => _showCodeLogin(context),
              child: Row(
                children: [
                  Icon(Icons.login_outlined, size: 13, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    'الدخول برمز اللاعب',
                    style: AppTheme.body(size: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCodeLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => const _CodeLoginSheet(),
    );
  }
}

class _CodeLoginSheet extends StatefulWidget {
  const _CodeLoginSheet();

  @override
  State<_CodeLoginSheet> createState() => _CodeLoginSheetState();
}

class _CodeLoginSheetState extends State<_CodeLoginSheet> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
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
              const Icon(Icons.login_outlined, color: AppColors.grass),
              const SizedBox(width: 10),
              Text('الدخول برمز اللاعب', style: AppTheme.heading(size: 18)),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTheme.body(size: 13, color: AppColors.muted, height: 1.7),
              children: const [
                TextSpan(text: 'أدخل رمزك الخاص لعرض بطاقاتك على هذا الجهاز وتعبئة بياناتك تلقائياً — مفيد إن فتحت الموقع من هاتف آخر أو مسحت بيانات المتصفح.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _codeCtrl,
            maxLength: 8,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              fontFamily: 'Changa',
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              fontSize: 17,
              color: AppColors.ink,
            ),
            decoration: InputDecoration(
              hintText: 'A7BK',
              hintStyle: const TextStyle(
                fontFamily: 'Changa',
                letterSpacing: 3,
                color: AppColors.faint,
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await state.loginWithCode(_codeCtrl.text);
                if (!mounted) return;
                String msg;
                bool ok = false;
                if (result.startsWith('in_match:')) {
                  final parts = result.split(':');
                  msg = 'أهلاً ${parts.length > 2 ? parts[2] : ''} — بطاقتك في هذه المباراة جاهزة';
                  ok = true;
                } else if (result.startsWith('profile:')) {
                  final parts = result.split(':');
                  msg = 'أهلاً ${parts.length > 1 ? parts[1] : ''} — بياناتك جاهزة، اضغط «انضم للتشكيلة» للحجز';
                  ok = true;
                } else if (result == 'not_found') {
                  msg = 'هذا الرمز غير مسجل — سجّل حجزاً جديداً به أولاً';
                } else if (result == 'invalid') {
                  msg = 'أدخل رمزاً صحيحاً (4-8 أحرف/أرقام)';
                } else {
                  msg = 'تعذّر تنفيذ العملية — تحقق من اتصالك';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: ok ? AppColors.surface : AppColors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (ok) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grass,
                foregroundColor: const Color(0xFF07130A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: const Icon(Icons.login_outlined),
              label: const Text(
                'دخول',
                style: TextStyle(
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
