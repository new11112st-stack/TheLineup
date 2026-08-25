// نموذج المباراة
class MatchModel {
  final String id;
  final String title;
  final String venue;
  final String matchDate; // YYYY-MM-DD
  final String matchTime; // HH:mm
  final String matchEnd; // HH:mm
  final String type; // '5x5' or '7x7'
  final int capacity;
  final int fee;
  final String currency;
  final String phone;
  final String status; // 'open' or 'archived'
  final int? createdAt;
  final MatchSummary? summary;

  MatchModel({
    required this.id,
    required this.title,
    required this.venue,
    required this.matchDate,
    required this.matchTime,
    required this.matchEnd,
    required this.type,
    required this.capacity,
    required this.fee,
    required this.currency,
    required this.phone,
    required this.status,
    this.createdAt,
    this.summary,
  });

  factory MatchModel.fromMap(String id, Map<String, dynamic> data) {
    final summary = data['summary'] as Map<String, dynamic>?;
    return MatchModel(
      id: id,
      title: (data['title'] as String?) ?? 'مباراة',
      venue: (data['venue'] as String?) ?? '',
      matchDate: (data['matchDate'] as String?) ?? '',
      matchTime: (data['matchTime'] as String?) ?? '',
      matchEnd: (data['matchEnd'] as String?) ?? '',
      type: (data['type'] as String?) == '7x7' ? '7x7' : '5x5',
      capacity: (data['capacity'] as num?)?.toInt() ?? 10,
      fee: (data['fee'] as num?)?.toInt() ?? 0,
      currency: (data['currency'] as String?) ?? 'ريال يمني',
      phone: (data['phone'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'open',
      createdAt: (data['createdAt'] as num?)?.toInt(),
      summary: summary != null
          ? MatchSummary(
              players: (summary['players'] as num?)?.toInt() ?? 0,
              confirmed: (summary['confirmed'] as num?)?.toInt() ?? 0,
              collected: (summary['collected'] as num?)?.toInt() ?? 0,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'venue': venue,
        'matchDate': matchDate,
        'matchTime': matchTime,
        'matchEnd': matchEnd,
        'type': type,
        'capacity': capacity,
        'fee': fee,
        'currency': currency,
        'phone': phone,
        'status': status,
        if (createdAt != null) 'createdAt': createdAt,
        if (summary != null)
          'summary': {
            'players': summary!.players,
            'confirmed': summary!.confirmed,
            'collected': summary!.collected,
          },
      };

  MatchModel copyWith({
    String? title,
    String? venue,
    String? matchDate,
    String? matchTime,
    String? matchEnd,
    String? type,
    int? capacity,
    int? fee,
    String? currency,
    String? phone,
    String? status,
    MatchSummary? summary,
  }) =>
      MatchModel(
        id: id,
        title: title ?? this.title,
        venue: venue ?? this.venue,
        matchDate: matchDate ?? this.matchDate,
        matchTime: matchTime ?? this.matchTime,
        matchEnd: matchEnd ?? this.matchEnd,
        type: type ?? this.type,
        capacity: capacity ?? this.capacity,
        fee: fee ?? this.fee,
        currency: currency ?? this.currency,
        phone: phone ?? this.phone,
        status: status ?? this.status,
        createdAt: createdAt,
        summary: summary ?? this.summary,
      );

  /// تاريخ المباراة كـ DateTime
  DateTime get dateObj {
    final parts = matchDate.split('-');
    if (parts.length != 3) return DateTime.now();
    final y = int.tryParse(parts[0]) ?? DateTime.now().year;
    final mo = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;
    return DateTime(y, mo, d);
  }

  DateTime get startDateTime {
    final dt = dateObj;
    final parts = matchTime.split(':');
    return DateTime(dt.year, dt.month, dt.day,
        parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
        parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0);
  }

  DateTime get endDateTime {
    final dt = dateObj;
    final parts = matchEnd.split(':');
    var end = DateTime(dt.year, dt.month, dt.day,
        parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
        parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0);
    if (end.isBefore(startDateTime)) {
      end = end.add(const Duration(days: 1));
    }
    return end;
  }

  /// مرحلة المباراة: 'before' | 'live' | 'ended'
  String get phase {
    final now = DateTime.now();
    if (now.isBefore(startDateTime)) return 'before';
    if (now.isAfter(endDateTime)) return 'ended';
    return 'live';
  }
}

class MatchSummary {
  final int players;
  final int confirmed;
  final int collected;
  MatchSummary({required this.players, required this.confirmed, required this.collected});
}
