class FlashcardProgress {
  final String id;
  final String userId;
  final String flashcardId;
  final String confidenceLevel;
  final bool isMarkedForLater;
  final DateTime lastReviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  FlashcardProgress({
    required this.id,
    required this.userId,
    required this.flashcardId,
    required this.confidenceLevel,
    required this.isMarkedForLater,
    required this.lastReviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlashcardProgress.fromJson(Map<String, dynamic> json) {
    return FlashcardProgress(
      id: json['id'],
      userId: json['user_id'],
      flashcardId: json['flashcard_id'],
      confidenceLevel: json['confidence_level'],
      isMarkedForLater: json['is_marked_for_later'],
      lastReviewedAt: DateTime.parse(json['last_reviewed_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'flashcard_id': flashcardId,
    'confidence_level': confidenceLevel,
    'is_marked_for_later': isMarkedForLater,
    'last_reviewed_at': lastReviewedAt.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
} 