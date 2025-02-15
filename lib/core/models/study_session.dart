class StudySession {
  final String id;
  final String userId;
  final String deckId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int cardsReviewed;
  final DateTime? lastBreakAt;

  StudySession({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.startedAt,
    this.endedAt,
    required this.cardsReviewed,
    this.lastBreakAt,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'],
      userId: json['user_id'],
      deckId: json['deck_id'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      cardsReviewed: json['cards_reviewed'],
      lastBreakAt: json['last_break_at'] != null ? DateTime.parse(json['last_break_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'deck_id': deckId,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'cards_reviewed': cardsReviewed,
    'last_break_at': lastBreakAt?.toIso8601String(),
  };

  StudySession copyWith({
    String? id,
    String? userId,
    String? deckId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? cardsReviewed,
    DateTime? lastBreakAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deckId: deckId ?? this.deckId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      lastBreakAt: lastBreakAt ?? this.lastBreakAt,
    );
  }
} 