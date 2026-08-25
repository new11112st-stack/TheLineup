// خدمة التخزين المحلي — يحفظ myIds, myCodes, وجلسة الأدمن
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static SharedPreferences get prefs => _prefs;

  // ====== أرقام اللاعبين الخاصة بي ======
  static List<String> get myIds {
    final raw = _prefs.getString(StorageKeys.mine);
    if (raw == null) return [];
    // بسيط: نحفظهم مفصولين بفواصل
    return raw.split(',').where((s) => s.isNotEmpty).toList();
  }

  static Future<void> addMyId(String id) async {
    final ids = myIds;
    if (!ids.contains(id)) {
      ids.add(id);
      await _prefs.setString(StorageKeys.mine, ids.join(','));
    }
  }

  static Future<void> removeMyId(String id) async {
    final ids = myIds;
    ids.remove(id);
    await _prefs.setString(StorageKeys.mine, ids.join(','));
  }

  static Future<void> clearMyIds() async {
    await _prefs.setString(StorageKeys.mine, '');
  }

  // ====== رموز اللاعبين الخاصة بي ======
  static List<String> get myCodes {
    final raw = _prefs.getString(StorageKeys.codes);
    if (raw == null) return [];
    return raw
        .split(',')
        .where((s) => s.isNotEmpty && Validators.isValidCode(s))
        .toList();
  }

  static Future<void> addMyCode(String code) async {
    final c = Validators.normCode(code);
    if (!Validators.isValidCode(c)) return;
    final codes = myCodes;
    if (!codes.contains(c)) {
      codes.add(c);
      await _prefs.setString(StorageKeys.codes, codes.join(','));
    }
  }

  static String? get lastCode {
    final codes = myCodes;
    if (codes.isEmpty) return null;
    return codes.last;
  }

  // ====== جلسة الأدمن ======
  static bool get isAdminUnlocked =>
      _prefs.getString(StorageKeys.adminSession) == '1';

  static Future<void> setAdminSession(bool unlocked) async {
    if (unlocked) {
      await _prefs.setString(StorageKeys.adminSession, '1');
    } else {
      await _prefs.remove(StorageKeys.adminSession);
    }
  }
}
