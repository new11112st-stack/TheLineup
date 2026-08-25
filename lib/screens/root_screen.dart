// الشاشة الجذرية — تدير التنقل بين اللاعب والأدمن
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';
import 'squad_screen.dart';
import 'my_cards_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_new_match_screen.dart';
import 'splash_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _playerIndex = 0;
  int _adminIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // شاشة التحميل
    if (!state.isReady && !state.hasError) {
      return const SplashScreen();
    }

    // وضع الأدمن
    if (state.adminUnlocked && state.view == 'admin') {
      return _buildAdminShell();
    }

    // وضع اللاعب
    return _buildPlayerShell();
  }

  Widget _buildPlayerShell() {
    final state = context.read<AppState>();
    final pages = [
      const HomeScreen(),
      const SquadScreen(),
      const MyCardsScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: CustomAppBar(
          onAdminTap: () => _handleAdminTap(state),
        ),
        body: IndexedStack(
          index: _playerIndex,
          children: pages,
        ),
        extendBody: true,
        bottomNavigationBar: PlayerBottomNav(
          currentIndex: _playerIndex,
          onTap: (i) => setState(() => _playerIndex = i),
        ),
      ),
    );
  }

  Widget _buildAdminShell() {
    final state = context.read<AppState>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: CustomAppBar(
          showAdminButton: false,
          onAdminTap: () => state.backHome(),
        ),
        body: IndexedStack(
          index: _adminIndex,
          children: [
            const AdminDashboardScreen(),
            const AdminNewMatchScreen(),
            const SizedBox.shrink(), // تسجيل الخروج — يُعالج بالـ onTap
          ],
        ),
        extendBody: true,
        bottomNavigationBar: AdminBottomNav(
          currentIndex: _adminIndex,
          onTap: (i) => _handleAdminNavTap(i, state),
        ),
      ),
    );
  }

  void _handleAdminNavTap(int index, AppState state) {
    if (index == 2) {
      // تسجيل الخروج
      _showLogoutDialog(state);
      return;
    }
    setState(() => _adminIndex = index);
  }

  void _handleAdminTap(AppState state) {
    final result = state.openAdmin();
    if (result == 'ok') return;
    if (result == 'loading') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('جارٍ الاتصال بالسيرفر، لحظة...'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (result == 'login') {
      _showAdminLogin(state);
    } else if (result == 'setup') {
      _showAdminSetup(state);
    }
  }

  void _showAdminLogin(AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _AdminLoginSheet(state: state),
    );
  }

  void _showAdminSetup(AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => _AdminSetupSheet(state: state),
    );
  }

  void _showLogoutDialog(AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.logout_outlined, color: AppColors.redSoft),
            const SizedBox(width: 10),
            Text('تسجيل الخروج', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        content: const Text(
          'سيتم تسجيل خروجك من لوحة التحكم. ستحتاج لإدخال كلمة المرور للدخول مجدداً.',
          style: TextStyle(color: AppColors.muted, height: 1.7),
        ),
        actions: [
          AppButton(
            label: 'تراجع',
            style: BtnStyle.ghost,
            small: true,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'تسجيل الخروج',
            icon: Icons.logout_outlined,
            style: BtnStyle.danger,
            small: true,
            onPressed: () {
              Navigator.pop(ctx);
              state.logoutAdmin();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم تسجيل الخروج'),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminLoginSheet extends StatefulWidget {
  final AppState state;
  const _AdminLoginSheet({required this.state});

  @override
  State<_AdminLoginSheet> createState() => _AdminLoginSheetState();
}

class _AdminLoginSheetState extends State<_AdminLoginSheet> {
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

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
              const Icon(Icons.shield_outlined, color: AppColors.grass),
              const SizedBox(width: 10),
              Text('دخول الأدمن', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'لوحة التحكم مخصصة لمنظّم المباراة — إعدادات الملعب والمبلغ وقبول الحجوزات.',
            style: TextStyle(color: AppColors.muted, height: 1.7, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'كلمة مرور الأدمن',
              prefixIcon: Icon(Icons.lock_outline, size: 18),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      final ok = await widget.state.loginAdmin(_passCtrl.text);
                      if (!mounted) return;
                      setState(() => _loading = false);
                      if (ok) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('مرحباً بك في لوحة التحكم'),
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('كلمة المرور غير صحيحة'),
                            backgroundColor: AppColors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grass,
                foregroundColor: const Color(0xFF07130A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_outlined),
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

class _AdminSetupSheet extends StatefulWidget {
  final AppState state;
  const _AdminSetupSheet({required this.state});

  @override
  State<_AdminSetupSheet> createState() => _AdminSetupSheetState();
}

class _AdminSetupSheetState extends State<_AdminSetupSheet> {
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

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
              const Icon(Icons.shield_outlined, color: AppColors.grass),
              const SizedBox(width: 10),
              Text('تعيين كلمة مرور الأدمن', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'أول مرة تُفتح فيها اللوحة على هذا المشروع — عيّن كلمة مرور خاصة بالأدمن. تُحفظ في قاعدة البيانات وتُطلب في كل مرة.',
            style: TextStyle(color: AppColors.muted, height: 1.7, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'كلمة المرور (4 محارف على الأقل)',
              prefixIcon: Icon(Icons.lock_outline, size: 18),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pass2Ctrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'تأكيد كلمة المرور',
              prefixIcon: Icon(Icons.lock_outline, size: 18),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loading
                  ? null
                  : () async {
                      if (_passCtrl.text.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('كلمة المرور يجب ألا تقل عن 4 محارف'),
                            backgroundColor: AppColors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      if (_passCtrl.text != _pass2Ctrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('الكلمتان غير متطابقتين'),
                            backgroundColor: AppColors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      setState(() => _loading = true);
                      final ok = await widget.state.setupAdmin(_passCtrl.text, _pass2Ctrl.text);
                      if (!mounted) return;
                      setState(() => _loading = false);
                      if (ok) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('تم تعيين كلمة المرور — مرحباً بك في لوحة التحكم'),
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تعذّر تعيين كلمة المرور — تحقق من اتصالك'),
                            backgroundColor: AppColors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grass,
                foregroundColor: const Color(0xFF07130A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text(
                'تعيين ودخول',
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
