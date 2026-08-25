// شاشة إضافة حجز جديد — مطابقة لـ newMatchForm في الموقع
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/arabic_helpers.dart';
import '../widgets/app_button.dart';

class AdminNewMatchScreen extends StatefulWidget {
  const AdminNewMatchScreen({super.key});

  @override
  State<AdminNewMatchScreen> createState() => _AdminNewMatchScreenState();
}

class _AdminNewMatchScreenState extends State<AdminNewMatchScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _venueCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _endCtrl;
  late TextEditingController _capacityCtrl;
  late TextEditingController _feeCtrl;
  late TextEditingController _currencyCtrl;
  late TextEditingController _phoneCtrl;
  String _type = '5x5';
  bool _hasCurrent = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final match = state.match;
    _hasCurrent = match != null;

    if (match != null) {
      _titleCtrl = TextEditingController(text: match.title);
      _venueCtrl = TextEditingController(text: match.venue);
      _dateCtrl = TextEditingController(text: match.matchDate);
      _timeCtrl = TextEditingController(text: match.matchTime);
      _endCtrl = TextEditingController(text: match.matchEnd);
      _capacityCtrl = TextEditingController(text: '${match.capacity}');
      _feeCtrl = TextEditingController(text: '${match.fee}');
      _currencyCtrl = TextEditingController(text: match.currency);
      _phoneCtrl = TextEditingController(text: match.phone);
      _type = match.type;
    } else {
      final d = DateTime.now().add(const Duration(days: 3));
      _titleCtrl = TextEditingController();
      _venueCtrl = TextEditingController();
      _dateCtrl = TextEditingController(text: fmtDateInput(d));
      _timeCtrl = TextEditingController();
      _endCtrl = TextEditingController();
      _capacityCtrl = TextEditingController(text: '10');
      _feeCtrl = TextEditingController();
      _currencyCtrl = TextEditingController(text: 'ريال يمني');
      _phoneCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _venueCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _endCtrl.dispose();
    _capacityCtrl.dispose();
    _feeCtrl.dispose();
    _currencyCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _setType(String t) {
    setState(() {
      _type = t;
      _capacityCtrl.text = t == '7x7' ? '14' : '10';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
        child: Container(
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
                  Icon(Icons.event_available_outlined, size: 22, color: AppColors.grass),
                  const SizedBox(width: 10),
                  Text(
                    _hasCurrent ? 'إنشاء حجز جديد' : 'إنشاء الحجز الأول',
                    style: AppTheme.heading(size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _hasCurrent
                    ? 'سيُؤرشف الحجز الحالي مع لاعبيه في «الحجوزات السابقة»، ويُفتح حجز جديد فارغ. الحقول ممهدة ببيانات الحجز الحالي.'
                    : 'أدخل تفاصيل الحجز ليبدأ اللاعبون بالتسجيل فوراً — يظهر مباشرةً لكل من يفتح التطبيق.',
                style: AppTheme.body(size: 13, color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 18),
              _Field(label: 'عنوان المباراة', child: TextField(controller: _titleCtrl, maxLength: 40, decoration: const InputDecoration(counterText: '', hintText: 'مثال: مباراة الجيرة'))),
              const SizedBox(height: 14),
              _Field(label: 'الملعب / الموقع', child: TextField(controller: _venueCtrl, maxLength: 40, decoration: const InputDecoration(counterText: '', hintText: 'اسم الملعب'))),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Field(label: 'التاريخ', child: TextField(controller: _dateCtrl, readOnly: true, onTap: _pickDate, decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today_outlined, size: 18))))),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'من (البداية)', child: TextField(controller: _timeCtrl, readOnly: true, onTap: () => _pickTime(_timeCtrl), decoration: const InputDecoration(suffixIcon: Icon(Icons.access_time_outlined, size: 18))))),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'إلى (النهاية)', child: TextField(controller: _endCtrl, readOnly: true, onTap: () => _pickTime(_endCtrl), decoration: const InputDecoration(suffixIcon: Icon(Icons.access_time_outlined, size: 18))))),
                ],
              ),
              const SizedBox(height: 14),
              _Field(
                label: 'نوع الملعب',
                child: Row(
                  children: [
                    Expanded(
                      child: _SegButton(
                        label: 'ملعب 5×5',
                        isActive: _type == '5x5',
                        onTap: () => _setType('5x5'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SegButton(
                        label: 'ملعب 7×7',
                        isActive: _type == '7x7',
                        onTap: () => _setType('7x7'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _Field(label: 'عدد اللاعبين', child: TextField(controller: _capacityCtrl, keyboardType: TextInputType.number))),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'مبلغ الحجز للفرد', child: TextField(controller: _feeCtrl, keyboardType: TextInputType.number))),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(label: 'العملة', child: TextField(controller: _currencyCtrl, maxLength: 12, decoration: const InputDecoration(counterText: '')))),
                ],
              ),
              const SizedBox(height: 14),
              _Field(label: 'رقم استلام الحوالات', child: TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: const InputDecoration(hintText: 'رقم الهاتف / المحفظة'))),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _hasCurrent ? 'فتح الحجز الجديد' : 'فتح الحجز',
                  icon: Icons.event_available_outlined,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.grass,
            onPrimary: Color(0xFF07130A),
            surface: AppColors.surface,
            onSurface: AppColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateCtrl.text = fmtDateInput(picked);
    }
  }

  void _pickTime(TextEditingController ctrl) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(ctrl.text),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.grass,
            onPrimary: Color(0xFF07130A),
            surface: AppColors.surface,
            onSurface: AppColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text = '${pad2(picked.hour)}:${pad2(picked.minute)}';
    }
  }

  TimeOfDay _parseTime(String s) {
    if (s.isEmpty) return TimeOfDay.now();
    final parts = s.split(':');
    if (parts.length != 2) return TimeOfDay.now();
    return TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
  }

  void _submit() async {
    final date = _dateCtrl.text.trim();
    final time = _timeCtrl.text.trim();
    final end = _endCtrl.text.trim();
    final cap = int.tryParse(_capacityCtrl.text) ?? 0;
    final fee = int.tryParse(_feeCtrl.text);

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      _toast('حدد تاريخ المباراة', true);
      return;
    }
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(time)) {
      _toast('حدد وقت البداية', true);
      return;
    }
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(end)) {
      _toast('حدد وقت النهاية', true);
      return;
    }
    if (cap == 0) {
      _toast('حدد عدد اللاعبين', true);
      return;
    }
    if (fee == null) {
      _toast('حدد مبلغ الحجز', true);
      return;
    }

    final state = context.read<AppState>();
    final ok = await state.createNewMatch(
      title: _titleCtrl.text,
      venue: _venueCtrl.text,
      matchDate: date,
      matchTime: time,
      matchEnd: end,
      type: _type,
      capacity: cap,
      fee: fee,
      currency: _currencyCtrl.text,
      phone: _phoneCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      _toast('تم فتح الحجز الجديد — التسجيل متاح الآن', false);
      // العودة للوحة التحكم
      Navigator.pop(context);
    } else {
      _toast('تعذّر فتح الحجز — تحقق من اتصالك', true);
    }
  }

  void _toast(String msg, bool err) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: err ? AppColors.red : AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.body(size: 12, color: AppColors.muted)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _SegButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0x1F5EE089) : AppColors.inputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? AppColors.grass : AppColors.lineStrong),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Changa',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isActive ? AppColors.grass : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
