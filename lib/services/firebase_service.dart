// خدمة Firebase — التهيئة وعمليات Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/match.dart';
import '../models/player.dart';

class FirebaseService {
  static late FirebaseFirestore _db;
  static bool _initialized = false;

  /// تهيئة Firebase
  static Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCSqQt_FmqP3w8byTb8z-pBwPapSAHsAnk',
        appId: '1:761292662915:android:7934907b6d3661ea4513b6',
        messagingSenderId: '761292662915',
        projectId: 'the-neup',
        storageBucket: 'the-neup.firebasestorage.app',
      ),
    );
    try {
      _db = FirebaseFirestore.instance;
      // إعدادات أفضل للأداء
      _db.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {
      _db = FirebaseFirestore.instance;
    }
    _initialized = true;
  }

  static FirebaseFirestore get db => _db;

  // ====== الاستماع لـ config/app ======
  static Stream<DocumentSnapshot<Map<String, dynamic>>> configStream() {
    return _db.collection('config').doc('app').snapshots();
  }

  // ====== الاستماع لجميع المباريات ======
  static Stream<QuerySnapshot<Map<String, dynamic>>> matchesStream() {
    return _db.collection('matches').snapshots();
  }

  // ====== الاستماع لمباراة محددة ======
  static Stream<DocumentSnapshot<Map<String, dynamic>>> matchStream(String id) {
    return _db.collection('matches').doc(id).snapshots();
  }

  // ====== الاستماع للاعبي مباراة محددة ======
  static Stream<QuerySnapshot<Map<String, dynamic>>> playersStream(String matchId) {
    return _db
        .collection('matches')
        .doc(matchId)
        .collection('players')
        .snapshots();
  }

  // ====== إضافة لاعب ======
  static Future<String> addPlayer(String matchId, Map<String, dynamic> data) async {
    final ref = await _db
        .collection('matches')
        .doc(matchId)
        .collection('players')
        .add(data);
    return ref.id;
  }

  // ====== تحديث لاعب ======
  static Future<void> updatePlayer(
      String matchId, String playerId, Map<String, dynamic> data) async {
    await _db
        .collection('matches')
        .doc(matchId)
        .collection('players')
        .doc(playerId)
        .update(data);
  }

  // ====== حذف لاعب ======
  static Future<void> deletePlayer(String matchId, String playerId) async {
    await _db
        .collection('matches')
        .doc(matchId)
        .collection('players')
        .doc(playerId)
        .delete();
  }

  // ====== تحديث مباراة ======
  static Future<void> updateMatch(
      String matchId, Map<String, dynamic> data) async {
    await _db.collection('matches').doc(matchId).update(data);
  }

  // ====== إنشاء مباراة جديدة (مع أرشفة القديمة) ======
  static Future<String> createNewMatch({
    MatchModel? currentMatch,
    required List<PlayerModel> currentPlayers,
    required Map<String, dynamic> newMatchData,
  }) async {
    final batch = _db.batch();

    final newRef = _db.collection('matches').doc();

    if (currentMatch != null) {
      final confirmed =
          currentPlayers.where((p) => p.status == 'confirmed').length;
      final active =
          currentPlayers.where((p) => p.status != 'rejected').length;
      batch.update(_db.collection('matches').doc(currentMatch.id), {
        'status': 'archived',
        'summary': {
          'players': active,
          'confirmed': confirmed,
          'collected': confirmed * (currentMatch.fee),
        }
      });
    }

    batch.set(newRef, {
      ...newMatchData,
      'status': 'open',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'summary': null,
    });

    batch.set(_db.collection('config').doc('app'),
        {'activeMatchId': newRef.id}, SetOptions(merge: true));

    await batch.commit();
    return newRef.id;
  }

  // ====== حفظ / تحديث ملف اللاعب ======
  static Future<void> saveProfile(String code, String name, String phone) async {
    await _db.collection('profiles').doc(code).set({
      'name': name,
      'phone': phone,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  // ====== البحث عن ملف لاعب ======
  static Future<Map<String, dynamic>?> getProfile(String code) async {
    final snap = await _db.collection('profiles').doc(code).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  // ====== تحديث إعدادات التطبيق ======
  static Future<void> updateAppConfig(Map<String, dynamic> data) async {
    await _db
        .collection('config')
        .doc('app')
        .set(data, SetOptions(merge: true));
  }
}
