// مزود الحالة الرئيسي — يربط Firebase بالواجهة ويدير كل العمليات
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_config.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../services/image_service.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';

class AppState extends ChangeNotifier {
  // ====== الحالة ======
  AppConfig cfg = AppConfig();
  MatchModel? match;
  List<PlayerModel> players = [];
  List<MatchModel> archived = [];

  int connection = -1; // -1 = متصل، نحاول
  String? _netErr;

  bool adminUnlocked = false;
  String view = 'home'; // 'home' | 'admin'
  String adminFilter = 'all';
  String typeDraft = '5x5';
  String newTypeDraft = '5x5';
  String? joinProfileCode;
  ProfileLookup? joinProfile;
  bool _profileLoading = false;

  bool get isReady => cfg.ready;
  bool get hasError => _netErr != null;

  // ====== المزامنة المحلية ======
  List<String> get myIds => StorageService.myIds;
  List<String> get myCodes => StorageService.myCodes;

  List<PlayerModel> get activePlayers =>
      players.where((p) => p.status != 'rejected').toList();

  bool isMine(PlayerModel p) {
    if (myIds.contains(p.id)) return true;
    if (p.code.isNotEmpty) {
      return myCodes.contains(Validators.normCode(p.code));
    }
    return false;
  }

  List<PlayerModel> get myPlayers =>
      players.where((p) => isMine(p)).toList()
        ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

  int shirtNum(PlayerModel p) {
    return players.indexWhere((x) => x.id == p.id) + 1;
  }

  // ====== الاشتراكات ======
  StreamSubscription? _configSub;
  StreamSubscription? _matchesSub;
  StreamSubscription? _matchSub;
  StreamSubscription? _playersSub;
  String? _matchSubscribed;

  /// بداية الاستماع لقاعدة البيانات
  void start() {
    // إلغاء الاشتراكات السابقة إن وجدت
    _configSub?.cancel();
    _matchesSub?.cancel();
    _matchSub?.cancel();
    _playersSub?.cancel();
    _matchSubscribed = null;

    _configSub = FirebaseService.configStream().listen(
      (snap) {
        cfg = AppConfig(ready: true);
        if (snap.exists) {
          final d = snap.data()!;
          cfg = cfg.copyWith(
            activeMatchId: d['activeMatchId'] as String?,
            adminPass: d['adminPass'] as String?,
          );
        }
        _setLive(_snapState(snap));
        attachMatch();
        notifyListeners();
      },
      onError: (e) {
        cfg = AppConfig(ready: true);
        _setLive(Connection.error);
        _netErr = e.toString();
        notifyListeners();
      },
    );

    _matchesSub = FirebaseService.matchesStream().listen(
      (snap) {
        _setLive(_snapState(snap));
        archived = snap.docs
            .map((d) => MatchModel.fromMap(d.id, d.data() ?? {}))
            .where((m) => m.status == 'archived')
            .toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
        notifyListeners();
      },
      onError: (e) {
        _setLive(Connection.error);
        notifyListeners();
      },
    );

    adminUnlocked = StorageService.isAdminUnlocked;
  }

  void attachMatch() {
    final id = cfg.activeMatchId;
    if (_matchSubscribed == id) return;

    _matchSub?.cancel();
    _playersSub?.cancel();
    _matchSubscribed = id;
    match = null;
    players = [];

    if (id == null) {
      notifyListeners();
      return;
    }

    _matchSub = FirebaseService.matchStream(id).listen(
      (snap) {
        _setLive(_snapState(snap));
        match = snap.exists
            ? MatchModel.fromMap(snap.id, snap.data() ?? {})
            : null;
        if (match == null) players = [];
        notifyListeners();
      },
      onError: (e) {
        _setLive(Connection.error);
        notifyListeners();
      },
    );

    _playersSub = FirebaseService.playersStream(id).listen(
      (snap) {
        _setLive(_snapState(snap));
        players = snap.docs
            .map((d) => PlayerModel.fromMap(d.id, d.data() ?? {}))
            .toList()
          ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
        notifyListeners();
      },
      onError: (e) {
        _setLive(Connection.error);
        notifyListeners();
      },
    );
  }

  int _snapState(dynamic snap) {
    if (snap == null) return Connection.error;
    try {
      if (snap.metadata.isFromCache) return Connection.cache;
    } catch (_) {}
    return Connection.ok;
  }

  void _setLive(int state) {
    connection = state;
    if (state == Connection.ok) _netErr = null;
  }

  // ====== العمليات ======

  /// محاولة فتح لوحة الأدمن
  /// ترجع: 'ok' | 'login' | 'setup' | 'loading'
  String openAdmin() {
    if (!cfg.ready) return 'loading';
    if (adminUnlocked) {
      view = 'admin';
      notifyListeners();
      return 'ok';
    }
    return (cfg.adminPass != null && cfg.adminPass!.isNotEmpty) ? 'login' : 'setup';
  }

  Future<bool> loginAdmin(String pass) async {
    if (cfg.adminPass != null && pass == cfg.adminPass) {
      await StorageService.setAdminSession(true);
      adminUnlocked = true;
      view = 'admin';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> setupAdmin(String pass, String pass2) async {
    if (pass.length < 4) return false;
    if (pass != pass2) return false;
    try {
      await FirebaseService.updateAppConfig({'adminPass': pass});
      await StorageService.setAdminSession(true);
      adminUnlocked = true;
      view = 'admin';
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logoutAdmin() {
    adminUnlocked = false;
    StorageService.setAdminSession(false);
    view = 'home';
    notifyListeners();
  }

  void backHome() {
    view = 'home';
    notifyListeners();
  }

  void setAdminFilter(String filter) {
    adminFilter = filter;
    notifyListeners();
  }

  /// إضافة لاعب جديد
  /// ترجع: (success, playerId, errorCode)
  Future<({bool ok, String? playerId, String? err})> addPlayer({
    required String code,
    required String name,
    required String phone,
  }) async {
    if (match == null) {
      return (ok: false, playerId: null, err: 'لا يوجد حجز مفتوح حالياً');
    }
    if (match!.phase != 'before') {
      return (ok: false, playerId: null, err: 'اعتذرنا، بدأ وقت المباراة وأُغلق التسجيل');
    }
    if (activePlayers.length >= match!.capacity) {
      return (ok: false, playerId: null, err: 'اكتمل عدد اللاعبين');
    }

    final c = Validators.normCode(code);
    if (!Validators.isValidCode(c)) {
      return (ok: false, playerId: null, err: 'اكتب رمزاً من 4 إلى 8 أحرف إنجليزية أو أرقام');
    }

    // التحقق إن لم يكن رمزاً مستخدماً في هذه المباراة
    final existing = players.firstWhere(
      (p) => Validators.normCode(p.code) == c,
      orElse: () => PlayerModel(
        id: '',
        name: '',
        phone: '',
        code: '',
        status: '',
        joinedAt: 0,
        note: '',
      ),
    );
    if (existing.id.isNotEmpty) {
      // الرمز له حجز في هذه المباراة — نضيفه لـ myIds ونعرض البطاقة
      await StorageService.addMyId(existing.id);
      await StorageService.addMyCode(c);
      notifyListeners();
      return (ok: true, playerId: existing.id, err: 'existing');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return (ok: false, playerId: null, err: 'اكتب اسم اللاعب أولاً');
    }

    try {
      final newId = await FirebaseService.addPlayer(match!.id, {
        'name': Validators.clamp(trimmedName, 30),
        'phone': Validators.clamp(phone.trim(), 20),
        'code': c,
        'status': 'pending',
        'joinedAt': DateTime.now().millisecondsSinceEpoch,
        'receipt': null,
        'receiptAt': null,
        'note': '',
      });

      await StorageService.addMyId(newId);
      await StorageService.addMyCode(c);

      // حفظ الملف الشخصي للاستخدام المستقبلي
      FirebaseService.saveProfile(c, trimmedName, phone).catchError((_) {});

      notifyListeners();
      return (ok: true, playerId: newId, err: null);
    } catch (e) {
      return (ok: false, playerId: null, err: _dbErrMsg(e));
    }
  }

  /// رفع إشعار التحويل
  Future<bool> uploadReceipt(String playerId, String dataUrl) async {
    if (match == null) return false;
    try {
      await FirebaseService.updatePlayer(match!.id, playerId, {
        'receipt': dataUrl,
        'receiptAt': DateTime.now().millisecondsSinceEpoch,
        'status': 'review',
        'note': '',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// فتح معرض الصور ورفع الإشعار
  Future<bool> uploadReceiptFromGallery(String playerId) async {
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (xfile == null) return false;
      final file = File(xfile.path);
      final dataUrl = await ImageService.compressToDataUrl(file);
      if (dataUrl == null) return false;
      return await uploadReceipt(playerId, dataUrl);
    } catch (e) {
      return false;
    }
  }

  /// إزالة لاعب
  Future<bool> removePlayer(String playerId) async {
    if (match == null) return false;
    try {
      await StorageService.removeMyId(playerId);
      await FirebaseService.deletePlayer(match!.id, playerId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// قبول لاعب (أدمن)
  Future<bool> acceptPlayer(String playerId) async {
    if (match == null) return false;
    try {
      await FirebaseService.updatePlayer(match!.id, playerId, {
        'status': 'confirmed',
        'note': '',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// رفض لاعب (أدمن)
  Future<bool> rejectPlayer(String playerId, {String note = ''}) async {
    if (match == null) return false;
    try {
      await FirebaseService.updatePlayer(match!.id, playerId, {
        'status': 'rejected',
        'note': note.length > 80 ? note.substring(0, 80) : note,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف لاعب نهائياً (أدمن)
  Future<bool> deletePlayer(String playerId) async {
    if (match == null) return false;
    try {
      await StorageService.removeMyId(playerId);
      await FirebaseService.deletePlayer(match!.id, playerId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// حفظ إعدادات المباراة (أدمن)
  Future<bool> saveMatchSettings({
    required String title,
    required String venue,
    required String matchDate,
    required String matchTime,
    required String matchEnd,
    required String type,
    required int capacity,
    required int fee,
    required String currency,
    required String phone,
    String? newPass,
  }) async {
    if (match == null) return false;
    try {
      await FirebaseService.updateMatch(match!.id, {
        'title': title.trim().isEmpty ? 'مباراة' : Validators.clamp(title.trim(), 40),
        'venue': Validators.clamp(venue.trim(), 40),
        'matchDate': matchDate,
        'matchTime': matchTime,
        'matchEnd': matchEnd,
        'type': type == '7x7' ? '7x7' : '5x5',
        'capacity': Validators.clampInt(capacity, 2, 30, 10),
        'fee': fee < 0 ? 0 : fee,
        'currency': currency.trim().isEmpty ? 'ريال يمني' : Validators.clamp(currency.trim(), 12),
        'phone': Validators.clamp(phone.trim(), 20),
      });
      if (newPass != null && newPass.isNotEmpty) {
        await FirebaseService.updateAppConfig({'adminPass': newPass});
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// إنشاء مباراة جديدة (أدمن)
  Future<bool> createNewMatch({
    required String title,
    required String venue,
    required String matchDate,
    required String matchTime,
    required String matchEnd,
    required String type,
    required int capacity,
    required int fee,
    required String currency,
    required String phone,
  }) async {
    try {
      await FirebaseService.createNewMatch(
        currentMatch: match,
        currentPlayers: players,
        newMatchData: {
          'title': title.trim().isEmpty ? 'مباراة' : Validators.clamp(title.trim(), 40),
          'venue': Validators.clamp(venue.trim(), 40),
          'matchDate': matchDate,
          'matchTime': matchTime,
          'matchEnd': matchEnd,
          'type': type == '7x7' ? '7x7' : '5x5',
          'capacity': Validators.clampInt(capacity, 2, 30, 10),
          'fee': fee < 0 ? 0 : fee,
          'currency': currency.trim().isEmpty ? 'ريال يمني' : Validators.clamp(currency.trim(), 12),
          'phone': Validators.clamp(phone.trim(), 20),
        },
      );
      await StorageService.clearMyIds();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// البحث عن ملف لاعب
  Future<void> lookupProfile(String code) async {
    final c = Validators.normCode(code);
    if (!Validators.isValidCode(c)) return;
    _profileLoading = true;

    try {
      final data = await FirebaseService.getProfile(c);
      joinProfile = ProfileLookup(
        code: c,
        found: data != null,
        name: (data?['name'] as String?) ?? '',
        phone: (data?['phone'] as String?) ?? '',
      );
      joinProfileCode = c;
    } catch (_) {
      joinProfile = ProfileLookup(code: c, found: false);
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  bool get profileLoading => _profileLoading;

  /// الدخول برمز اللاعب
  /// ترجع: 'ok' | 'not_found' | 'err'
  Future<String> loginWithCode(String code) async {
    final c = Validators.normCode(code);
    if (!Validators.isValidCode(c)) return 'invalid';
    try {
      final data = await FirebaseService.getProfile(c);
      if (data == null) return 'not_found';
      await StorageService.addMyCode(c);
      final pl = players.firstWhere(
        (p) => Validators.normCode(p.code) == c,
        orElse: () => PlayerModel(
          id: '',
          name: '',
          phone: '',
          code: '',
          status: '',
          joinedAt: 0,
          note: '',
        ),
      );
      if (pl.id.isNotEmpty) {
        await StorageService.addMyId(pl.id);
        notifyListeners();
        return 'in_match:${pl.id}:${data['name'] ?? ''}';
      }
      notifyListeners();
      return 'profile:${data['name'] ?? ''}';
    } catch (e) {
      return 'err';
    }
  }

  String _dbErrMsg(dynamic e) {
    final code = (e is FirebaseException) ? e.code : '';
    final msg = e.toString();
    if (code == 'permission-denied') {
      return 'قواعد أمان Firestore تمنع هذه العملية — راجعها في لوحة Firebase';
    }
    if (msg.contains('unavailable') || msg.contains('failed-precondition')) {
      return 'لا يوجد اتصال بخوادم Firebase';
    }
    if (msg.toLowerCase().contains('not exist') || msg.toLowerCase().contains('database')) {
      return 'قاعدة البيانات غير منشأة في مشروع Firebase';
    }
    return 'تعذّر تنفيذ العملية — تحقق من اتصالك';
  }

  void resetProfile() {
    joinProfile = null;
    joinProfileCode = null;
  }

  @override
  void dispose() {
    _configSub?.cancel();
    _matchesSub?.cancel();
    _matchSub?.cancel();
    _playersSub?.cancel();
    super.dispose();
  }
}
