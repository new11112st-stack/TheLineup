// نموذج إعدادات التطبيق
class AppConfig {
  final bool ready;
  final String? activeMatchId;
  final String? adminPass;

  AppConfig({
    this.ready = false,
    this.activeMatchId,
    this.adminPass,
  });

  AppConfig copyWith({
    bool? ready,
    String? activeMatchId,
    String? adminPass,
  }) =>
      AppConfig(
        ready: ready ?? this.ready,
        activeMatchId: activeMatchId ?? this.activeMatchId,
        adminPass: adminPass ?? this.adminPass,
      );
}

/// نتيجة البحث عن رمز في ملفات اللاعبين
class ProfileLookup {
  final String code;
  final bool found;
  final String name;
  final String phone;

  ProfileLookup({
    required this.code,
    required this.found,
    this.name = '',
    this.phone = '',
  });
}
