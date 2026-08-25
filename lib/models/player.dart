// نموذج اللاعب
class PlayerModel {
  final String id;
  final String name;
  final String phone;
  final String code;
  final String status; // pending | review | confirmed | rejected
  final int joinedAt;
  final String? receipt; // base64 data URL
  final int? receiptAt;
  final String note;

  PlayerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.code,
    required this.status,
    required this.joinedAt,
    this.receipt,
    this.receiptAt,
    required this.note,
  });

  factory PlayerModel.fromMap(String id, Map<String, dynamic> data) {
    return PlayerModel(
      id: id,
      name: (data['name'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      code: (data['code'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'pending',
      joinedAt: (data['joinedAt'] as num?)?.toInt() ?? 0,
      receipt: data['receipt'] as String?,
      receiptAt: (data['receiptAt'] as num?)?.toInt(),
      note: (data['note'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'code': code,
        'status': status,
        'joinedAt': joinedAt,
        'receipt': receipt,
        'receiptAt': receiptAt,
        'note': note,
      };

  PlayerModel copyWith({
    String? name,
    String? phone,
    String? code,
    String? status,
    int? joinedAt,
    String? receipt,
    int? receiptAt,
    String? note,
  }) =>
      PlayerModel(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        code: code ?? this.code,
        status: status ?? this.status,
        joinedAt: joinedAt ?? this.joinedAt,
        receipt: receipt ?? this.receipt,
        receiptAt: receiptAt ?? this.receiptAt,
        note: note ?? this.note,
      );
}
